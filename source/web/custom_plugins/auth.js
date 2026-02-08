/**
 * Auth Required Plugin - Требует авторизации через Telegram бота
 * 
 * Виртуальная клавиатура как в Lampa:
 * - На ПК: клики мышкой по кнопкам
 * - На ТВ: стрелки для навигации, OK для ввода цифры
 */

(function () {
    'use strict';

    var PLUGIN_NAME = 'AuthRequired';
    var loginScreenShown = false;
    var isAuthorized = false;
    var network = null;
    var currentCode = '';
    var appConfig = null;

    // =========== DEFAULT CONFIGURATION ===========
    var TELEGRAM_BOT = '@lampa_bot'; // Will be updated from /api/config
    // =============================================

    function log() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[' + PLUGIN_NAME + ']');
        console.log.apply(console, args);
    }

    // =========================================================================
    // Authorization Check
    // =========================================================================

    function checkAuthorization() {
        var account = Lampa.Storage.get('account', '{}');

        if (account && account.token && account.profile) {
            log('User authorized:', account.profile.name || account.email || 'Unknown');
            isAuthorized = true;
            return true;
        }

        log('User not authorized');
        isAuthorized = false;
        return false;
    }

    // =========================================================================
    // API
    // =========================================================================

    function getApiUrl() {
        // Динамически определяем API URL из текущего домена
        var protocol = window.location.protocol;
        var host = window.location.host;
        return protocol + '//' + host + '/api/';
    }

    function loadAppConfig(callback) {
        if (appConfig) {
            if (callback) callback(appConfig);
            return;
        }

        var api = getApiUrl();
        $.ajax({
            url: api + 'config',
            method: 'GET',
            dataType: 'json',
            success: function (data) {
                appConfig = data;
                if (data.telegram_bot) {
                    TELEGRAM_BOT = data.telegram_bot;
                    log('Loaded bot name from config:', TELEGRAM_BOT);
                }
                if (callback) callback(data);
            },
            error: function (err) {
                log('Failed to load config, using defaults:', err);
                if (callback) callback(null);
            }
        });
    }

    function getDevicePlatform() {
        // Используем Lampa.Platform если доступен
        if (typeof Lampa !== 'undefined' && Lampa.Platform && Lampa.Platform.get) {
            var platform = Lampa.Platform.get();
            if (platform) return platform;
        }

        // Fallback определение платформы
        var ua = navigator.userAgent.toLowerCase();

        if (ua.indexOf('tizen') !== -1) return 'tizen';
        if (ua.indexOf('webos') !== -1 || ua.indexOf('web0s') !== -1) return 'webos';
        if (ua.indexOf('android') !== -1) return 'android';
        if (ua.indexOf('iphone') !== -1 || ua.indexOf('ipad') !== -1 || ua.indexOf('mac') !== -1) return 'apple';
        if (ua.indexOf('chrome') !== -1) return 'browser';

        return 'other';
    }

    function getDeviceName() {
        var platform = getDevicePlatform();
        var customName = '';

        // Получаем кастомное имя устройства из настроек Lampa
        if (typeof Lampa !== 'undefined' && Lampa.Storage && Lampa.Storage.field) {
            customName = Lampa.Storage.field('device_name') || '';
        }

        // Капитализируем платформу
        var platformName = platform.charAt(0).toUpperCase() + platform.slice(1);

        if (customName) {
            return platformName + ' - ' + customName;
        }

        return platformName;
    }

    function addDevice(code, onSuccess, onError) {
        if (!network) {
            network = new Lampa.Reguest();
        }

        var api = getApiUrl();
        var platform = getDevicePlatform();
        var deviceName = getDeviceName();

        log('Adding device with code:', code, 'platform:', platform, 'name:', deviceName);

        network.clear();
        network.silent(api + 'device/add', function (result) {
            log('Device added successfully:', result);

            Lampa.Storage.set('account', result, true);
            if (result.email) {
                Lampa.Storage.set('account_email', result.email, true);
            }

            if (onSuccess) onSuccess(result);
        }, function (error) {
            log('Error adding device:', error);
            if (onError) onError(error);
        }, {
            code: parseInt(code),
            platform: platform,
            name: deviceName
        });
    }

    // =========================================================================
    // Login Screen
    // =========================================================================

    function showLoginScreen() {
        if (loginScreenShown) return;
        loginScreenShown = true;
        currentCode = '';

        log('Showing login screen');

        // Создаем HTML через jQuery как в Lampa
        var html = $('\
            <div class="auth-overlay">\
                <div class="auth-container">\
                    <div class="auth-logo">\
                        <svg viewBox="0 0 24 24"><path d="M12 2L4 5v6.09c0 5.05 3.41 9.76 8 10.91 4.59-1.15 8-5.86 8-10.91V5l-8-3zm-1.06 13.54L7.4 12l1.41-1.41 2.12 2.12 4.24-4.24 1.41 1.41-5.64 5.66z"/></svg>\
                    </div>\
                    <div class="auth-title">Требуется авторизация</div>\
                    <div class="auth-desc">Для получения 6-значного кода<br>напишите боту: <b>' + TELEGRAM_BOT + '</b></div>\
                    <div class="auth-code">\
                        <div></div>\
                        <div></div>\
                        <div></div>\
                        <div></div>\
                        <div></div>\
                        <div></div>\
                    </div>\
                    <div class="auth-keyboard">\
                        <div class="auth-keyboard__row">\
                            <div class="auth-key selector" data-key="1"><span>1</span></div>\
                            <div class="auth-key selector" data-key="2"><span>2</span></div>\
                            <div class="auth-key selector" data-key="3"><span>3</span></div>\
                        </div>\
                        <div class="auth-keyboard__row">\
                            <div class="auth-key selector" data-key="4"><span>4</span></div>\
                            <div class="auth-key selector" data-key="5"><span>5</span></div>\
                            <div class="auth-key selector" data-key="6"><span>6</span></div>\
                        </div>\
                        <div class="auth-keyboard__row">\
                            <div class="auth-key selector" data-key="7"><span>7</span></div>\
                            <div class="auth-key selector" data-key="8"><span>8</span></div>\
                            <div class="auth-key selector" data-key="9"><span>9</span></div>\
                        </div>\
                        <div class="auth-keyboard__row">\
                            <div class="auth-key auth-key--fn selector" data-key="BKSP"><span>⌫</span></div>\
                            <div class="auth-key selector" data-key="0"><span>0</span></div>\
                            <div class="auth-key auth-key--fn selector" data-key="ENTER"><span>✓</span></div>\
                        </div>\
                    </div>\
                </div>\
            </div>\
        ');

        var keyboard = html.find('.auth-keyboard');
        var keys = keyboard.find('[data-key]');
        var focusIndex = 0; // Начинаем с кнопки "1"

        // Устанавливаем фокус на кнопку по индексу
        function setFocus(index) {
            // Ограничиваем индекс
            if (index < 0) index = 0;
            if (index >= keys.length) index = keys.length - 1;

            focusIndex = index;
            keys.removeClass('focus');
            keys.eq(focusIndex).addClass('focus');
        }

        // Навигация по сетке 3x4
        function navigate(direction) {
            var cols = 3;
            var rows = 4;
            var row = Math.floor(focusIndex / cols);
            var col = focusIndex % cols;

            if (direction === 'up') {
                if (row > 0) {
                    setFocus(focusIndex - cols);
                }
            } else if (direction === 'down') {
                if (row < rows - 1) {
                    setFocus(focusIndex + cols);
                }
            } else if (direction === 'left') {
                if (col > 0) {
                    setFocus(focusIndex - 1);
                }
            } else if (direction === 'right') {
                if (col < cols - 1) {
                    setFocus(focusIndex + 1);
                }
            }
        }

        // Обновление отображения кода
        function drawCode() {
            var divs = html.find('.auth-code div').removeClass('fill');
            for (var i = 0; i < 6; i++) {
                if (currentCode[i]) {
                    divs.eq(i).addClass('fill').text(currentCode[i]);
                } else {
                    divs.eq(i).text('');
                }
            }
        }

        // Добавление цифры
        function addNum(num) {
            if (currentCode.length < 6) {
                currentCode += num;
                drawCode();

                if (currentCode.length === 6) {
                    setTimeout(submitCode, 300);
                }
            }
        }

        // Удаление цифры
        function removeNum() {
            if (currentCode.length > 0) {
                currentCode = currentCode.slice(0, -1);
                drawCode();
            }
        }

        // Отправка кода
        function submitCode() {
            if (currentCode.length !== 6) {
                Lampa.Noty.show('Введите 6 цифр');
                return;
            }

            Lampa.Noty.show('Проверка кода...');

            addDevice(currentCode, function (result) {
                Lampa.Noty.show('Авторизация успешна!');

                // Просто перезагружаем страницу
                window.location.reload();
            }, function (error) {
                Lampa.Noty.show('Неверный код или код истёк');
                currentCode = '';
                drawCode();
            });
        }

        // Обработка нажатия на кнопку (для ПК клики, для ТВ hover:enter)
        keyboard.find('[data-key]').on('hover:enter', function () {
            var key = $(this).data('key');

            if (key === 'BKSP') {
                removeNum();
            } else if (key === 'ENTER') {
                submitCode();
            } else {
                addNum(key.toString());
            }
        });

        // Добавляем стили
        addStyles();

        // Добавляем на страницу
        $('body').append(html);

        // Сразу выводим тестовое сообщение
        log('=== AUTH SCREEN LOADED ===');
        log('Keyboard keys count:', keys.length);

        // Инициализируем контроллер - своя навигация по сетке
        Lampa.Controller.add('auth_keyboard', {
            toggle: function () {
                log('Controller toggle called');
                // Устанавливаем начальный фокус
                setFocus(0);
            },
            back: function () {
                log('Controller BACK pressed');
                if (currentCode.length > 0) {
                    removeNum();
                } else {
                    Lampa.Noty.show('Требуется авторизация для использования');
                }
            },
            up: function () {
                log('Controller UP pressed, current index:', focusIndex);
                navigate('up');
            },
            down: function () {
                log('Controller DOWN pressed, current index:', focusIndex);
                navigate('down');
            },
            left: function () {
                log('Controller LEFT pressed, current index:', focusIndex);
                navigate('left');
            },
            right: function () {
                log('Controller RIGHT pressed, current index:', focusIndex);
                navigate('right');
            },
            enter: function () {
                log('Controller ENTER pressed, current index:', focusIndex);
                // Нажатие на текущую кнопку
                var key = keys.eq(focusIndex).data('key');
                log('Key at index:', key);
                if (key === 'BKSP') {
                    removeNum();
                } else if (key === 'ENTER') {
                    submitCode();
                } else {
                    addNum(key.toString());
                }
            }
        });

        Lampa.Controller.toggle('auth_keyboard');

        // Свой обработчик клавиш - Lampa.Controller не работает для нашего экрана
        // Блокируем ВСЕ события чтобы не проходили в Lampa
        $(document).on('keydown.auth_keyboard', function (e) {

            // Блокируем все события клавиатуры пока наш экран активен
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            if (e.keyCode === 38) { // UP
                navigate('up');
            } else if (e.keyCode === 40) { // DOWN
                navigate('down');
            } else if (e.keyCode === 37) { // LEFT
                navigate('left');
            } else if (e.keyCode === 39) { // RIGHT
                navigate('right');
            } else if (e.keyCode === 13) { // ENTER
                var key = keys.eq(focusIndex).data('key');
                if (key === 'BKSP') {
                    removeNum();
                } else if (key === 'ENTER') {
                    submitCode();
                } else {
                    addNum(key.toString());
                }
            } else if (e.keyCode === 8 || e.keyCode === 461) { // BACKSPACE or TV Back
                if (currentCode.length > 0) {
                    removeNum();
                }
            }

            return false; // Дополнительная блокировка
        });

        // Устанавливаем начальный фокус
        setFocus(0);

        // Блокируем события на уровне capture phase (раньше всех)
        // Наш обработчик уже обработал нужное, тут просто блокируем для Lampa
        window._authKeyHandler = function (e) {
            // Блокируем keyup и keypress полностью
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            return false;
        };
        // Только keyup и keypress блокируем в capture, keydown обрабатываем через jQuery
        document.addEventListener('keyup', window._authKeyHandler, true);
        document.addEventListener('keypress', window._authKeyHandler, true);

        // DEBUG: Проверяем текущий контроллер
        log('Current controller:', Lampa.Controller.current());
        log('Keys found:', keys.length);

        // Сохраняем ссылку на HTML для удаления
        window._authHtml = html;
    }

    function addStyles() {
        if ($('#auth-required-styles').length) return;

        var css = '\
            .auth-overlay {\
                position: fixed;\
                top: 0;\
                left: 0;\
                right: 0;\
                bottom: 0;\
                background: #1b1b1b;\
                z-index: 999999;\
                /* Используем безопасное центрирование с возможностью скролла */\
                display: flex;\
                flex-direction: column;\
                overflow-y: auto;\
                -webkit-overflow-scrolling: touch;\
            }\
            .auth-container {\
                margin: auto;\
                text-align: center;\
                /* Безопасная формула масштабирования: */\
                /* 1.5vh - чтобы по высоте влезало с запасом (около 70% высоты экрана) */\
                /* 3vw - чтобы по ширине влезало на мобильных (с запасом под пальцы) */\
                font-size: min(1.5vh, 3vw);\
                padding: 3em;\
                display: flex;\
                flex-direction: column;\
                align-items: center;\
                justify-content: center;\
                box-sizing: border-box;\
                /* Предотвращаем обрезку контента если экран супер-маленький */\
                min-height: min-content;\
            }\
            /* Если экран слишком уж маленький, ставим минимальный читаемый шрифт */\
            @media (max-height: 400px) {\
                 .auth-container { font-size: 10px; }\
            }\
            /* Запрещаем элементам сплющиваться */\
            .auth-logo, .auth-title, .auth-desc, .auth-code, .auth-keyboard {\
                flex-shrink: 0;\
            }\
            .auth-logo {\
                margin-bottom: 2em;\
            }\
            .auth-logo svg {\
                width: 5em;\
                height: 5em;\
                fill: #fff;\
            }\
            .auth-title {\
                font-size: 1.6em;\
                color: #fff;\
                margin-bottom: 0.5em;\
                font-weight: 600;\
            }\
            .auth-desc {\
                font-size: 1.1em;\
                color: rgba(255,255,255,0.6);\
                margin-bottom: 2em;\
                line-height: 1.4;\
            }\
            .auth-desc b {\
                color: #fff;\
            }\
            .auth-code {\
                display: flex;\
                justify-content: center;\
                gap: 0.6em;\
                margin-bottom: 2em;\
            }\
            .auth-code > div {\
                width: 3em;\
                height: 3em;\
                background: rgba(255,255,255,0.1);\
                border: 2px solid rgba(255,255,255,0.3);\
                border-radius: 0.4em;\
                display: flex;\
                align-items: center;\
                justify-content: center;\
                font-size: 1.5em;\
                color: #fff;\
                font-weight: bold;\
                box-sizing: border-box;\
            }\
            .auth-code > div.fill {\
                border-color: #fff;\
                background: rgba(255,255,255,0.2);\
            }\
            .auth-keyboard {\
                display: flex;\
                flex-direction: column;\
                gap: 0.6em;\
            }\
            .auth-keyboard__row {\
                display: flex;\
                justify-content: center;\
                gap: 0.6em;\
            }\
            .auth-key {\
                width: 4em;\
                height: 4em;\
                background: rgba(255,255,255,0.08);\
                border-radius: 0.5em;\
                display: flex;\
                align-items: center;\
                justify-content: center;\
                font-size: 1.4em;\
                color: #fff;\
                cursor: pointer;\
                transition: background 0.15s, transform 0.15s;\
                box-sizing: border-box;\
            }\
            .auth-key--fn {\
                background: rgba(255,255,255,0.05);\
            }\
            .auth-key.focus,\
            .auth-key:hover {\
                background: rgba(255,255,255,0.3);\
                transform: scale(1.05);\
            }\
            .auth-key span {\
                pointer-events: none;\
            }\
        ';

        $('<style id="auth-required-styles">' + css + '</style>').appendTo('head');
    }

    function hideLoginScreen() {
        // Убираем наш обработчик клавиш
        $(document).off('keydown.auth_keyboard');

        // Убираем capture блокировщики
        if (window._authKeyHandler) {
            document.removeEventListener('keyup', window._authKeyHandler, true);
            document.removeEventListener('keypress', window._authKeyHandler, true);
            window._authKeyHandler = null;
        }

        if (window._authHtml) {
            window._authHtml.remove();
            window._authHtml = null;
        }

        // Controller.remove может не существовать
        try {
            Lampa.Controller.enabled().name !== 'auth_keyboard' || Lampa.Controller.toggle('content');
        } catch (e) { }

        loginScreenShown = false;
    }

    // =========================================================================
    // Watch for Authorization Changes
    // =========================================================================

    function watchAuthChanges() {
        setInterval(function () {
            var wasAuthorized = isAuthorized;
            var nowAuthorized = checkAuthorization();

            if (!wasAuthorized && nowAuthorized) {
                log('User just logged in!');
                hideLoginScreen();
            } else if (wasAuthorized && !nowAuthorized) {
                log('User logged out');
                showLoginScreen();
            }
        }, 1000);

        if (Lampa.Storage && Lampa.Storage.listener) {
            Lampa.Storage.listener.follow('change', function (e) {
                if (e.name === 'account') {
                    setTimeout(function () {
                        if (checkAuthorization()) {
                            hideLoginScreen();
                        } else {
                            showLoginScreen();
                        }
                    }, 100);
                }
            });
        }
    }

    // =========================================================================
    // Initialization
    // =========================================================================

    function init() {
        if (window.lampa_auth_required_initialized) {
            return;
        }
        window.lampa_auth_required_initialized = true;

        log('Initializing...');

        // Load config first, then check authorization
        loadAppConfig(function () {
            if (!checkAuthorization()) {
                setTimeout(function () {
                    if (!checkAuthorization()) {
                        showLoginScreen();
                    }
                }, 500);
            }
        });

        watchAuthChanges();

        log('Initialized');
    }

    // Start when Lampa is ready
    if (window.Lampa && Lampa.Storage && Lampa.Manifest && Lampa.Controller && Lampa.Noty) {
        init();
    } else {
        var checkInterval = setInterval(function () {
            if (window.Lampa && Lampa.Storage && Lampa.Manifest && Lampa.Controller && Lampa.Noty) {
                clearInterval(checkInterval);
                init();
            }
        }, 100);

        setTimeout(function () {
            clearInterval(checkInterval);
            if (window.Lampa) {
                init();
            }
        }, 10000);
    }

})();
