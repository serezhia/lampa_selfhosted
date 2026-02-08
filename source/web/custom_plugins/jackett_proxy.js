/**
 * Jackett Proxy Plugin - Подменяет API ключ Jackett на deviceToken
 * 
 * Схема работы:
 * 1. Lampa делает запрос к Jackett с apikey = deviceToken
 * 2. Nginx принимает запрос и валидирует deviceToken через /api/device/validate
 * 3. Если токен валиден, Nginx подменяет apikey на реальный ключ Jackett
 * 4. Запрос проксируется в Jackett
 *
 * Это позволяет:
 * - Не раскрывать реальный API ключ Jackett пользователям
 * - Контролировать доступ к Jackett через авторизацию устройств
 */

(function () {
    'use strict';

    var PLUGIN_NAME = 'JackettProxy';

    function log() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[' + PLUGIN_NAME + ']');
        console.log.apply(console, args);
    }

    // =========================================================================
    // Get Device Token
    // =========================================================================

    function getDeviceToken() {
        var account = Lampa.Storage.get('account', '{}');
        if (account && account.token) {
            return account.token;
        }
        return '';
    }

    // =========================================================================
    // Proxy URL Builder
    // =========================================================================

    function getJackettProxyUrl() {
        var protocol = window.location.protocol;
        var host = window.location.host;
        return protocol + '//' + host + '/jackett';
    }

    // =========================================================================
    // API Key Substitution
    // =========================================================================

    function init() {
        // Проверяем что Lampa загружена
        if (typeof Lampa === 'undefined' || !Lampa.Storage || !Lampa.Storage.field) {
            log('Lampa not ready, retrying in 500ms...');
            setTimeout(init, 500);
            return;
        }

        log('Initializing Jackett Proxy...');

        // Сохраняем оригинальную функцию field
        var originalField = Lampa.Storage.field;

        // Перехватываем Storage.field для подмены API ключей
        Lampa.Storage.field = function (name) {
            // Подменяем API ключи Jackett/Prowlarr на deviceToken
            if (name === 'jackett_key' ||
                name === 'jackett_key_two' ||
                name === 'prowlarr_key' ||
                name === 'prowlarr_key_two') {

                var token = getDeviceToken();
                if (token) {
                    log('Substituting', name, 'with deviceToken');
                    return token;
                }
            }

            return originalField.apply(this, arguments);
        };

        log('API key substitution enabled');

        // Автоматически настраиваем URL Jackett на прокси
        setupJackettUrl();
    }

    // =========================================================================
    // Auto-configure Jackett URL
    // =========================================================================

    function setupJackettUrl() {
        var jackettProxyUrl = getJackettProxyUrl();

        // Проверяем текущие настройки
        var currentUrl = Lampa.Storage.get('jackett_url', '');
        var isUsingProxy = currentUrl.indexOf(window.location.host) !== -1 &&
            currentUrl.indexOf('/jackett') !== -1;

        // Если не используется прокси, предлагаем настроить
        if (!isUsingProxy && getDeviceToken()) {
            log('Jackett URL:', currentUrl);
            log('Recommended proxy URL:', jackettProxyUrl);

            // Автоматически настраиваем если URL пустой или это jacred
            if (!currentUrl || currentUrl.indexOf('jacred') !== -1) {
                Lampa.Storage.set('jackett_url', jackettProxyUrl);
                log('Auto-configured Jackett URL to proxy:', jackettProxyUrl);
            }
        }
    }

    // =========================================================================
    // Manual Configuration Helper
    // =========================================================================

    // Экспортируем функцию для ручной настройки
    window.JackettProxy = {
        getProxyUrl: getJackettProxyUrl,
        getDeviceToken: getDeviceToken,

        // Принудительно настроить прокси
        configure: function () {
            var url = getJackettProxyUrl();
            Lampa.Storage.set('jackett_url', url);
            Lampa.Storage.set('jackett_key', 'auto'); // Будет заменён на deviceToken
            log('Configured Jackett to use proxy:', url);
            Lampa.Noty.show('Jackett настроен на прокси', { time: 3000 });
        },

        // Показать информацию о настройках
        info: function () {
            console.log('=== Jackett Proxy Info ===');
            console.log('Proxy URL:', getJackettProxyUrl());
            console.log('Device Token:', getDeviceToken() ? 'Present' : 'Not found');
            console.log('Current Jackett URL:', Lampa.Storage.get('jackett_url', ''));
            console.log('========================');
        }
    };

    // =========================================================================
    // Plugin Registration
    // =========================================================================

    function startPlugin() {
        if (window.appready) {
            init();
        } else {
            Lampa.Listener.follow('app', function (event) {
                if (event.type === 'ready') {
                    init();
                }
            });
        }
    }

    // Запускаем
    if (typeof Lampa !== 'undefined' && Lampa.Listener) {
        startPlugin();
    } else {
        // Ждём загрузки Lampa
        var checkInterval = setInterval(function () {
            if (typeof Lampa !== 'undefined' && Lampa.Listener) {
                clearInterval(checkInterval);
                startPlugin();
            }
        }, 100);
    }

    log('Plugin loaded');
})();
