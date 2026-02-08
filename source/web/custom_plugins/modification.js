/**
 * Modification.js - Автоматический загрузчик плагинов для Lampa
 * 
 * Этот файл загружает все плагины из manifest.json
 * Manifest генерируется при старте контейнера и учитывает приоритет:
 * - Custom плагины (data/plugins) имеют приоритет
 * - Builtin плагины (source/web/custom_plugins) загружаются если нет custom версии
 */

(function () {
    'use strict';

    console.log('[Modification] Инициализация загрузчика плагинов');

    /**
     * Загружает скрипт плагина
     * @param {string} url - URL скрипта
     * @returns {Promise}
     */
    function loadScript(url) {
        return new Promise(function (resolve, reject) {
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.src = url;

            script.onload = function () {
                console.log('[Modification] Загружен:', url);
                resolve(url);
            };

            script.onerror = function () {
                console.error('[Modification] Ошибка загрузки:', url);
                reject(new Error('Failed to load: ' + url));
            };

            document.head.appendChild(script);
        });
    }

    /**
     * Загружает плагины последовательно
     * @param {Array} plugins - Массив объектов плагинов из manifest
     */
    function loadPluginsSequentially(plugins) {
        var index = 0;

        function loadNext() {
            if (index >= plugins.length) {
                console.log('[Modification] Все плагины загружены');
                return;
            }

            var plugin = plugins[index];
            var sourceLabel = plugin.source === 'custom' ? '(custom)' : '(builtin)';
            console.log('[Modification] Загрузка ' + sourceLabel + ': ' + plugin.name);

            loadScript(plugin.url)
                .then(function () {
                    index++;
                    loadNext();
                })
                .catch(function () {
                    // Продолжаем загрузку остальных плагинов даже при ошибке
                    index++;
                    loadNext();
                });
        }

        loadNext();
    }

    /**
     * Загружает manifest и инициализирует плагины
     */
    function init() {
        console.log('[Modification] Загрузка манифеста плагинов...');

        fetch('/plugins/manifest.json')
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Manifest not found');
                }
                return response.json();
            })
            .then(function (manifest) {
                console.log('[Modification] Найдено плагинов:', manifest.plugins.length);

                // Сортируем: сначала modification (если есть), потом остальные в определённом порядке
                var loadOrder = ['auth', 'default_settings', 'jackett_proxy', 'custom_notices', 'sync_player', 'transcoding', 'online'];

                var sortedPlugins = manifest.plugins.slice().sort(function (a, b) {
                    var aIndex = loadOrder.indexOf(a.name);
                    var bIndex = loadOrder.indexOf(b.name);

                    // Если оба в списке порядка - сортируем по порядку
                    if (aIndex !== -1 && bIndex !== -1) {
                        return aIndex - bIndex;
                    }
                    // Если один в списке - он первый
                    if (aIndex !== -1) return -1;
                    if (bIndex !== -1) return 1;
                    // Оба не в списке - по имени
                    return a.name.localeCompare(b.name);
                });

                // Фильтруем modification.js из загрузки (он уже загружен)
                sortedPlugins = sortedPlugins.filter(function (p) {
                    return p.name !== 'modification';
                });

                loadPluginsSequentially(sortedPlugins);
            })
            .catch(function (error) {
                console.error('[Modification] Ошибка загрузки манифеста:', error);
                console.log('[Modification] Fallback: загрузка плагинов напрямую');

                // Fallback - загружаем известные плагины напрямую
                var fallbackPlugins = [
                    { name: 'auth', url: '/plugins/auth.js' },
                    { name: 'default_settings', url: '/plugins/default_settings.js' },
                    { name: 'jackett_proxy', url: '/plugins/jackett_proxy.js' },
                    { name: 'custom_notices', url: '/plugins/custom_notices.js' },
                    { name: 'sync_player', url: '/plugins/sync_player.js' },
                    { name: 'transcoding', url: '/plugins/transcoding.js' },
                    { name: 'online', url: '/plugins/online.js' }
                ];
                loadPluginsSequentially(fallbackPlugins);
            });
    }

    // Запускаем загрузку после того, как Lampa будет готова
    if (window.Lampa) {
        init();
    } else {
        // Если Lampa ещё не загружена, ждём события DOMContentLoaded
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(init, 500);
        });
    }

})();

