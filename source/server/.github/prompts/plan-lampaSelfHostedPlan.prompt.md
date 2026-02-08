## Plan: Self-hosted Dart Frog Server для Lampa

Создание собственного сервера синхронизации на Dart Frog, который заменит CUB API для закладок, таймлайнов и профилей. Сервер будет использовать токен-авторизацию и поддерживать WebSocket для real-time синхронизации между устройствами.

### Steps

1. **Создать модели данных** в `lampa_server/lib/models/` — `User`, `Profile`, `Bookmark`, `TimelineEntry`, `Device`, `Session`

2. **Реализовать аутентификацию** — эндпоинты `/api/device/add`, генерация токенов, middleware проверки заголовков `token` и `profile`

3. **Добавить эндпоинты профилей** — `/api/profile/all` (GET), `/api/profile/add` (POST) с поддержкой до 8 профилей

4. **Реализовать API закладок** — `/api/bookmarks/add|remove|dump|changelog|clear|upload` с версионированием для инкрементальной синхронизации

5. **Добавить API таймлайнов** — `/api/timeline/dump`, `/api/timeline/changelog` для хранения прогресса просмотра

6. **Настроить WebSocket** — методы `timeline`, `bookmarks`, `devices`, `open` для real-time синхронизации между устройствами

7. **Подменить URL в Lampa** — переопределить `Manifest.cub_domain` через настройки или патч `src/utils/manifest.js` на адрес своего сервера

---

### Модели данных

| Модель | Поля |
|--------|------|
| **User** | `id`, `email`, `password_hash`, `premium`, `created_at` |
| **Profile** | `id`, `user_id`, `name`, `icon`, `main`, `child` |
| **Bookmark** | `id`, `cid`, `card_id`, `type` (like/wath/book/history/look/viewed/scheduled/continued/thrown), `data` (JSON card), `profile_id`, `time`, `version` |
| **TimelineEntry** | `hash`, `percent`, `time`, `duration`, `profile_id`, `updated_at`, `version` |
| **Device** | `id`, `user_id`, `name`, `platform`, `token`, `last_seen` |
| **Session** | `token`, `user_id`, `device_id`, `created_at` |

---

### API Endpoints

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/device/add` | Авторизация по 6-значному коду → токен |
| GET | `/api/user/info` | Данные текущего пользователя |
| GET | `/api/profile/all` | Все профили пользователя |
| POST | `/api/profile/add` | Создать профиль `{name, icon, child}` |
| POST | `/api/bookmarks/add` | Добавить закладку `{card_id, type, data}` |
| POST | `/api/bookmarks/remove` | Удалить `{card_id, type}` |
| GET | `/api/bookmarks/dump` | Полный дамп закладок профиля |
| GET | `/api/bookmarks/changelog?version=N` | Изменения с версии N |
| POST | `/api/bookmarks/clear` | Очистить тип `{type}` |
| POST | `/api/bookmarks/upload` | Загрузить локальные (FormData) |
| GET | `/api/timeline/dump` | Полный дамп таймлайнов |
| GET | `/api/timeline/changelog?version=N` | Изменения с версии N |
| WSS | `/ws` | Real-time sync: `timeline`, `bookmarks`, `devices` |

---

### Подмена сервера CUB

**Вариант B:** Патч при сборке
- В `lampa-source/gulpfile.js` добавить замену домена при `gulp build`
- Все обращения к API идут через `Utils.protocol() + Manifest.cub_domain + '/api/'`
- Так же в интерфейсе посмотреть и заменить cub на свой сервер

---

1. **База данных?** SQLite для простоты + drift
2. **WebSocket обязателен** для real-time sync между устройствами
3. **Регистрация пользователей?** Реализовать свою форму простенькую (пароль логин, без восстановления пароля пока)
