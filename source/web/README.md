# Lampa Web

Система сборки Lampa с автоматическим клонированием из оригинального репозитория и применением патчей.

## Структура

```
lampa_web/
├── Dockerfile                  # Multi-stage сборка с клонированием и патчами
├── patches.json                # Список патчей для self-hosted версии
├── apply-modifications.js      # Скрипт применения патчей
├── custom_plugins/             # Кастомные плагины (hot-reload через volume)
│   ├── modification.js         # Загрузчик плагинов
│   └── sync_player.js          # Синхронный просмотр
└── .dockerignore
```

## Как это работает

### Сборка

1. **Клонирование** - Dockerfile клонирует оригинальный `yumata/lampa-source` из GitHub
2. **Патчинг** - Применяет патчи из `patches.json` через `apply-modifications.js`
3. **Сборка** - Собирает проект через `gulp pack_github`
4. **Nginx** - Финальный образ с nginx для раздачи статики

### Hot-reload плагинов

Кастомные плагины монтируются через volume:
```yaml
volumes:
  - ./lampa_web/custom_plugins:/usr/share/nginx/html/plugins/custom:ro
```

**Чтобы отредактировать плагин:**
1. Откройте файл в `lampa_web/custom_plugins/`
2. Сохраните изменения
3. Обновите страницу в браузере (Ctrl+Shift+R для полной перезагрузки)

Пересборка Docker не требуется!

### Загрузчик плагинов

`modification.js` автоматически загружает:
- Стандартные плагины Lampa из `plugins/`
- Кастомные плагины из `plugins/custom/`

Чтобы добавить новый плагин:
1. Добавьте файл `your_plugin.js` в `lampa_web/custom_plugins/`
2. Откройте `modification.js` и добавьте имя плагина в массив `customPlugins`

## Сборка и запуск

```bash
# Сборка образа
docker-compose build lampa-frontend

# Запуск
docker-compose up -d

# Или сборка с параметрами
docker-compose build --build-arg LAMPA_BRANCH=main lampa-frontend
```

## Патчи

Все патчи описаны в `patches.json`. Основные изменения:

- Замена `cub.rip` на ваш домен
- Использование самостоятельных API доменов
- Настройка TMDB прокси
- Настройка социальных функций

Для изменения домена отредактируйте `patches.json`:
```json
{
  "config": {
    "SELF_HOSTED_DOMAIN": "your-domain.com",
    "CUB_API_DOMAIN": "cub.rip"
  }
}
```

## Преимущества новой архитектуры

✅ **Не храним исходники** - lampa-source клонируется при сборке  
✅ **Всегда актуально** - можно пересобрать с последней версией  
✅ **Hot-reload плагинов** - редактируй и обновляй без пересборки  
✅ **Чистый репозиторий** - только конфигурация и кастомные плагины  
✅ **Легко обновлять** - изменяем патчи, пересобираем образ  

## Обновление Lampa

```bash
# Пересобираем образ (клонирует свежую версию)
docker-compose build --no-cache lampa-frontend

# Перезапускаем
docker-compose up -d lampa-frontend
```

## Разработка плагинов

1. Создайте файл в `lampa_web/custom_plugins/your_plugin.js`
2. Добавьте имя в `modification.js` в массив `customPlugins`
3. Обновите страницу

Плагин должен быть обёрнут в IIFE:
```javascript
(function () {
    'use strict';
    
    // Ваш код плагина
    
})();
```
