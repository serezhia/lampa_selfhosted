(function () {
    'use strict';

    var PLUGIN_NAME = 'LampaTranscoding';
    var API_BASE = '';  // Will use relative URLs

    var activeJob = null;
    var heartbeatTimer = null;

    // =========================================================================
    // Logging & Notifications
    // =========================================================================

    function log() {
        try {
            var args = Array.prototype.slice.call(arguments);
            args.unshift('[' + PLUGIN_NAME + ']');
            console.log.apply(console, args);
        } catch (e) { /* noop */ }
    }

    function notify(message, time) {
        if (Lampa && Lampa.Noty) {
            Lampa.Noty.show(message, { time: time || 3000 });
        } else {
            log(message);
        }
    }

    // =========================================================================
    // Authentication Headers
    // =========================================================================

    function getAuthHeaders() {
        var headers = {};

        // CUB Account - use 'token' and 'profile' headers as expected by server
        var account = Lampa.Storage.get('account', '{}');
        if (account && account.token) {
            headers['token'] = account.token;
            if (account.profile && account.profile.id) {
                headers['profile'] = String(account.profile.id);
            }
        }

        return headers;
    }

    function addAuthToUrl(url) {
        var account = Lampa.Storage.get('account', '{}');
        if (account && account.token) {
            url = Lampa.Utils.addUrlComponent(url, 'token=' + encodeURIComponent(account.token));
            if (account.profile && account.profile.id) {
                url = Lampa.Utils.addUrlComponent(url, 'profile=' + encodeURIComponent(account.profile.id));
            }
        }
        return url;
    }

    // =========================================================================
    // API Requests
    // =========================================================================

    function apiRequest(method, path, body, onSuccess, onError, options) {
        options = options || {};
        var url = API_BASE + path;

        var xhr = new XMLHttpRequest();
        xhr.open(method, url, true);
        xhr.timeout = options.timeout || 30000;

        // Set headers
        var headers = getAuthHeaders();
        for (var key in headers) {
            xhr.setRequestHeader(key, headers[key]);
        }

        if (body && typeof body === 'object') {
            xhr.setRequestHeader('Content-Type', 'application/json');
        }

        xhr.onload = function () {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var response = xhr.responseText;
                    if (options.json !== false) {
                        response = JSON.parse(response);
                    }
                    if (onSuccess) onSuccess(response);
                } catch (e) {
                    if (onError) onError(e);
                }
            } else {
                if (onError) onError(new Error('HTTP ' + xhr.status));
            }
        };

        xhr.onerror = function () {
            if (onError) onError(new Error('Network error'));
        };

        xhr.ontimeout = function () {
            if (onError) onError(new Error('Request timeout'));
        };

        if (body && typeof body === 'object') {
            xhr.send(JSON.stringify(body));
        } else {
            xhr.send(body || null);
        }

        return xhr;
    }

    // =========================================================================
    // Helpers
    // =========================================================================

    function resolveMediaUrl(data) {
        if (data && data.url) return data.url;
        return '';
    }

    function shouldTranscode(data) {
        var url = resolveMediaUrl(data);
        if (!url) return false;

        // Already transcoded
        if (data.transcoding) return false;
        if (/\/transcoding\//i.test(url)) return false;

        // MKV, AVI, FLV files
        if (/\.(mkv|avi|flv)($|\?|#)/i.test(url)) return true;

        // TorrServer streams
        if (/\/stream\?/i.test(url)) return true;
        if (/torrserver/i.test(url)) return true;

        // Lampac pidtor
        if (/\/lite\/pidtor\//i.test(url)) return true;

        return false;
    }

    function showWait(message) {
        Lampa.Loading.start(function () { }, message);
    }

    function hideWait() {
        Lampa.Loading.stop();
    }

    // =========================================================================
    // Audio Track Formatting
    // =========================================================================

    function formatAudioItem(track, index) {
        var tags = track.tags || {};
        var title = tags.title || tags.handler_name || ('Дорожка ' + (index + 1));
        var lang = (tags.language || '').toUpperCase();
        var codec = (track.codec_name || '').toUpperCase();

        // Channel layout
        var channels = '';
        if (track.channel_layout) {
            channels = track.channel_layout
                .replace('(side)', '')
                .replace('stereo', '2.0')
                .replace('5.1', '5.1')
                .replace('7.1', '7.1');
        } else if (track.channels) {
            channels = track.channels + ' ch';
        }

        // Bitrate
        var rate = '';
        if (track.bit_rate) {
            rate = Math.round(track.bit_rate / 1000) + ' kbps';
        }

        var subtitleParts = [];
        if (lang) subtitleParts.push(lang);
        if (codec) subtitleParts.push(codec);
        if (channels) subtitleParts.push(channels);
        if (rate) subtitleParts.push(rate);

        return {
            title: title,
            subtitle: subtitleParts.join(' • '),
            track: track,
            index: index
        };
    }

    // =========================================================================
    // Subtitle Track Formatting
    // =========================================================================

    function formatSubtitleItem(track, index) {
        var tags = track.tags || {};
        var title = tags.title || tags.handler_name || ('Субтитры ' + (index + 1));
        var lang = (tags.language || '').toUpperCase();
        var codec = (track.codec_name || '').toUpperCase();

        var subtitleParts = [];
        if (lang) subtitleParts.push(lang);
        if (codec) subtitleParts.push(codec);

        return {
            title: title,
            subtitle: subtitleParts.join(' • '),
            track: track,
            index: index
        };
    }

    // =========================================================================
    // Track Selection UI
    // =========================================================================

    function showAudioSelector(data, audioTracks, subtitleTracks, duration) {
        if (!audioTracks.length) {
            notify('Не найдены аудиодорожки');
            return;
        }

        var items = audioTracks.map(function (track, index) {
            return formatAudioItem(track, index);
        });

        var lastController = Lampa.Controller.enabled().name;

        Lampa.Select.show({
            title: 'Выберите аудиодорожку',
            items: items,
            onSelect: function (item) {
                Lampa.Select.close();
                if (!item || item.track === undefined) {
                    notify('Не выбрана дорожка');
                    return;
                }

                // If there are subtitles, ask for them too
                if (subtitleTracks && subtitleTracks.length > 0) {
                    showSubtitleSelector(data, item.track, subtitleTracks, duration);
                } else {
                    startTranscoding(data, item.track, null, duration);
                }
            },
            onBack: function () {
                Lampa.Controller.toggle(lastController);
            }
        });
    }

    function showSubtitleSelector(data, audioTrack, subtitleTracks, duration) {
        var items = [{
            title: 'Без субтитров',
            subtitle: '',
            track: null,
            index: -1
        }];

        subtitleTracks.forEach(function (track, index) {
            items.push(formatSubtitleItem(track, index));
        });

        var lastController = Lampa.Controller.enabled().name;

        Lampa.Select.show({
            title: 'Выберите субтитры',
            items: items,
            onSelect: function (item) {
                Lampa.Select.close();
                startTranscoding(data, audioTrack, item.track, duration);
            },
            onBack: function () {
                Lampa.Controller.toggle(lastController);
            }
        });
    }

    // =========================================================================
    // FFprobe
    // =========================================================================

    function requestFfprobe(mediaUrl, onSuccess, onError) {
        if (!mediaUrl) {
            if (onError) onError(new Error('Empty media URL'));
            return;
        }

        log('FFprobe request:', mediaUrl);

        apiRequest('GET', '/api/transcoding/ffprobe?media=' + encodeURIComponent(mediaUrl), null,
            function (response) {
                log('FFprobe response:', response);
                if (onSuccess) onSuccess(response);
            },
            function (error) {
                log('FFprobe error:', error);
                if (onError) onError(error);
            },
            { timeout: 60000 }
        );
    }

    // =========================================================================
    // Transcoding Control
    // =========================================================================

    var mediaDuration = null;  // Store duration from ffprobe
    var durationOverrideApplied = false;  // Track if override is active

    // =========================================================================
    // Duration Override
    // =========================================================================

    /**
     * Override video.duration property to return the real duration from ffprobe.
     * HLS streams report duration that grows dynamically as segments load,
     * so we fix it to the known value.
     */
    function overrideVideoDuration(video, fixedDuration) {
        if (!video || !fixedDuration || fixedDuration <= 0) return;

        try {
            Object.defineProperty(video, 'duration', {
                configurable: true,
                get: function () {
                    return fixedDuration;
                },
                set: function () {
                    // ignore sets
                }
            });

            durationOverrideApplied = true;
            log('Duration overridden to', fixedDuration, 'seconds');
        } catch (e) {
            log('Failed to override duration:', e);
        }
    }

    /**
     * Restore the original video.duration property
     */
    function restoreVideoDuration(video) {
        if (!durationOverrideApplied) return;

        try {
            if (video) {
                // Remove the instance-level override, restoring prototype behavior
                delete video.duration;
            }
            durationOverrideApplied = false;
            log('Duration restored to native');
        } catch (e) {
            log('Failed to restore duration:', e);
        }
    }

    /**
     * Handler for loadeddata event — apply duration override as soon as
     * video metadata is available
     */
    function handleVideoLoadedData() {
        if (!activeJob || !mediaDuration) return;

        try {
            var video = Lampa.PlayerVideo.video();
            if (video) {
                log('Video loadeddata, native duration:', video.duration,
                    '- overriding to:', mediaDuration);
                overrideVideoDuration(video, mediaDuration);

                // Force a timeupdate-like refresh so the UI picks up the new duration
                // immediately instead of waiting for the next natural timeupdate
                try {
                    Lampa.PlayerVideo.listener.send('timeupdate', {
                        duration: mediaDuration,
                        current: video.currentTime || 0
                    });
                } catch (e) { /* noop */ }
            }
        } catch (e) {
            log('Error in loadeddata handler:', e);
        }
    }

    function startTranscoding(data, audioTrack, subtitleTrack, duration) {
        stopHeartbeat();
        ensureJobStopped(true);

        showWait('Запуск транскодирования...');

        var payload = {
            src: resolveMediaUrl(data),
            audioIndex: audioTrack ? audioTrack.index : 0
        };

        if (subtitleTrack) {
            payload.subtitleIndex = subtitleTrack.index;
        }

        // Pass duration from ffprobe
        if (duration) {
            payload.duration = duration;
        }

        // Pass movie metadata for better filenames
        if (data.movie) {
            payload.title = data.movie.title || data.movie.name || '';
        }

        log('Start transcoding:', payload);

        apiRequest('POST', '/api/transcoding/start', payload,
            function (response) {
                hideWait();
                log('Transcoding started:', response);

                if (!response || !response.streamId || !response.playlistUrl) {
                    notify('Некорректный ответ сервера');
                    return;
                }

                activeJob = {
                    streamId: response.streamId,
                    playlistUrl: response.playlistUrl,
                    duration: response.duration || duration
                };

                // Store duration for player
                mediaDuration = response.duration || duration;

                // Start heartbeat
                startHeartbeat();

                // Play the HLS stream
                var playback = Object.assign({}, data);
                playback.transcoding = true;
                playback.url = addAuthToUrl(response.playlistUrl);

                // Set duration if known
                if (mediaDuration) {
                    playback.duration = mediaDuration;
                }

                // Add subtitles if returned
                if (response.subtitlesUrl) {
                    playback.subtitles = playback.subtitles || [];
                    playback.subtitles.push({
                        label: 'Встроенные',
                        url: addAuthToUrl(response.subtitlesUrl)
                    });
                }

                log('Playing transcoded stream:', playback.url);
                Lampa.Player.play(playback);
            },
            function (error) {
                hideWait();
                notify('Ошибка запуска транскодирования');
                log('Start error:', error);
            },
            { timeout: 30000 }
        );
    }

    function startHeartbeat() {
        stopHeartbeat();
        heartbeatTimer = setInterval(sendHeartbeat, 15000);
    }

    function stopHeartbeat() {
        if (heartbeatTimer) {
            clearInterval(heartbeatTimer);
            heartbeatTimer = null;
        }
    }

    function sendHeartbeat() {
        if (!activeJob) return;

        apiRequest('POST', '/api/transcoding/' + activeJob.streamId + '/heartbeat', null,
            function () {
                log('Heartbeat OK');
            },
            function (error) {
                log('Heartbeat error:', error);
            },
            { timeout: 10000 }
        );
    }

    function ensureJobStopped(sendRemote) {
        if (!activeJob) return;

        var job = activeJob;
        activeJob = null;
        stopHeartbeat();

        if (sendRemote) {
            apiRequest('POST', '/api/transcoding/' + job.streamId + '/stop', null,
                function () {
                    log('Transcoding stopped');
                },
                function (error) {
                    log('Stop error:', error);
                },
                { timeout: 10000 }
            );
        }
    }

    // =========================================================================
    // Player Event Handlers
    // =========================================================================

    function handlePlayerCreate(e) {
        var data = e.data || {};

        // Skip if not applicable
        if (!shouldTranscode(data)) {
            return;
        }

        log('Intercepting playback:', data.url);

        // Abort default playback
        if (e.abort) e.abort();

        // Fix TorrServer URL if needed
        var mediaUrl = resolveMediaUrl(data);
        if (mediaUrl.indexOf('&preload') > -1) {
            mediaUrl = mediaUrl.replace(/&(preload|stat|m3u)/g, '&play');
            data.url = mediaUrl;
        }

        showWait('Анализ медиафайла...');

        requestFfprobe(mediaUrl, function (info) {
            hideWait();

            var streams = (info && Array.isArray(info.streams)) ? info.streams : [];

            // Get duration from format info
            var duration = null;
            if (info && info.format && info.format.duration) {
                duration = parseFloat(info.format.duration);
                log('Media duration:', duration, 'seconds');
            }

            var audioTracks = streams.filter(function (s) {
                return s.codec_type === 'audio';
            });

            var subtitleTracks = streams.filter(function (s) {
                return s.codec_type === 'subtitle';
            });

            log('Found audio tracks:', audioTracks.length);
            log('Found subtitle tracks:', subtitleTracks.length);

            if (audioTracks.length === 0) {
                notify('Аудиодорожки не найдены');
                return;
            }

            // If only one audio track, skip selection
            if (audioTracks.length === 1 && subtitleTracks.length === 0) {
                startTranscoding(data, audioTracks[0], null, duration);
            } else {
                showAudioSelector(data, audioTracks, subtitleTracks, duration);
            }
        }, function (error) {
            hideWait();
            notify('Ошибка анализа файла');
            log('FFprobe error:', error);
        });
    }

    function handlePlayerDestroy() {
        log('Player destroy event');

        // Restore native duration before destroying
        try {
            var video = Lampa.PlayerVideo.video();
            restoreVideoDuration(video);
        } catch (e) { /* noop */ }

        mediaDuration = null;
        ensureJobStopped(true);
    }

    function handlePlayerBack() {
        log('Player back event');

        // Restore native duration before leaving
        try {
            var video = Lampa.PlayerVideo.video();
            restoreVideoDuration(video);
        } catch (e) { /* noop */ }

        mediaDuration = null;
        ensureJobStopped(true);
    }

    function handleVideoPause() {
        // Keep heartbeat going during pause
        if (activeJob && !heartbeatTimer) {
            startHeartbeat();
        }
    }

    function handleVideoPlay() {
        // Heartbeat continues during play too
        if (activeJob && !heartbeatTimer) {
            startHeartbeat();
        }
    }

    // =========================================================================
    // Plugin Initialization
    // =========================================================================

    function initPlugin() {
        if (window.lampa_transcoding_initialized) {
            log('Already initialized');
            return;
        }
        window.lampa_transcoding_initialized = true;

        log('Initializing...');

        // Subscribe to player events
        Lampa.Player.listener.follow('create', handlePlayerCreate);
        Lampa.Player.listener.follow('destroy', handlePlayerDestroy);
        Lampa.Player.listener.follow('back', handlePlayerBack);

        if (Lampa.PlayerVideo && Lampa.PlayerVideo.listener) {
            Lampa.PlayerVideo.listener.follow('loadeddata', handleVideoLoadedData);
            Lampa.PlayerVideo.listener.follow('canplay', handleVideoLoadedData);
            Lampa.PlayerVideo.listener.follow('pause', handleVideoPause);
            Lampa.PlayerVideo.listener.follow('play', handleVideoPlay);
        }

        // Also handle page navigation to stop transcoding
        Lampa.Listener.follow('activity', function (e) {
            if (e.type === 'start' || e.type === 'destroy') {
                // If we leave player, stop transcoding
                if (activeJob) {
                    log('Activity change, stopping transcoding');
                    ensureJobStopped(true);
                }
            }
        });

        log('Initialized successfully');
    }

    // Start when Lampa is ready
    if (window.Lampa && Lampa.Platform) {
        initPlugin();
    } else {
        var checkInterval = setInterval(function () {
            if (window.Lampa && Lampa.Platform) {
                clearInterval(checkInterval);
                initPlugin();
            }
        }, 100);

        // Timeout after 10 seconds
        setTimeout(function () {
            clearInterval(checkInterval);
        }, 10000);
    }

})();
