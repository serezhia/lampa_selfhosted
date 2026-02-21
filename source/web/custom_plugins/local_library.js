(function () {
    'use strict';

    if (window.plugin_local_library_initialized) return;
    window.plugin_local_library_initialized = true;

    console.log('[LocalLibrary] Инициализация плагина');

    var network = new Lampa.Reguest();

    function getAuthHeaders() {
        var account = Lampa.Storage.get('account', {}) || {};
        var profile = Lampa.Storage.get('profile', {}) || {};
        return {
            'token': account.token || '',
            'profile': profile.id || ''
        };
    }

    // 1. Добавляем пункт меню
    function addMenuItem() {
        if ($('.menu__text:contains("Моя библиотека")').length) return; // Защита от дублирования

        var svg = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>';
        
        Lampa.Menu.addButton(svg, 'Моя библиотека', function () {
            Lampa.Activity.push({
                url: '',
                title: 'Моя библиотека',
                component: 'local_library',
                page: 1
            });
        });
    }

    // 2. Создаем компонент страницы библиотеки
    function LocalLibraryComponent(object) {
        var comp = Lampa.Utils.createInstance(Lampa.Maker.get('Category'), object, {
            module: Lampa.Maker.module('Category').toggle(Lampa.Maker.module('Category').MASK.base, 'Pagination')
        });

        comp.use({
            onCreate: function () {
                var _this = this;
                
                // Запрашиваем список загрузок
                var url = Lampa.Storage.get('server_url', '') + '/api/library/list';

                network.silent(url, function (data) {
                    if (data && data.success && data.items) {
                        var items = data.items.map(function(item) {
                            // Преобразуем в формат карточки Lampa
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
                                original_title: item.title,
                                original_name: item.title,
                                release_date: '2025',
                                first_air_date: '2025',
                                vote_average: 0
                            };

                            // Правильная обработка постеров для Lampa
                            if (item.poster && item.poster.indexOf('/') === 0) {
                                // Если это относительный путь TMDB (начинается со слэша)
                                card.poster_path = item.poster;
                                card.backdrop_path = item.poster;
                            } else if (item.poster) {
                                // Если это уже полный URL
                                card.img = item.poster;
                            } else {
                                // Заглушка, если постера нет
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
                }, false, {
                    headers: getAuthHeaders()
                });
            },
            onInstance: function (item, data) {
                item.use({
                    onCreate: function() {
                        // Добавляем статус на карточку
                        var statusText = '';
                        var statusClass = '';
                        
                        if (data.library_status === 'pending') {
                            if (data.library_progress > 0) {
                                statusText = 'В очереди ' + Math.round(data.library_progress) + '%';
                            } else {
                                statusText = 'В очереди';
                            }
                            statusClass = 'status-pending';
                        } else if (data.library_status === 'downloading') {
                            statusText = 'Загрузка ' + Math.round(data.library_progress) + '%';
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
                            
                            // В новом API Lampa DOM-элемент карточки доступен через this.html или this.card
                            var cardEl = this.html || $(this.card);
                            var viewEl = cardEl.find('.card__view');
                            
                            if (viewEl.length) {
                                viewEl.append(statusHtml);
                            } else {
                                cardEl.append(statusHtml);
                            }

                            // Если статус не "Готово" и не "Ошибка", запускаем таймер для обновления
                            if (data.library_status !== 'ready' && data.library_status !== 'error') {
                                var updateTimer = setInterval(function() {
                                    // Проверяем, существует ли еще карточка в DOM
                                    if (!cardEl.closest('body').length) {
                                        clearInterval(updateTimer);
                                        return;
                                    }

                                    var url = Lampa.Storage.get('server_url', '') + '/api/library/list';
                                    network.silent(url, function (res) {
                                        if (res && res.success && res.items) {
                                            var updatedItem = res.items.find(function(i) { return i.id === data.library_id; });
                                            if (updatedItem) {
                                                var newText = '';
                                                if (updatedItem.status === 'pending') {
                                                    newText = updatedItem.progress > 0 ? 'В очереди ' + Math.round(updatedItem.progress) + '%' : 'В очереди';
                                                } else if (updatedItem.status === 'downloading') {
                                                    newText = 'Загрузка ' + Math.round(updatedItem.progress) + '%';
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
                                                    // Обновляем данные в самой карточке, чтобы onEnter работал правильно
                                                    data.library_status = updatedItem.status;
                                                    data.library_progress = updatedItem.progress;
                                                }
                                            } else {
                                                // Элемент удален
                                                clearInterval(updateTimer);
                                            }
                                        }
                                    }, false, false, {
                                        headers: getAuthHeaders()
                                    });
                                }, 5000); // Обновляем каждые 5 секунд
                            }
                        }
                    },
                    onEnter: function () {
                        if (data.library_status === 'ready') {
                            // Воспроизводим
                            var playUrl = Lampa.Storage.get('server_url', '') + '/api/library/play/' + data.library_id + '/playlist.m3u8';
                            
                            var video = {
                                title: data.title,
                                url: playUrl
                            };
                            
                            Lampa.Player.play(video);
                            Lampa.Player.playlist([video]);
                        } else {
                            // Показываем меню с возможностью удалить
                            Lampa.Select.show({
                                title: 'Действия',
                                items: [
                                    {
                                        title: 'Удалить из библиотеки',
                                        action: 'delete'
                                    }
                                ],
                                onSelect: function (a) {
                                    if (a.action === 'delete') {
                                        deleteItem(data.library_id, function() {
                                            Lampa.Activity.replace(); // Перезагружаем страницу
                                        });
                                    }
                                },
                                onBack: function () {
                                    Lampa.Controller.toggle('content');
                                }
                            });
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

    function deleteItem(id, callback) {
        var url = Lampa.Storage.get('server_url', '') + '/api/library/remove?id=' + id;

        network.silent(url, function (data) {
            if (data && data.success) {
                Lampa.Noty.show('Удалено из библиотеки');
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

    Lampa.Component.add('local_library', LocalLibraryComponent);

    // 3. Добавляем кнопку "Скачать на сервер" в меню действий файла (долгое нажатие на файл)
    Lampa.Listener.follow('torrent_file', function (e) {
        if (e.type === 'onlong') {
            // Проверяем, нет ли уже такой кнопки
            if (e.menu.filter(function(m) { return m.title === 'Скачать на сервер'; }).length > 0) return;

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
                        episode: file.episode || 0
                    };
                    
                    if (!data.magnet_uri) {
                        Lampa.Noty.show('Не удалось получить ссылку на торрент');
                        return;
                    }

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
                        headers: headers
                    });
                }
            });
        }
    });

    // 4. Добавляем в долгое нажатие на сам торрент
    Lampa.Listener.follow('torrent', function (e) {
        if (e.type === 'onlong') {
            // Проверяем, нет ли уже такой кнопки
            if (e.menu.filter(function(m) { return m.title === 'Скачать на сервер'; }).length > 0) return;

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
                        episode: file.episode || 0
                    };
                    
                    if (!data.magnet_uri) {
                        Lampa.Noty.show('Не удалось получить ссылку на торрент');
                        return;
                    }

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
                        headers: headers
                    });
                }
            });
        }
    });

    // Инициализация
    if (window.appready) {
        addMenuItem();
    } else {
        Lampa.Listener.follow('app', function (e) {
            if (e.type === 'ready') {
                addMenuItem();
            }
        });
    }

})();
