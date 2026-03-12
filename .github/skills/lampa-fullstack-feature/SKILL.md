---
name: lampa-fullstack-feature
description: Guides the development of a complete feature spanning the Lampa frontend plugin, Dart Frog backend API, database, and Telegram bot.
---

# Lampa Full-Stack Feature Development

This skill provides the architectural workflow for creating a new feature that requires both UI changes (frontend plugin) and backend logic (API, Database, Telegram Bot).

## Development Workflow

When asked to implement a full-stack feature, **always follow this order of implementation**:

### Step 1: Database Schema (Backend)
1. Define the state and data models required for the feature.
2. Add the new table or columns to `source/server/lib/database/database.dart` using Drift ORM.
3. **CRITICAL:** Run the code generator:
   ```bash
   cd source/server && dart run build_runner build --delete-conflicting-outputs
   ```
4. Add helper methods to `DataSource` (`source/server/lib/data_source.dart`) to interact with the new data.
*Reference: Use the `/lampa-server-api` skill for database templates.*

### Step 2: REST API (Backend)
1. Create new endpoints in `source/server/routes/api/` to expose the data or actions to the frontend.
2. Ensure the route uses the `Profile` injected by `_middleware.dart` for authentication.
3. Return standard JSON responses: `{'success': true, 'data': ...}`.
*Reference: Use the `/lampa-server-api` skill for API route templates.*

### Step 3: Telegram Bot (Backend)
1. If the feature requires user notifications or remote control, add commands to `source/server/lib/telegram_bot.dart`.
2. Use the `televerse` package to handle commands (e.g., `/myfeature`) or inline callbacks.
3. Write bot responses in **Russian**.
*Reference: Use the `/lampa-server-api` skill for bot templates.*

### Step 4: Frontend Plugin (Web)
1. Create a new plugin in `source/web/custom_plugins/` (e.g., `my_feature.js`).
2. **CRITICAL:** Use the `mcp_deepwiki` tool to search the `yumata/lampa-source` repository to understand which Lampa UI components to use (e.g., `Lampa.Activity`, `Lampa.Template`, `Lampa.Menu`).
3. Use `Lampa.Network` (or `Lampa.Reguest`) to call the new API endpoints created in Step 2.
4. Ensure the plugin is wrapped in an IIFE and uses ES5 syntax.
5. Add the plugin to `source/web/patches.json` or `modification.js` so it loads on startup.
*Reference: Use the `/lampa-web-plugin` skill for plugin templates.*

## Example Feature: "Watch Later List"
- **DB:** Create `WatchLater` table in Drift.
- **API:** `POST /api/watch_later/add`, `GET /api/watch_later/list`.
- **Bot:** `/watchlater` command to show the list in Telegram.
- **Plugin:** Add a "Watch Later" button to the movie card (`Lampa.Component`) that calls the API, and a new menu item (`Lampa.Menu`) to view the list.
