/**
 * Custom Notices Plugin for Lampa Self-Hosted
 * Переопределяет поведение NoticeCub для поддержки кастомных уведомлений
 * 
 * Формат данных для simple уведомлений:
 * {
 *   "card": {
 *     "title": "Заголовок",
 *     "poster": "https://...",
 *   },
 *   "type": "custom",
 *   "text": "Произвольное описание",
 *   "labels": ["Метка 1", "Метка 2"]  // опционально
 * }
 */
(function () {
    'use strict';

    if (!window.Lampa) {
        console.log('[CustomNotices] Lampa not found, skipping');
        return;
    }

    console.log('[CustomNotices] Plugin loaded, waiting for app ready...');

    function patchNoticeCub() {
        console.log('[CustomNotices] Attempting to patch NoticeCub...');

        // Получаем доступ к NoticeCub
        var Notice = Lampa.Notice;
        if (!Notice) {
            console.log('[CustomNotices] Lampa.Notice not found!');
            return false;
        }

        console.log('[CustomNotices] Notice found:', Notice);
        console.log('[CustomNotices] Notice.classes:', Notice.classes);

        if (!Notice.classes || !Notice.classes.cub) {
            console.log('[CustomNotices] NoticeCub not found in Notice.classes');
            return false;
        }

        var cubNotice = Notice.classes.cub;

        // Проверяем, не патчили ли уже
        if (cubNotice._customNoticesPatched) {
            console.log('[CustomNotices] Already patched, skipping');
            return true;
        }

        console.log('[CustomNotices] Found cubNotice:', cubNotice);
        console.log('[CustomNotices] cubNotice.update:', typeof cubNotice.update);

        // Переопределяем метод update
        cubNotice.update = function () {
            console.log('[CustomNotices] ===== update() called =====');

            var Account = Lampa.Account;
            var Lang = Lampa.Lang;
            var Utils = Lampa.Utils;
            var self = this;

            console.log('[CustomNotices] Calling Account.Api.notices...');

            Account.Api.notices(function (result) {
                console.log('[CustomNotices] Got notices result:', result);
                console.log('[CustomNotices] Result type:', typeof result);
                console.log('[CustomNotices] Result length:', result ? result.length : 'null');

                if (result && result.length > 0) {
                    console.log('[CustomNotices] First notice raw:', JSON.stringify(result[0]));
                }

                self.notices = result.map(function (item, index) {
                    console.log('[CustomNotices] Processing item', index, ':', item);
                    console.log('[CustomNotices] item.data type:', typeof item.data);
                    console.log('[CustomNotices] item.data:', item.data);

                    var data;
                    try {
                        data = typeof item.data === 'string' ? JSON.parse(item.data) : item.data;
                        console.log('[CustomNotices] Parsed data:', data);
                    } catch (e) {
                        console.log('[CustomNotices] Failed to parse notice data:', e);
                        return null;
                    }

                    if (!data) {
                        console.log('[CustomNotices] data is null/undefined');
                        return null;
                    }

                    if (!data.card) {
                        console.log('[CustomNotices] data.card is missing');
                        return null;
                    }

                    console.log('[CustomNotices] data.type:', data.type);
                    console.log('[CustomNotices] data.text:', data.text);
                    console.log('[CustomNotices] data.card:', data.card);
                    console.log('[CustomNotices] data.card.seasons:', data.card.seasons);
                    console.log('[CustomNotices] data.card.quality:', data.card.quality);

                    var text = '';
                    var labels = [];

                    // Проверяем кастомный тип уведомления
                    if (data.type === 'custom' || data.type === 'notice') {
                        console.log('[CustomNotices] Using CUSTOM notice format');
                        // Кастомное уведомление — используем text и labels из data
                        text = data.text || '';
                        labels = data.labels || [];
                        console.log('[CustomNotices] Custom text:', text);
                        console.log('[CustomNotices] Custom labels:', labels);
                    } else if (data.card.seasons) {
                        console.log('[CustomNotices] Using NEW EPISODE format');
                        // Стандартное уведомление о новой серии
                        var k = [];
                        for (var i in data.card.seasons) k.push(i);
                        var s = k.pop();

                        labels.push('S - <b>' + s + '</b>');
                        labels.push('E - <b>' + data.card.seasons[s] + '</b>');

                        if (data.voice) labels.push(data.voice);

                        text = Lang.translate('notice_new_episode');
                    } else if (data.card.quality) {
                        console.log('[CustomNotices] Using NEW QUALITY format');
                        // Стандартное уведомление о новом качестве
                        labels.push(Lang.translate('notice_quality') + ' - <b>' + data.card.quality + '</b>');
                        text = Lang.translate('notice_new_quality');
                    } else {
                        console.log('[CustomNotices] Using FALLBACK format');
                        // Fallback — если есть text в data, используем его
                        text = data.text || '';
                        labels = data.labels || [];
                    }

                    // Определяем заголовок
                    var title = !Lang.selected(['ru', 'uk', 'be'])
                        ? (data.card.original_title || data.card.original_name || data.card.title || data.card.name)
                        : (data.card.title || data.card.name || data.card.original_title || data.card.original_name);

                    // Определяем poster
                    var poster = data.card.poster || data.card.img || data.card.poster_path;

                    var result_notice = {
                        time: item.time || (item.date ? Utils.parseToDate(item.date).getTime() : Date.now()),
                        title: title || '',
                        text: text,
                        poster: poster,
                        card: data.card,
                        labels: labels,
                        data: data,
                        item: item
                    };

                    console.log('[CustomNotices] Final notice object:', result_notice);

                    return result_notice;
                }).filter(Boolean);

                console.log('[CustomNotices] Total notices after processing:', self.notices.length);

                self.notices.sort(function (a, b) {
                    return a.time > b.time ? -1 : a.time < b.time ? 1 : 0;
                });

                // Сохраняем в кеш
                if (Lampa.Cache) {
                    Lampa.Cache.rewriteData('other', 'cub_notice', self.notices);
                }

                Notice.drawCount();
                console.log('[CustomNotices] ===== update() complete =====');
            });
        };

        cubNotice._customNoticesPatched = true;

        console.log('[CustomNotices] NoticeCub.update successfully overridden!');

        // Принудительно вызываем update для применения изменений
        console.log('[CustomNotices] Triggering immediate update...');
        cubNotice.update();

        return true;
    }

    // Пробуем патчить сразу (если app уже ready)
    setTimeout(function () {
        console.log('[CustomNotices] Trying immediate patch...');
        if (patchNoticeCub()) {
            console.log('[CustomNotices] Immediate patch successful!');
        } else {
            console.log('[CustomNotices] Immediate patch failed, will retry...');
        }
    }, 100);

    // Также слушаем событие app ready
    Lampa.Listener.follow('app', function (event) {
        if (event.type === 'ready') {
            console.log('[CustomNotices] Got app ready event');
            patchNoticeCub();
        }
    });

    // Резервный вариант - патчим через интервал
    var patchAttempts = 0;
    var patchInterval = setInterval(function () {
        patchAttempts++;
        console.log('[CustomNotices] Retry attempt', patchAttempts);

        if (patchNoticeCub() || patchAttempts >= 10) {
            clearInterval(patchInterval);
            if (patchAttempts >= 10) {
                console.log('[CustomNotices] Gave up after 10 attempts');
            }
        }
    }, 1000);
})();