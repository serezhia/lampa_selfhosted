/**
 * Default Settings Plugin - Устанавливает настройки по умолчанию при первом запуске
 */

(function () {
    'use strict';

    var PLUGIN_NAME = 'DefaultSettings';

    function log() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[' + PLUGIN_NAME + ']');
        console.log.apply(console, args);
    }

    // =========================================================================
    // Default Settings Configuration
    // =========================================================================

    function getBaseUrl() {
        return window.location.protocol + '//' + window.location.host;
    }

    var DEFAULTS = {
        // TorrServer
        'torrserver_url': getBaseUrl() + '/torrserver',
        'torrserver_auth': false,
        'torrserver_login': '',
        'torrserver_password': '',
        'torrserver_use_stream': true,

        // Jackett Parser (через прокси с валидацией токена)
        // API key автоматически подменяется на deviceToken плагином jackett_proxy.js
        'parser': true,
        'parser_use': 'jackett',
        'parser_torrent_type': 'jackett',
        'jackett_url': getBaseUrl() + '/jackett',  // Свой прокси с валидацией
        'jackett_key': 'auto',  // Будет заменён на deviceToken

        // Synchronization - включаем по умолчанию
        'account_use': true,           // Использовать аккаунт
        'account_sync': true,          // Синхронизация
        'account_sync_bookmarks': true, // Синхронизация закладок
        'account_sync_history': true,   // Синхронизация истории
        'account_sync_timeline': true,  // Синхронизация таймлайна

        // Enable Torrent section in menu
        'source': 'cub',
        'start_page': 'main'
    };

    // Key to track if defaults have been applied
    var DEFAULTS_APPLIED_KEY = 'lampa_defaults_applied_v3';

    // =========================================================================
    // Apply Defaults
    // =========================================================================

    function applyDefaults() {
        // Check if defaults were already applied
        if (Lampa.Storage.get(DEFAULTS_APPLIED_KEY)) {
            log('Defaults already applied, skipping');
            return;
        }

        log('Applying default settings...');

        var applied = 0;

        for (var key in DEFAULTS) {
            var currentValue = Lampa.Storage.get(key, null);

            // Only set if not already configured
            if (currentValue === null || currentValue === '' || currentValue === undefined) {
                Lampa.Storage.set(key, DEFAULTS[key]);
                log('Set', key, '=', DEFAULTS[key]);
                applied++;
            } else {
                log('Skip', key, '- already set to:', currentValue);
            }
        }

        // Mark defaults as applied
        Lampa.Storage.set(DEFAULTS_APPLIED_KEY, true);

        log('Applied', applied, 'default settings');

        // Show notification if settings were applied
        if (applied > 0 && Lampa.Noty) {
            Lampa.Noty.show('Настройки TorrServer и Jacred установлены', { time: 3000 });
        }
    }

    // =========================================================================
    // Force Reset (for development/testing)
    // =========================================================================

    function resetDefaults() {
        log('Resetting defaults flag...');
        Lampa.Storage.set(DEFAULTS_APPLIED_KEY, false);

        for (var key in DEFAULTS) {
            Lampa.Storage.set(key, DEFAULTS[key]);
            log('Reset', key, '=', DEFAULTS[key]);
        }

        if (Lampa.Noty) {
            Lampa.Noty.show('Настройки сброшены к значениям по умолчанию', { time: 3000 });
        }
    }

    // Expose reset function for debugging
    window.resetLampaDefaults = resetDefaults;

    // =========================================================================
    // Initialization
    // =========================================================================

    function init() {
        if (window.lampa_default_settings_initialized) {
            return;
        }
        window.lampa_default_settings_initialized = true;

        log('Initializing...');

        // Apply defaults on startup
        applyDefaults();

        log('Initialized');
    }

    // Start when Lampa is ready
    if (window.Lampa && Lampa.Storage) {
        init();
    } else {
        var checkInterval = setInterval(function () {
            if (window.Lampa && Lampa.Storage) {
                clearInterval(checkInterval);
                init();
            }
        }, 100);

        setTimeout(function () {
            clearInterval(checkInterval);
        }, 10000);
    }

})();
