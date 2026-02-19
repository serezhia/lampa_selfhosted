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

    // Text-based subtitle codecs that FFmpeg can convert to WebVTT
    var TEXT_SUBTITLE_CODECS = [
        'subrip', 'srt', 'ass', 'ssa', 'webvtt', 'vtt',
        'mov_text', 'text', 'ttml', 'stl'
    ];

    // Graphical subtitle codecs that CANNOT be converted to WebVTT
    var GRAPHICAL_SUBTITLE_CODECS = [
        'hdmv_pgs_subtitle', 'pgs', 'dvd_subtitle', 'dvdsub',
        'dvb_subtitle', 'xsub', 'vobsub'
    ];

    function isTextSubtitle(track) {
        if (!track || !track.codec_name) return false;
        var codec = track.codec_name.toLowerCase();
        // Allow if it's in text list or NOT in graphical list
        if (TEXT_SUBTITLE_CODECS.indexOf(codec) !== -1) return true;
        if (GRAPHICAL_SUBTITLE_CODECS.indexOf(codec) !== -1) return false;
        // Unknown codec - assume it might be text-based
        return true;
    }

    function formatSubtitleItem(track, index) {
        var tags = track.tags || {};
        var title = tags.title || tags.handler_name || ('Субтитры ' + (index + 1));
        var lang = (tags.language || '').toUpperCase();
        var codec = (track.codec_name || '').toUpperCase();

        // Mark graphical subs
        var isGraphical = !isTextSubtitle(track);

        var subtitleParts = [];
        if (lang) subtitleParts.push(lang);
        if (codec) subtitleParts.push(codec);
        if (isGraphical) subtitleParts.push('(графические)');

        return {
            title: title,
            subtitle: subtitleParts.join(' • '),
            track: track,
            index: index,
            isGraphical: isGraphical
        };
    }

    // =========================================================================
    // Track Selection UI
    // =========================================================================

    function showAudioSelector(data, audioTracks, subtitleTracks) {
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
                    showSubtitleSelector(data, item.track, subtitleTracks);
                } else {
                    startTranscoding(data, item.track, null);
                }
            },
            onBack: function () {
                Lampa.Controller.toggle(lastController);
            }
        });
    }

    function showSubtitleSelector(data, audioTrack, subtitleTracks) {
        // Filter to only show text-based subtitles
        var textSubs = subtitleTracks.filter(function (track) {
            return isTextSubtitle(track);
        });

        // If no text subtitles available
        if (textSubs.length === 0) {
            var hasGraphical = subtitleTracks.some(function (track) {
                return !isTextSubtitle(track);
            });
            if (hasGraphical) {
                notify('Только графические субтитры (PGS/VOBSUB) - не поддерживаются', 4000);
            }
            startTranscoding(data, audioTrack, null);
            return;
        }

        var items = [{
            title: 'Без субтитров',
            subtitle: '',
            track: null,
            index: -1
        }];

        textSubs.forEach(function (track, index) {
            items.push(formatSubtitleItem(track, index));
        });

        var lastController = Lampa.Controller.enabled().name;

        Lampa.Select.show({
            title: 'Выберите субтитры',
            items: items,
            onSelect: function (item) {
                Lampa.Select.close();
                startTranscoding(data, audioTrack, item.track);
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

    // Note: Duration is dynamic for live HLS, we don't try to fix it

    function startTranscoding(data, audioTrack, subtitleTrack) {
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
                    playlistUrl: response.playlistUrl
                };

                // Start heartbeat
                startHeartbeat();

                // Play the HLS stream
                var playback = Object.assign({}, data);
                playback.transcoding = true;
                playback.url = addAuthToUrl(response.playlistUrl);

                // Add subtitles if returned
                if (response.subtitlesUrl) {
                    playback.subtitles = playback.subtitles || [];
                    playback.subtitles.push({
                        label: 'Встроенные',
                        url: addAuthToUrl(response.subtitlesUrl),
                        index: 0
                    });
                    log('Subtitles added:', response.subtitlesUrl);
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
                startTranscoding(data, audioTracks[0], null);
            } else {
                showAudioSelector(data, audioTracks, subtitleTracks);
            }
        }, function (error) {
            hideWait();
            notify('Ошибка анализа файла');
            log('FFprobe error:', error);
        });
    }

    function handlePlayerDestroy() {
        log('Player destroy event');
        ensureJobStopped(true);
    }

    function handlePlayerBack() {
        log('Player back event');
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
