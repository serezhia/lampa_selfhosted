# Lampa Self-Hosted - Copilot Instructions

## Architecture Overview

Self-hosted media center based on [Lampa](https://github.com/yumata/lampa-source) with Telegram auth, sync features, and torrent streaming.

**Main components (Docker Compose orchestrated):**
- `lampa-frontend` - Patched Lampa SPA (source/web/) served via nginx
- `lampa-server` - Dart Frog backend (source/server/) with SQLite/Drift
- `nginx` - Reverse proxy with optional Let's Encrypt
- `jackett` - Torrent indexer proxy
- `torrserver` - Torrent streaming

**Data flow:**
```
Browser → nginx → lampa-frontend (SPA)
              ↓
      lampa-server (API + WebSocket)
              ↓
    SQLite database (data/database/)
```

## Backend (source/server/)

**Framework:** [Dart Frog](https://dartfrog.vgv.dev/) with file-based routing

**Key patterns:**
- Routes map to `routes/` directory structure (e.g., `routes/api/bookmarks/sync.dart` → `POST /api/bookmarks/sync`)
- Middleware at `routes/api/_middleware.dart` handles auth via `token` header
- Singleton services: `DataSource.instance`, `TelegramBotService.instance`, `SyncPlayerService.instance`
- Database uses Drift ORM with code generation (`dart run build_runner build`)

**Auth flow:**
1. User registers via Telegram bot → gets 6-digit code
2. Frontend submits code to `/api/device/add`
3. Server validates and returns token stored in `Lampa.Storage`
4. Subsequent requests include `token` + `profile` headers

**Adding a new API endpoint:**
```dart
// routes/api/example/action.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  final profile = context.read<db.Profile?>(); // Injected by middleware
  // ... handler logic
  return Response.json(body: {'success': true});
}
```

## Frontend Plugins (source/web/custom_plugins/)

**Plugin loading:** `modification.js` fetches `/plugins/manifest.json` and loads plugins sequentially.

**Load order:** auth → default_settings → jackett_proxy → custom_notices → sync_player → transcoding → online

**Plugin structure:**
```javascript
(function() {
    'use strict';
    // Use Lampa.* APIs: Storage, Activity, Template, Noty, etc.
    // Consult DeepWiki for yumata/lampa-source docs before writing
})();
```

**Override mechanism:** User plugins in `data/plugins/` override builtin plugins by filename. No rebuild needed—just restart container.

## Build & Patching

**Frontend build (source/web/Dockerfile):**
1. Clones `yumata/lampa-source` from GitHub
2. Applies patches from `patches.json` via `apply-modifications.js`
3. Runs `gulp pack_github` → outputs to `build/github/lampa/`

**patches.json format:**
```json
{
  "config": { "SELF_HOSTED_DOMAIN": "your-domain.com" },
  "patches": [
    { "file": "src/core/socket.js", "search": "...", "replace": "..." }
  ]
}
```

## Development Commands

```bash
# Full stack
docker compose up -d --build

# Rebuild specific service
docker compose up -d --build lampa-frontend

# Regenerate Drift database code
cd source/server && dart run build_runner build --delete-conflicting-outputs

# Run server locally (requires Dart SDK)
cd source/server && dart_frog dev

# View logs
docker compose logs -f lampa-server
```

## Key Files Reference

| Purpose | Location |
|---------|----------|
| Docker orchestration | [docker-compose.yml](../docker-compose.yml) |
| Environment config | `.env` (from [.env.example](../.env.example)) |
| Frontend patching | [source/web/patches.json](../source/web/patches.json) |
| API auth middleware | [source/server/routes/api/_middleware.dart](../source/server/routes/api/_middleware.dart) |
| Database schema | [source/server/lib/database/database.dart](../source/server/lib/database/database.dart) |
| Telegram bot commands | [source/server/lib/telegram_bot.dart](../source/server/lib/telegram_bot.dart) |
| Sync Player WebSocket | [source/server/lib/sync_player_service.dart](../source/server/lib/sync_player_service.dart) |

## Conventions

- **Backend:** Dart 3.0+, Drift for DB, Televerse for Telegram
- **Frontend plugins:** ES5 syntax (no modules), IIFE pattern, access Lampa APIs globally
- **API responses:** `{'success': bool, ...}` or `{'error': string}`
- **Logging:** `print('[ServiceName] message')` with flush for Docker visibility
- **Language:** Russian comments/UI, English code
