(function () {
    'use strict';

    var plugin_name = 'downloads';
    var plugin_version = '1.0.0';

    if (window.plugin_downloads_initialized) return;
    window.plugin_downloads_initialized = true;

    console.log('[Plugin]', plugin_name, 'v' + plugin_version, 'initialized');

    var network = new Lampa.Reguest();

    // =========================================================================
    // 1. API & Network
    // =========================================================================

    function getAuthHeaders() {
        var account = Lampa.Storage.get('account', {}) || {};
        var profile = Lampa.Storage.get('profile', {}) || {};
        return {
            'token': account.token || '',
            'profile': profile.id || ''
        };
    }

    function fetchLibraryList(onSuccess, onError) {
        var url = Lampa.Storage.get('server_url', '') + '/api/library/list?t=' + Date.now();
        network.silent(url, onSuccess, onError, false, {
            headers: getAuthHeaders()
        });
    }

    function deleteLibraryItem(id, callback) {
        var url = Lampa.Storage.get('server_url', '') + '/api/library/remove?id=' + id;
        network.silent(url, function (data) {
            if (data && data.success) {
                Lampa.Noty.show('Удалено из загрузок');
                if (callback) callback();
            } else {
                Lampa.Noty.show('Ошибка удаления');
            }
        }, function () {
            Lampa.Noty.show('Ошибка сети');
        }, false, {
            headers: getAuthHeaders(),
            method: 'DELETE'
        });
    }

    function analyzeMediaFile(data, onSuccess, onError) {
        var url = Lampa.Storage.get('server_url', '') + '/api/library/analyze';
        var headers = getAuthHeaders();
        headers['Content-Type'] = 'application/json';

        network.silent(url, onSuccess, onError, JSON.stringify(data), {
            headers: headers,
            method: 'POST'
        });
    }

    function sendDownloadRequest(data, audioIndex, subtitleIndex) {
        if (audioIndex !== null) data.audio_index = audioIndex;
        if (subtitleIndex !== null) data.subtitle_index = subtitleIndex;

        var url = Lampa.Storage.get('server_url', '') + '/api/library/add';
        var headers = getAuthHeaders();
        headers['Content-Type'] = 'application/json';

        network.silent(url, function (res) {
            if (res && res.success) {
                Lampa.Noty.show('Добавлено в очередь загрузки');
            } else {
                Lampa.Noty.show('Ошибка добавления');
            }
        }, function () {
            Lampa.Noty.show('Ошибка сети');
        }, JSON.stringify(data), {
            headers: headers,
            method: 'POST'
        });
    }

    // =========================================================================
    // 2. Helpers
    // =========================================================================

    var TEXT_SUBTITLE_CODECS = [
        'subrip', 'srt', 'ass', 'ssa', 'webvtt', 'vtt',
        'mov_text', 'text', 'ttml', 'stl'
    ];

    var GRAPHICAL_SUBTITLE_CODECS = [
        'hdmv_pgs_subtitle', 'pgs', 'dvd_subtitle', 'dvdsub',
        'dvb_subtitle', 'xsub', 'vobsub'
    ];

    function isTextSubtitle(track) {
        if (!track || !track.codec_name) return false;
        var codec = track.codec_name.toLowerCase();
        if (TEXT_SUBTITLE_CODECS.indexOf(codec) !== -1) return true;
        if (GRAPHICAL_SUBTITLE_CODECS.indexOf(codec) !== -1) return false;
        return true;
    }

    function formatAudioItem(track, index) {
        var tags = track.tags || {};
        var title = tags.title || tags.handler_name || ('Дорожка ' + (index + 1));
        var lang = (tags.language || '').toUpperCase();
        var codec = (track.codec_name || '').toUpperCase();

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

    function formatSubtitleItem(track, index) {
        var tags = track.tags || {};
        var title = tags.title || tags.handler_name || ('Субтитры ' + (index + 1));
        var lang = (tags.language || '').toUpperCase();
        var codec = (track.codec_name || '').toUpperCase();

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
    // 3. UI Components
    // =========================================================================

    function addMenuItem() {
        if ($('.menu__text:contains("Загрузки")').length) return;

        var svg = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>';

        Lampa.Menu.addButton(svg, 'Загрузки', function () {
            Lampa.Activity.push({
                url: '',
                title: 'Загрузки',
                component: 'downloads',
                page: 1
            });
        });
    }

    function DownloadsComponent(object) {
        var comp = Lampa.Utils.createInstance(Lampa.Maker.get('Category'), object, {
            module: Lampa.Maker.module('Category').toggle(Lampa.Maker.module('Category').MASK.base, 'Pagination')
        });

        comp.use({
            onCreate: function () {
                var _this = this;

                fetchLibraryList(function (data) {
                    if (data && data.success && data.items) {
                        var items = data.items.map(function (item) {
                            var card = {
                                id: item.tmdb_id,
                                title: item.title,
                                name: item.title,
                                type: item.type,
                                media_type: item.type,
                                library_id: item.id,
                                library_status: item.status,
                                library_progress: item.progress,
                                library_error: item.error_message,
                                subtitle_index: item.subtitle_index,
                                original_title: item.title,
                                original_name: item.title,
                                release_date: '2025',
                                first_air_date: '2025',
                                vote_average: 0
                            };

                            if (item.poster && item.poster.indexOf('/') === 0) {
                                card.poster_path = item.poster;
                                card.backdrop_path = item.poster;
                            } else if (item.poster) {
                                card.img = item.poster;
                            } else {
                                card.img = 'https://via.placeholder.com/300x450/333333/ffffff?text=' + encodeURIComponent(item.title.substring(0, 20));
                            }

                            if (item.type === 'tv') {
                                card.title = item.title + ' (S' + (item.season || 1) + 'E' + (item.episode || 1) + ')';
                                card.name = card.title;
                            }

                            return card;
                        });

                        if (items.length > 0) {
                            _this.build({
                                results: items,
                                page: 1,
                                total_pages: 1,
                                total_results: items.length
                            });
                        } else {
                            _this.empty();
                        }
                    } else {
                        _this.empty();
                    }
                }, function () {
                    _this.empty();
                });
            },
            onInstance: function (item, data) {
                item.use({
                    onCreate: function () {
                        var statusText = '';
                        var statusClass = '';

                        if (data.library_status === 'pending') {
                            statusText = data.library_progress > 0 ? 'В очереди ' + Math.round(data.library_progress) + '%' : 'В очереди';
                            statusClass = 'status-pending';
                        } else if (data.library_status === 'downloading') {
                            statusText = 'Загрузка (HLS) ' + Math.round(data.library_progress) + '%';
                            statusClass = 'status-downloading';
                        } else if (data.library_status === 'transcoding') {
                            statusText = 'Конвертация ' + Math.round(data.library_progress) + '%';
                            statusClass = 'status-transcoding';
                        } else if (data.library_status === 'ready') {
                            statusText = 'Готово';
                            statusClass = 'status-ready';
                        } else if (data.library_status === 'error') {
                            statusText = 'Ошибка';
                            statusClass = 'status-error';
                        }

                        if (statusText) {
                            var statusHtml = $('<div class="library-status ' + statusClass + '" style="position:absolute;top:5px;right:5px;background:rgba(0,0,0,0.8);padding:4px 8px;border-radius:5px;font-size:12px;font-weight:bold;z-index:10;color:#fff;">' + statusText + '</div>');

                            var cardEl = this.html || $(this.card);
                            var viewEl = cardEl.find('.card__view');

                            if (viewEl.length) {
                                viewEl.append(statusHtml);
                            } else {
                                cardEl.append(statusHtml);
                            }

                            if (data.library_status !== 'ready' && data.library_status !== 'error') {
                                var updateTimer = setInterval(function () {
                                    var active = Lampa.Activity.active();
                                    if (!active || active.component !== 'downloads') {
                                        clearInterval(updateTimer);
                                        return;
                                    }

                                    fetchLibraryList(function (res) {
                                        if (res && res.success && res.items) {
                                            var updatedItem = res.items.find(function (i) { return i.id === data.library_id; });
                                            if (updatedItem) {
                                                var newText = '';
                                                if (updatedItem.status === 'pending') {
                                                    newText = updatedItem.progress > 0 ? 'В очереди ' + Math.round(updatedItem.progress) + '%' : 'В очереди';
                                                } else if (updatedItem.status === 'downloading') {
                                                    newText = 'Загрузка (HLS) ' + Math.round(updatedItem.progress) + '%';
                                                } else if (updatedItem.status === 'transcoding') {
                                                    newText = 'Конвертация ' + Math.round(updatedItem.progress) + '%';
                                                } else if (updatedItem.status === 'ready') {
                                                    newText = 'Готово';
                                                    clearInterval(updateTimer);
                                                } else if (updatedItem.status === 'error') {
                                                    newText = 'Ошибка';
                                                    clearInterval(updateTimer);
                                                }

                                                if (newText) {
                                                    statusHtml.text(newText);
                                                    data.library_status = updatedItem.status;
                                                    data.library_progress = updatedItem.progress;
                                                }
                                            } else {
                                                clearInterval(updateTimer);
                                            }
                                        }
                                    }, function () { });
                                }, 3000);
                            }
                        }
                    },
                    onEnter: function () {
                        if (data.library_status === 'ready') {
                            var playUrl = Lampa.Storage.get('server_url', '') + '/api/library/play/' + data.library_id + '/playlist.m3u8';
                            var video = { title: data.title, url: playUrl };

                            if (data.subtitle_index !== null && data.subtitle_index !== undefined) {
                                var subUrl = Lampa.Storage.get('server_url', '') + '/api/library/play/' + data.library_id + '/subtitles.vtt';
                                video.subtitles = [{ label: 'Встроенные', url: subUrl, index: 0 }];
                            }

                            Lampa.Player.play(video);
                            Lampa.Player.playlist([video]);
                        } else {
                            Lampa.Select.show({
                                title: 'Действия',
                                items: [
                                    { title: 'Открыть карточку', action: 'open' },
                                    { title: 'Удалить из загрузок', action: 'delete' }
                                ],
                                onSelect: function (a) {
                                    Lampa.Select.close();
                                    Lampa.Controller.toggle('content');
                                    if (a.action === 'delete') {
                                        deleteLibraryItem(data.library_id, function () {
                                            Lampa.Activity.replace();
                                        });
                                    } else if (a.action === 'open') {
                                        Lampa.Activity.push({
                                            url: '',
                                            component: 'full',
                                            id: data.id,
                                            method: data.type,
                                            card: data
                                        });
                                    }
                                },
                                onBack: function () {
                                    Lampa.Controller.toggle('content');
                                }
                            });
                        }
                    },
                    onMenu: function (info) {
                        if (info && info.length !== undefined) {
                            info.length = 0;
                        }

                        var menu = [
                            { title: 'Открыть карточку', action: 'open' },
                            { title: 'Удалить из загрузок', action: 'delete' }
                        ];

                        if (data.library_status === 'ready') {
                            menu.unshift({ title: 'Смотреть', action: 'play' });
                        }

                        menu.forEach(function (m) {
                            m.onSelect = function () {
                                if (m.action === 'delete') {
                                    deleteLibraryItem(data.library_id, function () {
                                        Lampa.Activity.replace();
                                    });
                                } else if (m.action === 'play') {
                                    var playUrl = Lampa.Storage.get('server_url', '') + '/api/library/play/' + data.library_id + '/playlist.m3u8';
                                    var video = { title: data.title, url: playUrl };
                                    if (data.subtitle_index !== null && data.subtitle_index !== undefined) {
                                        var subUrl = Lampa.Storage.get('server_url', '') + '/api/library/play/' + data.library_id + '/subtitles.vtt';
                                        video.subtitles = [{ label: 'Встроенные', url: subUrl, index: 0 }];
                                    }
                                    Lampa.Player.play(video);
                                    Lampa.Player.playlist([video]);
                                } else if (m.action === 'open') {
                                    Lampa.Activity.push({
                                        url: '',
                                        component: 'full',
                                        id: data.id,
                                        method: data.type,
                                        card: data
                                    });
                                }
                            };
                        });

                        if (info && info.push) {
                            menu.forEach(function (m) { info.push(m); });
                        }
                    },
                    onFocus: function () {
                        Lampa.Background.change(Lampa.Utils.cardImgBackground(data));
                    }
                });
            }
        });

        return comp;
    }

    function startDownloadProcess(data, initialController) {
        Lampa.Loading.start(function () { }, 'Анализ медиафайла...');

        analyzeMediaFile(data, function (info) {
            Lampa.Loading.stop();

            var streams = (info && Array.isArray(info.streams)) ? info.streams : [];
            var audioTracks = streams.filter(function (s) { return s.codec_type === 'audio'; });
            var subtitleTracks = streams.filter(function (s) { return s.codec_type === 'subtitle'; });

            if (audioTracks.length === 0) {
                Lampa.Noty.show('Аудиодорожки не найдены');
                if (initialController) Lampa.Controller.toggle(initialController);
                return;
            }

            if (audioTracks.length === 1 && subtitleTracks.length === 0) {
                sendDownloadRequest(data, audioTracks[0].index, null);
                if (initialController) Lampa.Controller.toggle(initialController);
            } else {
                showAudioSelector(data, audioTracks, subtitleTracks, initialController);
            }
        }, function () {
            Lampa.Loading.stop();
            Lampa.Noty.show('Ошибка анализа файла');
            if (initialController) Lampa.Controller.toggle(initialController);
        });
    }

    function showAudioSelector(data, audioTracks, subtitleTracks, initialController) {
        var items = audioTracks.map(function (track, index) { return formatAudioItem(track, index); });
        var lastController = initialController || Lampa.Controller.enabled().name;
        if (lastController === 'select') {
            lastController = 'torrent_file';
        }

        Lampa.Select.show({
            title: 'Выберите аудиодорожку',
            items: items,
            onSelect: function (item) {
                if (!item || item.track === undefined) {
                    Lampa.Noty.show('Не выбрана дорожка');
                    Lampa.Controller.toggle(lastController);
                    return;
                }

                if (subtitleTracks && subtitleTracks.length > 0) {
                    // Важно: передаем lastController дальше, чтобы субтитры знали, куда возвращаться
                    showSubtitleSelector(data, item.track.index, subtitleTracks, lastController);
                } else {
                    sendDownloadRequest(data, item.track.index, null);
                    Lampa.Controller.toggle(lastController);
                }
            },
            onBack: function () {
                Lampa.Controller.toggle(lastController);
            }
        });
    }

    function showSubtitleSelector(data, audioIndex, subtitleTracks, lastController) {
        var textSubs = subtitleTracks.filter(function (track) { return isTextSubtitle(track); });

        if (textSubs.length === 0) {
            var hasGraphical = subtitleTracks.some(function (track) { return !isTextSubtitle(track); });
            if (hasGraphical) {
                Lampa.Noty.show('Только графические субтитры (PGS/VOBSUB) - не поддерживаются', 4000);
            }
            sendDownloadRequest(data, audioIndex, null);
            Lampa.Controller.toggle(lastController);
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

        // Небольшая задержка перед открытием второго меню, чтобы первое успело закрыться
        setTimeout(function() {
            Lampa.Select.show({
                title: 'Выберите субтитры',
                items: items,
                onSelect: function (item) {
                    sendDownloadRequest(data, audioIndex, item.index !== -1 ? item.track.index : null);
                    Lampa.Controller.toggle(lastController);
                },
                onBack: function () {
                    Lampa.Controller.toggle(lastController);
                }
            });
        }, 10);
    }

    // =========================================================================
    // 4. Listeners
    // =========================================================================

    function setupTorrentFileListener() {
        Lampa.Listener.follow('torrent_file', function (e) {
            if (e.type === 'onlong') {
                if (e.menu.filter(function (m) { return m.title === 'Скачать на сервер'; }).length > 0) return;

                e.menu.push({
                    title: 'Скачать на сервер',
                    onSelect: function () {
                        var active = Lampa.Activity.active() || {};
                        var activity = active.activity || {};
                        var movie = (e.params && e.params.movie) ? e.params.movie : (activity.movie || active.movie || {});
                        var file = e.element || {};

                        var data = {
                            tmdb_id: movie.id || 0,
                            type: movie.name ? 'tv' : 'movie',
                            title: movie.title || movie.name || file.title || file.name || file.Title || 'Unknown',
                            poster: movie.poster_path || movie.img || movie.poster || file.poster || file.img || '',
                            magnet_uri: file.MagnetUri || file.link || file.url || file.magnet || (e.params ? e.params.magnet : ''),
                            season: file.season || 0,
                            episode: file.episode || 0,
                            file_index: file.index !== undefined ? file.index : (file.id !== undefined ? file.id : (file.file_index !== undefined ? file.file_index : null))
                        };

                        if (data.magnet_uri && data.magnet_uri.indexOf('link=') !== -1) {
                            var match = data.magnet_uri.match(/link=([^&]+)/);
                            if (match && match[1]) {
                                data.magnet_uri = decodeURIComponent(match[1]);
                            }
                        }

                        if (!data.magnet_uri) {
                            Lampa.Noty.show('Не удалось получить ссылку на торрент');
                            return;
                        }

                        var lastController = Lampa.Controller.enabled().name;
                        if (lastController === 'select') lastController = 'torrent_file';
                        startDownloadProcess(data, lastController);
                    }
                });
            }
        });
    }

    // =========================================================================
    // 5. Initialization
    // =========================================================================

    Lampa.Component.add('downloads', DownloadsComponent);
    setupTorrentFileListener();

    function init() {
        addMenuItem();
    }

    if (window.appready) {
        init();
    } else {
        Lampa.Listener.follow('app', function (e) {
            if (e.type === 'ready') {
                init();
            }
        });
    }

})();