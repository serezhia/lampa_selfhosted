(function () {
    'use strict';

    console.log('[LocalLibrary] Инициализация плагина');

    var network = new Lampa.Reguest();

    // 1. Добавляем пункт меню
    function addMenuItem() {
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
        var comp = Lampa.Maker.make('Category', object, function (module) {
            // Отключаем пагинацию, так как у нас пока все одним списком
            // module.toggle(Lampa.Maker.module('Category').MASK.base, 'Pagination');
        });

        comp.use({
            onCreate: function () {
                var _this = this;
                
                // Запрашиваем список загрузок
                var url = Lampa.Storage.get('server_url', '') + '/api/library/list';
                var token = Lampa.Storage.get('account_token', '');
                var profile = Lampa.Storage.get('active_profile', '');

                network.silent(url, function (data) {
                    if (data && data.success && data.items) {
                        var items = data.items.map(function(item) {
                            // Преобразуем в формат карточки Lampa
                            var card = {
                                id: item.tmdb_id,
                                title: item.title,
                                name: item.title,
                                poster_path: item.poster,
                                background_image: item.poster,
                                type: item.type,
                                library_id: item.id,
                                library_status: item.status,
                                library_progress: item.progress,
                                library_error: item.error_message
                            };
                            
                            if (item.type === 'tv') {
                                card.title = item.title + ' (S' + (item.season || 1) + 'E' + (item.episode || 1) + ')';
                                card.name = card.title;
                            }
                            
                            return card;
                        });
                        
                        _this.build({
                            results: items,
                            page: 1,
                            total_pages: 1
                        });
                    } else {
                        _this.empty();
                    }
                }, function () {
                    _this.empty();
                }, false, {
                    headers: {
                        'token': token,
                        'profile': profile ? profile.id : ''
                    }
                });
            },
            onInstance: function (item, data) {
                // Добавляем статус на карточку
                var statusText = '';
                var statusClass = '';
                
                if (data.library_status === 'pending') {
                    statusText = 'В очереди';
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

                var statusHtml = $('<div class="library-status ' + statusClass + '" style="position:absolute;top:5px;right:5px;background:rgba(0,0,0,0.7);padding:3px 8px;border-radius:5px;font-size:12px;z-index:2;">' + statusText + '</div>');
                item.append(statusHtml);

                item.use({
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
        var url = Lampa.Storage.get('server_url', '') + '/api/library/remove';
        var token = Lampa.Storage.get('account_token', '');
        var profile = Lampa.Storage.get('active_profile', '');

        network.silent(url, function (data) {
            if (data && data.success) {
                Lampa.Noty.show('Удалено из библиотеки');
                if (callback) callback();
            } else {
                Lampa.Noty.show('Ошибка удаления');
            }
        }, function () {
            Lampa.Noty.show('Ошибка сети');
        }, {
            id: id
        }, {
            headers: {
                'token': token,
                'profile': profile ? profile.id : ''
            },
            method: 'DELETE'
        });
    }

    Lampa.Component.add('local_library', LocalLibraryComponent);

    // 3. Добавляем кнопку "Скачать на сервер" в список файлов торрента
    Lampa.Listener.follow('torrent_file', function (e) {
        if (e.type === 'render') {
            var downloadBtn = $('<div class="torrent-item__download selector" style="padding: 5px 10px; background: rgba(255,255,255,0.1); border-radius: 5px; margin-top: 5px; text-align: center;">Скачать на сервер</div>');
            
            downloadBtn.on('hover:enter', function () {
                // e.element содержит инфу о файле
                // e.params.movie содержит инфу о фильме
                
                var movie = e.params ? e.params.movie : {};
                var file = e.element || {};
                
                var data = {
                    tmdb_id: movie.id || 0,
                    type: movie.name ? 'tv' : 'movie',
                    title: movie.title || movie.name || file.title || 'Unknown',
                    poster: movie.poster_path || '',
                    magnet_uri: file.magnet || (e.params ? e.params.magnet : '') || file.link,
                    season: file.season || 0,
                    episode: file.episode || 0
                };
                
                if (!data.magnet_uri) {
                    Lampa.Noty.show('Не удалось получить magnet-ссылку');
                    return;
                }

                var url = Lampa.Storage.get('server_url', '') + '/api/library/add';
                var token = Lampa.Storage.get('account_token', '');
                var profile = Lampa.Storage.get('active_profile', '');

                network.silent(url, function (res) {
                    if (res && res.success) {
                        Lampa.Noty.show('Добавлено в очередь загрузки');
                    } else {
                        Lampa.Noty.show('Ошибка добавления');
                    }
                }, function () {
                    Lampa.Noty.show('Ошибка сети');
                }, JSON.stringify(data), {
                    headers: {
                        'token': token,
                        'profile': profile ? profile.id : '',
                        'Content-Type': 'application/json'
                    }
                });
            });
            
            // Добавляем кнопку в элемент файла
            e.item.append(downloadBtn);
        }
    });

    // 4. Добавляем в долгое нажатие на торрент
    Lampa.Listener.follow('torrent', function (e) {
        if (e.type === 'onlong') {
            e.menu.push({
                title: 'Скачать на сервер',
                onSelect: function () {
                    var movie = e.params ? e.params.movie : {};
                    var file = e.element || {};
                    
                    var data = {
                        tmdb_id: movie.id || 0,
                        type: movie.name ? 'tv' : 'movie',
                        title: movie.title || movie.name || file.title || 'Unknown',
                        poster: movie.poster_path || '',
                        magnet_uri: file.magnet || (e.params ? e.params.magnet : '') || file.link,
                        season: file.season || 0,
                        episode: file.episode || 0
                    };
                    
                    if (!data.magnet_uri) {
                        Lampa.Noty.show('Не удалось получить magnet-ссылку');
                        return;
                    }

                    var url = Lampa.Storage.get('server_url', '') + '/api/library/add';
                    var token = Lampa.Storage.get('account_token', '');
                    var profile = Lampa.Storage.get('active_profile', '');

                    network.silent(url, function (res) {
                        if (res && res.success) {
                            Lampa.Noty.show('Добавлено в очередь загрузки');
                        } else {
                            Lampa.Noty.show('Ошибка добавления');
                        }
                    }, function () {
                        Lampa.Noty.show('Ошибка сети');
                    }, JSON.stringify(data), {
                        headers: {
                            'token': token,
                            'profile': profile ? profile.id : '',
                            'Content-Type': 'application/json'
                        }
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
