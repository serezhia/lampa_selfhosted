(function () {
    'use strict';

    var CONFIG = {
        pluginName: 'sync_player',
        storage: {
            enabled: 'sync_player_enabled',
            autoConnect: 'sync_player_auto_connect',
            room: 'sync_player_room',
            isHost: 'sync_player_is_host',
            threshold: 'sync_player_threshold'
        },
        defaultThreshold: 2,
        syncIntervalMs: 1000,
        minSyncIntervalMs: 500,
        iconSvg: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none">' +
            '<path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z" fill="currentColor"/></svg>'
    };

    var state = {
        roomId: '',
        isHost: false,
        isConnected: false,
        isPublic: true, // Тип комнаты: публичная или приватная
        closing: false,
        video: null,
        videoHandlers: null,
        syncTimer: null,
        lastSyncSentAt: 0,
        lastRemoteUpdateAt: 0,
        syncThreshold: CONFIG.defaultThreshold,
        pendingMedia: null,
        awaitingPrompt: false,
        lastMediaSignature: null,
        lastMediaOfferSentAt: 0,
        isRemoteUpdate: false,
        remoteUpdateTimer: null,
        playPauseTimer: null,
        isApplyingOffer: false,
        playerActive: false
    };

    // WebSocket Client Wrapper (using standard WebSocket)
    var wsClient = {
        socket: null,
        messageHandler: null,

        connect: function (callback) {
            if (this.socket && this.socket.readyState === WebSocket.OPEN) {
                if (callback) callback();
                return;
            }

            var protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            var host = window.location.host;
            var uid = getUid();
            var url = protocol + '//' + host + '/syncplayer/ws?uid=' + encodeURIComponent(uid);

            this.socket = new WebSocket(url);

            var self = this;
            this.socket.onopen = function () {
                log('WebSocket connected');
                if (callback) callback();
            };

            this.socket.onmessage = function (event) {
                try {
                    var data = JSON.parse(event.data);
                    log('WS Recv:', data);
                    if (self.messageHandler) {
                        self.messageHandler(data);
                    }
                } catch (e) {
                    warn('Failed to parse message', e);
                }
            };

            this.socket.onclose = function (event) {
                log('WebSocket closed', event.code, event.reason);
                state.isConnected = false;
                updateHeaderState();
            };

            this.socket.onerror = function (error) {
                warn('WebSocket error', error);
            };
        },

        send: function (action, data) {
            if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
                // Try to connect first
                var self = this;
                this.connect(function () {
                    self.send(action, data);
                });
                return false;
            }

            // Flatten the payload as expected by the new backend
            var payload = {
                action: action,
                room_id: state.roomId,
                user_id: getUid()
            };

            // Merge data properties into payload
            if (data) {
                for (var key in data) {
                    if (Object.prototype.hasOwnProperty.call(data, key)) {
                        payload[key] = data[key];
                    }
                }
            }

            this.socket.send(JSON.stringify(payload));
            log('WS Send:', action, payload);
            return true;
        },

        onMessage: function (callback) {
            this.messageHandler = callback;
        },

        close: function () {
            if (this.socket) {
                this.socket.close();
                this.socket = null;
            }
        }
    };

    function log() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[SyncPlayer]');
        console.log.apply(console, args);
    }

    function warn() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[SyncPlayer-WARN]');
        console.warn.apply(console, args);
    }

    function notify(text) {
        if (!text) return;
        try {
            Lampa.Noty.show(text);
        } catch (err) {
            warn('Notification failed', err, text);
        }
    }

    function getBoolean(key, fallback) {
        var value = Lampa.Storage.get(key, fallback);
        if (typeof value === 'boolean') return value;
        if (value === undefined || value === null) return fallback;
        if (typeof value === 'string') {
            return value === 'true' || value === '1';
        }
        return !!value;
    }

    function setBoolean(key, value) {
        Lampa.Storage.set(key, value ? true : false);
    }

    function loadStateFromStorage() {
        state.roomId = '';
        state.isHost = false;
        var threshold = parseFloat(Lampa.Storage.get(CONFIG.storage.threshold, CONFIG.defaultThreshold));
        state.syncThreshold = isNaN(threshold) ? CONFIG.defaultThreshold : Math.max(0.1, threshold);
        updateHeaderState();
    }

    function resetAllState() {
        log('Resetting all plugin state');
        state.roomId = '';
        state.isHost = false;
        state.isConnected = false;
        state.closing = false;
        state.video = null;
        state.videoHandlers = null;
        state.syncTimer = null;
        state.lastSyncSentAt = 0;
        state.lastRemoteUpdateAt = 0;
        state.pendingMedia = null;
        state.awaitingPrompt = false;
        state.lastMediaSignature = null;
        state.isRemoteUpdate = false;
        state.remoteUpdateTimer = null;
        state.playPauseTimer = null;
        state.isApplyingOffer = false;
        state.playerActive = false;
    }

    function persistRoomState() {
        // Do not persist room state to storage to ensure auto-logout on reload
        Lampa.Storage.set(CONFIG.storage.room, '');
        Lampa.Storage.set(CONFIG.storage.isHost, false);
    }

    function isEnabled() {
        return true;
    }

    function isAutoConnectEnabled() {
        return getBoolean(CONFIG.storage.autoConnect, false);
    }

    function generateRoomId() {
        return (Math.floor(Math.random() * 900000) + 100000).toString();
    }

    function normalizeRoomCode(code) {
        if (code === null || code === undefined) return '';
        if (typeof code === 'number') code = code.toString();
        if (typeof code !== 'string') {
            try {
                code = String(code);
            } catch (err) {
                return '';
            }
        }
        var digits = code.replace(/\D/g, '');
        return digits.length === 6 ? digits : '';
    }

    function getUid() {
        var uid = Lampa.Storage.get('lampac_unic_id', '');
        if (!uid) {
            uid = 'anon_' + Math.random().toString(36).substring(2, 10);
            Lampa.Storage.set('lampac_unic_id', uid);
            log('Generated new uid:', uid);
        }
        return uid;
    }

    function sanitizeForSend(value, seen) {
        if (value === null || value === undefined) return value;
        if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') return value;
        if (typeof value === 'function') return undefined;
        if (typeof value !== 'object') return undefined;

        seen = seen || [];
        if (seen.indexOf(value) !== -1) return undefined;
        seen.push(value);

        if (Array.isArray(value)) {
            var arr = [];
            for (var i = 0; i < value.length; i++) {
                var sanitizedItem = sanitizeForSend(value[i], seen);
                if (sanitizedItem !== undefined) arr.push(sanitizedItem);
            }
            return arr;
        }

        var result = {};
        Object.keys(value).forEach(function (key) {
            var sanitized = sanitizeForSend(value[key], seen);
            if (sanitized !== undefined) {
                result[key] = sanitized;
            }
        });
        return result;
    }

    function buildMediaPayload(sourceData) {
        var mediaData = null;

        // Пытаемся получить данные из Lampa.Player.playdata()
        try {
            var playdata = Lampa.Player.playdata();
            if (playdata && playdata.url) {
                mediaData = sanitizeForSend(playdata);
                log('buildMediaPayload: got data from playdata()', mediaData ? mediaData.url : 'no url');
            }
        } catch (err) {
            log('buildMediaPayload: playdata() failed', err);
        }

        if (!mediaData || !mediaData.url) {
            log('buildMediaPayload: no valid media data');
            return null;
        }

        var playlistData = null;
        try {
            if (window.PlayerPlaylist && typeof window.PlayerPlaylist.get === 'function') {
                playlistData = sanitizeForSend(window.PlayerPlaylist.get());
            }
        } catch (err) {
            playlistData = null;
        }

        log('buildMediaPayload: returning payload with url:', mediaData.url);
        return {
            media: mediaData,
            playlist: playlistData
        };
    }

    function createMediaSignature(media, playlist) {
        try {
            return JSON.stringify({ media: media, playlist: playlist });
        } catch (err) {
            return Date.now().toString();
        }
    }

    function isSocketReady() {
        return wsClient.socket && wsClient.socket.readyState === WebSocket.OPEN;
    }

    function getVideo() {
        return ensureVideoReference();
    }

    function ensureVideoReference() {
        if (!Lampa.Player) return null;

        var element = null;
        if (typeof Lampa.Player.video === 'function') {
            element = Lampa.Player.video();
        }

        // Fallback: try to find video tag in DOM if Lampa.Player.video() returns nothing
        if (!element) {
            element = document.querySelector('video');
        }

        if (!element) return null;

        if (state.video === element) return state.video;

        detachVideoListeners();
        state.video = element;
        state.videoHandlers = {
            onPlay: function () {
                log('Video Event: play (RemoteUpdate: ' + state.isRemoteUpdate + ')');
                if (!state.isRemoteUpdate) {
                    sendPlayPause(true);
                }
            },
            onPause: function () {
                log('Video Event: pause (RemoteUpdate: ' + state.isRemoteUpdate + ')');
                if (!state.isRemoteUpdate) {
                    sendPlayPause(false);
                }
            },
            onSeeking: function () {
                log('Video Event: seeking (RemoteUpdate: ' + state.isRemoteUpdate + ')');
                if (!state.isRemoteUpdate) {
                    sendSyncState(true);
                }
            }
        };

        element.addEventListener('play', state.videoHandlers.onPlay);
        element.addEventListener('pause', state.videoHandlers.onPause);
        element.addEventListener('seeking', state.videoHandlers.onSeeking);

        if (state.isHost && isSocketReady()) {
            sendMediaOffer();
            sendSyncState(true);
        }

        return state.video;
    }

    function detachVideoListeners() {
        if (state.video && state.videoHandlers) {
            try {
                state.video.removeEventListener('play', state.videoHandlers.onPlay);
                state.video.removeEventListener('pause', state.videoHandlers.onPause);
                state.video.removeEventListener('seeking', state.videoHandlers.onSeeking);
            } catch (err) {
                warn('Failed to detach video listeners', err);
            }
        }
        state.video = null;
        state.videoHandlers = null;
    }

    function startHostSyncLoop() {
        if (!state.isHost) return;
        if (state.syncTimer) return;
        state.syncTimer = setInterval(function () {
            sendSyncState(false);
        }, CONFIG.syncIntervalMs);
        log('Host sync loop started');
    }

    function stopHostSyncLoop() {
        if (state.syncTimer) {
            clearInterval(state.syncTimer);
            state.syncTimer = null;
            log('Host sync loop stopped');
        }
    }

    function sendSyncState(force) {
        if (!isSocketReady()) return;
        var now = Date.now();
        if (!force && now - state.lastSyncSentAt < CONFIG.minSyncIntervalMs) return;

        var video = getVideo();
        if (!video) return;

        var payload = {
            time: video.currentTime,
            is_playing: !video.paused
        };

        wsClient.send('sync_state', payload);
        state.lastSyncSentAt = now;
    }

    function sendPlayPause(isPlaying) {
        if (!isSocketReady()) return;

        if (state.playPauseTimer) clearTimeout(state.playPauseTimer);

        state.playPauseTimer = setTimeout(function () {
            var video = getVideo();
            if (!video) return;

            var payload = {
                is_playing: isPlaying,
                time: video.currentTime
            };

            wsClient.send('play_pause', payload);
            state.lastSyncSentAt = Date.now();
        }, 250);
    }

    function sendMediaOffer(sourceData, forceNew) {
        log('sendMediaOffer called, forceNew:', forceNew, 'isHost:', state.isHost);

        if (!state.isHost) {
            log('sendMediaOffer: not host, skipping');
            return;
        }

        if (!isSocketReady()) {
            log('sendMediaOffer: socket not ready');
            return;
        }

        // Throttle - не отправлять чаще чем раз в 2 секунды (если не forceNew)
        var now = Date.now();
        if (!forceNew && state.lastMediaOfferSentAt && (now - state.lastMediaOfferSentAt) < 2000) {
            log('sendMediaOffer: throttled, skipping');
            return;
        }

        var payload = buildMediaPayload(sourceData);
        if (!payload) {
            log('sendMediaOffer: no payload');
            return;
        }

        var signature = createMediaSignature(payload.media, payload.playlist);
        if (!forceNew && signature === state.lastMediaSignature) {
            log('sendMediaOffer: skipping - same signature');
            return;
        }
        state.lastMediaSignature = signature;
        state.lastMediaOfferSentAt = Date.now();

        wsClient.send('media_offer', {
            media: payload.media,
            playlist: payload.playlist,
            timestamp: Date.now()
        });
        log('sendMediaOffer: sent successfully');
    }

    function sendPlayerClosed() {
        if (!isSocketReady()) return;
        if (!state.isHost) return;

        wsClient.send('player_closed', {
            timestamp: Date.now()
        });
        log('Sent player_closed');
    }

    function requestMediaOffer() {
        if (!isSocketReady()) return;
        if (state.isHost) return;

        wsClient.send('request_media', {
            timestamp: Date.now()
        });
        log('Sent request_media');
    }

    function connectWebSocket() {
        if (!state.roomId) {
            warn('Cannot connect without room id');
            return;
        }

        wsClient.connect(function () {
            state.isConnected = true;
            state.closing = false;
            updateHeaderState();

            var action = state.isHost ? 'create_room' : 'join_room';
            wsClient.send(action, {
                // room_id is added automatically by send wrapper
            });

            ensureVideoReference();
            if (state.isHost) {
                startHostSyncLoop();
                sendMediaOffer();
            }
        });

        // Setup listener
        wsClient.onMessage(function (data) {
            handleSocketMessage(data);
        });
    }

    function closeWebSocket(reason) {
        if (state.isConnected) {
            wsClient.send('leave_room', {});
            wsClient.close();
        }
        state.isConnected = false;
        stopHostSyncLoop();
        updateHeaderState();
        if (!state.closing) {
            notify('Совместный просмотр: отключено (' + reason + ')');
        }
    }

    function handleSocketMessage(data) {
        if (!data || !data.action) return;
        log('Handle Message:', data.action, data);

        switch (data.action) {
            case 'room_created':
                if (data.success || data.room_id) {
                    if (data.room_id) {
                        state.roomId = normalizeRoomCode(data.room_id);
                        persistRoomState();
                    }
                    state.isHost = true;
                    updateHeaderState();
                    ensureVideoReference();
                    startHostSyncLoop();
                    sendMediaOffer();
                } else {
                    notify('Совместный просмотр: не удалось создать комнату');
                    updateHeaderState();
                }
                break;

            case 'room_joined':
                if (data.success || data.room_id) {
                    if (data.room_id) {
                        state.roomId = normalizeRoomCode(data.room_id);
                    }
                    state.isHost = false;
                    state.pendingMedia = null;
                    state.awaitingPrompt = false;
                    persistRoomState();
                    notify('Совместный просмотр: подключено к ' + state.roomId);
                    updateHeaderState();
                    ensureVideoReference();
                    // Запрашиваем текущее медиа у хоста
                    setTimeout(function () {
                        requestMediaOffer();
                    }, 500);
                } else {
                    notify('Совместный просмотр: комната не найдена');
                    state.roomId = '';
                    state.isHost = false;
                    persistRoomState();
                    updateHeaderState();
                }
                break;

            case 'sync_state':
                applySyncState(data);
                break;

            case 'play_pause':
                applyPlayPause(data);
                break;

            case 'media_offer':
                log('Received media_offer, isHost:', state.isHost, 'media:', data.media ? 'exists' : 'null');
                if (!state.isHost) {
                    queueMediaOffer(data);
                } else {
                    log('Ignoring media_offer - we are host');
                }
                break;

            case 'user_joined':
                if (state.isHost) {
                    notify('Совместный просмотр: к комнате подключился новый участник');
                    // Отправляем текущее медиа новому участнику
                    if (state.playerActive) {
                        setTimeout(function () {
                            sendMediaOffer(null, true);
                            sendSyncState(true);
                        }, 300);
                    }
                }
                updateHeaderState();
                break;

            case 'user_left':
                if (state.isHost) {
                    notify('Совместный просмотр: участник покинул комнату');
                }
                updateHeaderState();
                break;

            case 'player_closed':
                if (!state.isHost) {
                    log('Host closed player');
                    state.pendingMedia = null;
                    if (state.awaitingPrompt) {
                        state.awaitingPrompt = false;
                        try {
                            Lampa.Modal.close();
                        } catch (e) { }
                    }
                    notify('Совместный просмотр: хост закрыл плеер');
                }
                break;

            case 'request_media':
                if (state.isHost && state.playerActive) {
                    log('Received request_media, sending media_offer');
                    sendMediaOffer(null, true);
                    sendSyncState(true);
                }
                break;
        }
    }

    function applySyncState(data) {
        log('Apply Sync:', data);
        var video = getVideo();
        if (!video) {
            log('Apply Sync: No video element');
            return;
        }

        state.isRemoteUpdate = true;
        try {
            if (typeof data.time === 'number') {
                var timeDiff = Math.abs(video.currentTime - data.time);
                if (timeDiff > state.syncThreshold) {
                    log('Apply Sync: Seeking from', video.currentTime, 'to', data.time);
                    video.currentTime = data.time;
                }
            }

            if (typeof data.is_playing === 'boolean') {
                log('Apply Sync: State paused:', video.paused, 'Target playing:', data.is_playing);
                if (data.is_playing && video.paused) {
                    log('Apply Sync: Calling play()');
                    playSilently(video);
                }
                if (!data.is_playing && !video.paused) {
                    log('Apply Sync: Calling pause()');
                    video.pause();
                }
            }
        } finally {
            setTimeout(function () { state.isRemoteUpdate = false; }, 500);
        }
        state.lastRemoteUpdateAt = Date.now();
    }

    function applyPlayPause(data) {
        log('Apply PlayPause:', data);
        var video = getVideo();
        if (!video) {
            log('Apply PlayPause: No video element');
            return;
        }

        state.isRemoteUpdate = true;
        try {
            if (typeof data.time === 'number') {
                var timeDiff = Math.abs(video.currentTime - data.time);
                if (timeDiff > state.syncThreshold / 2) {
                    log('Apply PlayPause: Seeking from', video.currentTime, 'to', data.time);
                    video.currentTime = data.time;
                }
            }

            if (typeof data.is_playing === 'boolean') {
                log('Apply PlayPause: State paused:', video.paused, 'Target playing:', data.is_playing);
                if (data.is_playing && video.paused) {
                    log('Apply PlayPause: Calling play()');
                    playSilently(video);
                }
                if (!data.is_playing && !video.paused) {
                    log('Apply PlayPause: Calling pause()');
                    video.pause();
                }
            }
        } finally {
            setTimeout(function () { state.isRemoteUpdate = false; }, 500);
        }
        state.lastRemoteUpdateAt = Date.now();
    }

    function playSilently(video) {
        try {
            var playPromise = video.play();
            if (playPromise && typeof playPromise.catch === 'function') {
                playPromise.catch(function (err) {
                    warn('play() rejected', err);
                });
            }
        } catch (err) {
            warn('play() failed', err);
        }
    }

    function queueMediaOffer(data) {
        log('queueMediaOffer called, data:', data);
        log('queueMediaOffer state: playerActive:', state.playerActive, 'awaitingPrompt:', state.awaitingPrompt, 'isHost:', state.isHost);

        // Хост не должен получать свои же офферы
        if (state.isHost) {
            log('queueMediaOffer: ignoring - we are host');
            return;
        }

        // Проверяем только если плеер действительно активен
        if (state.playerActive) {
            try {
                var current = Lampa.Player.playdata();
                if (current && current.url && data.media && data.media.url) {
                    if (current.url === data.media.url) {
                        log('queueMediaOffer: ignoring - already playing this media');
                        return;
                    }
                }
            } catch (e) {
                log('queueMediaOffer: error checking current playdata:', e);
            }
        }

        // Если уже ожидаем подтверждения и пришел новый оффер - обновляем данные
        if (state.awaitingPrompt && state.pendingMedia) {
            log('Updating pending media while prompt is open');
        }

        state.pendingMedia = {
            media: data.media || null,
            playlist: data.playlist || null,
            timestamp: data.timestamp || Date.now()
        };

        log('queueMediaOffer: pendingMedia set, calling promptMediaOffer');

        if (!state.awaitingPrompt) {
            // Отложенный вызов для стабильности контроллера
            setTimeout(function () {
                promptMediaOffer();
            }, 100);
        } else {
            log('queueMediaOffer: already awaiting prompt, not showing again');
        }
    }

    function promptMediaOffer() {
        log('promptMediaOffer called, pendingMedia:', state.pendingMedia ? 'exists' : 'null', 'awaitingPrompt:', state.awaitingPrompt);

        if (!state.pendingMedia) {
            log('promptMediaOffer: no pending media, returning');
            return;
        }
        if (state.awaitingPrompt) {
            log('promptMediaOffer: already awaiting, returning');
            return;
        }

        state.awaitingPrompt = true;
        log('promptMediaOffer: showing modal');

        var title = state.pendingMedia.media && state.pendingMedia.media.title ? String(state.pendingMedia.media.title) : '';
        var content = $('<div class="about"></div>');
        content.append($('<div></div>').text('Хост приглашает вас к просмотру'));
        if (title) {
            content.append($('<div style="margin-top:0.6em;font-weight:bold;"></div>').text(title));
        }

        try {
            Lampa.Modal.open({
                title: 'Совместный просмотр',
                html: content,
                buttons: [
                    {
                        name: 'Нет',
                        onSelect: function () {
                            log('promptMediaOffer: user declined');
                            declineMediaOffer();
                        }
                    },
                    {
                        name: 'Да',
                        onSelect: function () {
                            log('promptMediaOffer: user accepted');
                            acceptMediaOffer();
                        }
                    }
                ],
                onBack: function () {
                    log('promptMediaOffer: user pressed back');
                    declineMediaOffer();
                }
            });
            log('promptMediaOffer: Lampa.Modal.open called successfully');
        } catch (err) {
            warn('Failed to show media offer modal', err);
            state.awaitingPrompt = false;
        }
    }

    function acceptMediaOffer() {
        log('acceptMediaOffer called');
        state.awaitingPrompt = false;

        try {
            Lampa.Modal.close();
        } catch (e) { }

        var payload = state.pendingMedia;
        state.pendingMedia = null;

        log('acceptMediaOffer payload:', payload);

        if (!payload || !payload.media) {
            warn('acceptMediaOffer: no payload or media');
            return;
        }

        log('acceptMediaOffer media url:', payload.media.url);
        log('acceptMediaOffer media title:', payload.media.title);

        try {
            if (payload.playlist && typeof Lampa.Player.playlist === 'function') {
                log('acceptMediaOffer: applying playlist');
                Lampa.Player.playlist(payload.playlist);
            }
        } catch (err) {
            warn('Failed to apply playlist', err);
        }

        try {
            state.isApplyingOffer = true;
            log('acceptMediaOffer: calling Lampa.Player.play');
            Lampa.Player.play(payload.media);
            log('acceptMediaOffer: Lampa.Player.play called');
            notify('Совместный просмотр: воспроизведение запущено');
        } catch (err) {
            warn('Failed to start playback', err);
            notify('Совместный просмотр: не удалось запустить видео');
        } finally {
            setTimeout(function () { state.isApplyingOffer = false; }, 2000);
        }
    }

    function declineMediaOffer() {
        state.awaitingPrompt = false;

        try {
            Lampa.Modal.close();
        } catch (e) { }

        state.pendingMedia = null;
        notify('Совместный просмотр: вы покинули комнату');
        leaveRoom(true);
    }

    function updateHeaderState() {
        var btn = $('.open--sync-player');
        if (state.isConnected) {
            btn.find('svg').css('color', '#82ff98');
        } else {
            btn.find('svg').css('color', 'currentColor');
        }
    }

    function showSyncMenu() {
        var items = [];

        var status = state.isConnected ? 'Подключено' : 'Не подключено';
        if (state.roomId) status += ' (Комната ' + state.roomId + ')';

        items.push({
            title: 'Статус',
            subtitle: status
        });

        if (!state.roomId) {
            items.push({
                title: 'Создать комнату',
                action: createRoomFlow
            });
            items.push({
                title: 'Присоединиться',
                subtitle: 'Ввести код',
                action: promptJoinRoom
            });
            items.push({
                title: 'Открытые комнаты',
                subtitle: 'Список публичных комнат',
                action: showOpenRooms
            });
        } else {
            // Показываем тип комнаты только для хоста
            if (state.isHost) {
                items.push({
                    title: 'Тип комнаты',
                    subtitle: state.isPublic ? 'Публичная' : 'Приватная',
                    action: toggleRoomVisibility
                });
            }
            items.push({
                title: 'Отключиться',
                subtitle: 'Покинуть комнату',
                action: function () {
                    leaveRoom(true);
                }
            });
        }

        items.push({
            title: 'Порог синхронизации',
            subtitle: state.syncThreshold + ' с',
            action: function () {
                showThresholdSelect();
            }
        });

        items.push({
            title: 'Автоподключение',
            subtitle: isAutoConnectEnabled() ? 'Включено' : 'Выключено',
            action: function () {
                var newVal = !isAutoConnectEnabled();
                setBoolean(CONFIG.storage.autoConnect, newVal);
                notify('Совместный просмотр: автоподключение ' + (newVal ? 'включено' : 'выключено'));
                showSyncMenu();
            }
        });


        items.push({
            title: 'Версия',
            subtitle: '0.0.5'
        });

        Lampa.Select.show({
            title: 'Совместный просмотр',
            items: items,
            onSelect: function (item) {
                if (item.action) item.action();
            },
            onBack: function () {
                Lampa.Controller.toggle('content');
            }
        });
    }

    function showThresholdSelect() {
        var values = [0.5, 1, 1.5, 2, 3, 5];
        var items = values.map(function (v) {
            return {
                title: v + ' с',
                selected: state.syncThreshold === v,
                action: function () {
                    state.syncThreshold = v;
                    Lampa.Storage.set(CONFIG.storage.threshold, state.syncThreshold);
                    showSyncMenu();
                }
            };
        });

        Lampa.Select.show({
            title: 'Порог синхронизации',
            items: items,
            onSelect: function (item) {
                if (item.action) item.action();
            },
            onBack: function () {
                showSyncMenu();
            }
        });
    }

    function initHeaderButton() {
        if ($('.open--sync-player').length) return;

        var button = $('<div class="head__action selector open--sync-player">' + CONFIG.iconSvg + '</div>');

        button.on('hover:enter', function () {
            showSyncMenu();
        });

        $('.head__actions .open--settings').before(button);
        updateHeaderState();
    }

    function checkUrlParams() {
        try {
            var params = new URLSearchParams(window.location.search);
            var code = params.get('sync_room');
            if (!code) return;

            Lampa.Select.show({
                title: 'Приглашение к просмотру',
                items: [{
                    title: 'Присоединиться к комнате ' + code,
                    selected: true,
                    action: function () {
                        joinRoomFlow(code);
                        Lampa.Controller.toggle('content');
                        clearSyncQueryParam();
                    }
                }, {
                    title: 'Игнорировать',
                    action: function () {
                        clearSyncQueryParam();
                        Lampa.Controller.toggle('content');
                    }
                }],
                onSelect: function (item) {
                    if (item && item.action) item.action();
                },
                onBack: function () {
                    Lampa.Controller.toggle('content');
                }
            });
        } catch (err) {
            warn('checkUrlParams failed', err);
        }
    }

    function clearSyncQueryParam() {
        try {
            var url = window.location.pathname + window.location.hash;
            window.history.replaceState({}, document.title, url);
        } catch (err) {
            warn('Failed to clear query param', err);
        }
    }

    function maybeAutoConnect() {
        if (!isEnabled()) return;
        if (!isAutoConnectEnabled()) return;
        if (!state.roomId) return;
        connectWebSocket();
    }

    function createRoomFlow() {
        // Делаем запрос на сервер для создания комнаты
        var uid = getUid();
        var url = window.location.origin + '/syncplayer/create?uid=' + encodeURIComponent(uid);
        log('createRoomFlow: starting, uid=' + uid + ', url=' + url);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.withCredentials = true;
        xhr.timeout = 10000;

        xhr.onreadystatechange = function () {
            log('createRoomFlow: readyState=' + xhr.readyState + ', status=' + xhr.status);
            if (xhr.readyState === 4) {
                log('createRoomFlow: responseText=' + xhr.responseText);
                log('createRoomFlow: responseHeaders=' + xhr.getAllResponseHeaders());
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        log('createRoomFlow: parsed response=', response);
                        // Support both camelCase and snake_case for broader compatibility
                        var roomId = response.roomId || response.room_id;
                        var isPublic = response.isPublic !== undefined ? response.isPublic : response.is_public;

                        if (response.success && roomId) {
                            // Сбрасываем все состояние
                            state.pendingMedia = null;
                            state.awaitingPrompt = false;
                            state.lastMediaSignature = null;
                            state.isApplyingOffer = false;
                            state.closing = false;

                            state.roomId = roomId;
                            state.isHost = true;
                            state.isPublic = isPublic !== false;
                            persistRoomState();
                            connectWebSocket();
                            updateHeaderState();
                            notify('Комната ' + state.roomId + ' создана');
                            Lampa.Controller.toggle('content');
                        } else {
                            log('createRoomFlow: response missing success or roomId (received:', JSON.stringify(response), ')');
                            notify('Ошибка: ' + (response.error || 'Не удалось создать комнату'));
                            Lampa.Controller.toggle('content');
                        }
                    } catch (e) {
                        warn('Failed to parse create response:', e, 'responseText:', xhr.responseText);
                        notify('Ошибка создания комнаты');
                        Lampa.Controller.toggle('content');
                    }
                } else {
                    log('createRoomFlow: non-200 status=' + xhr.status);
                    notify('Ошибка создания комнаты (статус: ' + xhr.status + ')');
                    Lampa.Controller.toggle('content');
                }
            }
        };

        xhr.onerror = function () {
            log('createRoomFlow: onerror triggered');
            notify('Ошибка соединения');
            Lampa.Controller.toggle('content');
        };

        xhr.ontimeout = function () {
            log('createRoomFlow: timeout triggered');
            notify('Таймаут соединения');
            Lampa.Controller.toggle('content');
        };

        log('createRoomFlow: sending request');
        xhr.send();
    }

    function showOpenRooms() {
        // Запрашиваем список публичных комнат
        var uid = getUid();
        var xhr = new XMLHttpRequest();
        xhr.open('GET', window.location.origin + '/syncplayer/rooms?uid=' + encodeURIComponent(uid), true);
        xhr.withCredentials = true;
        xhr.timeout = 5000;

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        // Support legacy array response or new object response with rooms property
                        var rooms = Array.isArray(response) ? response : (response.rooms || []);
                        showRoomsListDialog(rooms);
                    } catch (e) {
                        log('Failed to parse rooms list:', e);
                        notify('Ошибка загрузки списка комнат');
                        Lampa.Controller.toggle('content');
                    }
                } else {
                    notify('Ошибка загрузки списка комнат');
                    Lampa.Controller.toggle('content');
                }
            }
        };

        xhr.onerror = function () {
            notify('Ошибка соединения');
            Lampa.Controller.toggle('content');
        };

        xhr.ontimeout = function () {
            notify('Таймаут соединения');
            Lampa.Controller.toggle('content');
        };

        xhr.send();
    }

    function showRoomsListDialog(rooms) {
        var items = [];

        if (rooms.length === 0) {
            items.push({
                title: 'Нет открытых комнат',
                subtitle: 'Создайте свою или введите код'
            });
        } else {
            rooms.forEach(function (room) {
                var roomId = room.id || room.room_id || room.roomId;
                var mediaTitle = room.mediaTitle || room.media_title;
                var members = room.member_count || room.members || 0;

                var subtitle = members + ' ' + pluralize(members, 'участник', 'участника', 'участников');
                if (mediaTitle) {
                    subtitle += ' • ' + mediaTitle;
                }
                items.push({
                    title: 'Комната ' + roomId,
                    subtitle: subtitle,
                    roomId: roomId
                });
            });
        }

        Lampa.Select.show({
            title: 'Открытые комнаты',
            items: items,
            onSelect: function (item) {
                if (item.roomId) {
                    joinRoomFlow(item.roomId);
                }
            },
            onBack: function () {
                showSyncMenu();
            }
        });
    }

    function pluralize(n, one, few, many) {
        var mod10 = n % 10;
        var mod100 = n % 100;
        if (mod10 === 1 && mod100 !== 11) return one;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return few;
        return many;
    }

    function toggleRoomVisibility() {
        if (!state.roomId || !state.isHost) return;

        var uid = getUid();
        var newIsPublic = !state.isPublic;
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.location.origin + '/syncplayer/setpublic?uid=' + encodeURIComponent(uid) + '&roomId=' + encodeURIComponent(state.roomId) + '&isPublic=' + newIsPublic, true);
        xhr.withCredentials = true;
        xhr.timeout = 5000;

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            state.isPublic = response.isPublic !== undefined ? response.isPublic : (response.is_public !== undefined ? response.is_public : newIsPublic);
                            notify('Комната ' + (state.isPublic ? 'публичная' : 'приватная'));
                            showSyncMenu();
                        }
                    } catch (e) {
                        warn('Failed to parse setpublic response:', e);
                    }
                }
            }
        };

        xhr.send();
    }

    function promptJoinRoom() {
        Lampa.Input.edit({
            title: 'Введите код комнаты',
            value: '',
            free: true,
            nosave: true,
            placeholder: '6 цифр'
        }, function (code) {
            if (code) {
                joinRoomFlow(code.trim());
            }
        });
    }

    function joinRoomFlow(code) {
        var normalized = normalizeRoomCode(code);
        if (!normalized) {
            notify('Совместный просмотр: некорректный код');
            Lampa.Controller.toggle('content');
            return;
        }

        // Сбрасываем все состояние перед подключением
        state.pendingMedia = null;
        state.awaitingPrompt = false;
        state.lastMediaSignature = null;
        state.isApplyingOffer = false;
        state.closing = false;

        state.roomId = normalized;
        state.isHost = false;
        persistRoomState();
        connectWebSocket();
        updateHeaderState();
        notify('Совместный просмотр: подключаемся...');
        Lampa.Controller.toggle('content');
    }

    function leaveRoom(clearStored) {
        log('leaveRoom called, clearStored:', clearStored);

        // Останавливаем все таймеры
        if (state.syncTimer) {
            clearInterval(state.syncTimer);
            state.syncTimer = null;
        }
        if (state.playPauseTimer) {
            clearTimeout(state.playPauseTimer);
            state.playPauseTimer = null;
        }
        if (state.remoteUpdateTimer) {
            clearTimeout(state.remoteUpdateTimer);
            state.remoteUpdateTimer = null;
        }

        closeWebSocket('manual');
        detachVideoListeners();

        // Полная очистка состояния
        state.roomId = '';
        state.isHost = false;
        state.isConnected = false;
        state.closing = false;
        state.pendingMedia = null;
        state.awaitingPrompt = false;
        state.lastMediaSignature = null;
        state.isApplyingOffer = false;
        state.lastSyncSentAt = 0;
        state.lastRemoteUpdateAt = 0;
        state.isRemoteUpdate = false;

        persistRoomState();
        updateHeaderState();
        notify('Совместный просмотр: отключено');
        Lampa.Controller.toggle('content');
    }

    function onPlayerStart(event) {
        log('onPlayerStart called, isHost:', state.isHost, 'isApplyingOffer:', state.isApplyingOffer, 'isConnected:', state.isConnected);
        state.playerActive = true;

        if (!isEnabled()) return;

        // Если мы гость и применяем оффер, не отправляем свой media_offer
        if (state.isApplyingOffer) {
            log('Skipping sendMediaOffer - applying offer');
            return;
        }

        // Только хост отправляет media_offer
        if (!state.isHost) {
            log('Not host, skipping media_offer');
            return;
        }

        if (!isSocketReady()) {
            log('Socket not ready, skipping media_offer');
            return;
        }

        // Всегда сбрасываем сигнатуру при новом старте
        state.lastMediaSignature = null;

        // Отложенная отправка чтобы данные плеера были готовы
        setTimeout(function () {
            if (state.isHost && state.playerActive && isSocketReady()) {
                log('Sending media_offer after delay');
                sendMediaOffer(null, true);
                sendSyncState(true);
            }
        }, 500);
    }

    function onPlayerReady() {
        log('onPlayerReady called, isHost:', state.isHost, 'isConnected:', state.isConnected);
        state.playerActive = true;

        if (!isEnabled()) return;
        ensureVideoReference();
        maybeAutoConnect();

        // Только хост отправляет media_offer
        if (state.isHost && isSocketReady() && !state.isApplyingOffer) {
            setTimeout(function () {
                if (state.isHost && state.playerActive && isSocketReady()) {
                    sendMediaOffer(null, true);
                }
            }, 300);
        }
    }

    function onPlayerDestroy() {
        log('onPlayerDestroy called, isHost:', state.isHost);
        state.playerActive = false;

        // Уведомляем других участников о закрытии плеера
        if (state.isHost && isSocketReady()) {
            sendPlayerClosed();
        }

        stopHostSyncLoop();
        detachVideoListeners();
        state.lastMediaSignature = null;
    }

    function initPlugin() {
        loadStateFromStorage();
        initHeaderButton();
        checkUrlParams();

        // Force internal player on Android when connected to Sync
        if (Lampa.Player && typeof Lampa.Player.play === 'function') {
            var originalPlay = Lampa.Player.play;
            Lampa.Player.play = function (data) {
                var isAndroid = Lampa.Platform && Lampa.Platform.is && Lampa.Platform.is('android');
                if (state.isConnected && isAndroid) {
                    if (data && typeof data === 'object') {
                        data.launch_player = 'inner';
                        notify('Совместный просмотр: принудительно включен встроенный плеер');
                    }
                }
                return originalPlay.apply(Lampa.Player, arguments);
            };
        }

        Lampa.Player.listener.follow('ready', function () {
            onPlayerReady();
        });

        Lampa.Player.listener.follow('destroy', function () {
            onPlayerDestroy();
        });

        Lampa.Player.listener.follow('start', function (event) {
            onPlayerStart(event);
        });

        maybeAutoConnect();
        log('SyncPlayer plugin initialized');
    }

    if (window.appready) {
        initPlugin();
    } else {
        Lampa.Listener.follow('app', function (event) {
            if (event.type === 'ready') {
                initPlugin();
            }
        });
    }

    // Экспорт API для интеграции с другими плагинами (например, ServerDownload)
    window.SyncPlayerAPI = {
        /**
         * Создать комнату и начать воспроизведение
         * @param {Object} card - Объект карточки фильма/сериала
         * @param {Object} stream - Объект стрима {url, title, quality}
         */
        createRoom: function (card, stream) {
            // Сначала создаём комнату
            createRoomFlow();

            // После подключения начинаем воспроизведение
            var checkConnected = setInterval(function () {
                if (state.isConnected && state.roomId) {
                    clearInterval(checkConnected);

                    // Формируем данные для плеера
                    var playerData = {
                        title: stream.title || card.title || card.name,
                        url: stream.url,
                        poster: card.poster_path ?
                            'https://image.tmdb.org/t/p/w500' + card.poster_path : '',
                        timeline: {
                            duration: 0,
                            time: 0
                        }
                    };

                    // Запускаем плеер
                    setTimeout(function () {
                        Lampa.Player.play(playerData);
                        Lampa.Player.playlist([playerData]);
                    }, 500);
                }
            }, 100);

            // Таймаут на случай если не подключимся
            setTimeout(function () {
                clearInterval(checkConnected);
            }, 10000);
        },

        /**
         * Присоединиться к комнате
         * @param {string} roomId - ID комнаты
         */
        joinRoom: function (roomId) {
            state.roomId = roomId;
            state.isHost = false;
            connectWebSocket();
        },

        /**
         * Проверить, подключен ли к комнате
         * @returns {boolean}
         */
        isConnected: function () {
            return state.isConnected;
        },

        /**
         * Получить ID текущей комнаты
         * @returns {string|null}
         */
        getRoomId: function () {
            return state.roomId || null;
        },

        /**
         * Отключиться от комнаты
         */
        disconnect: function () {
            leaveRoom();
        }
    };

    log('SyncPlayer script loaded');

})();