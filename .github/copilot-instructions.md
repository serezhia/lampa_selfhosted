# Lampa Self-Hosted - Copilot Instructions

You are an expert full-stack developer assisting with the **Lampa Self-Hosted** project. This project is a self-hosted media center based on [Lampa](https://github.com/yumata/lampa-source) with a custom Dart Frog backend, Telegram authentication, sync features, and torrent streaming.

## 🧠 Agent Skills & Knowledge Base

This project uses **Agent Skills** to provide detailed, context-specific instructions. You MUST rely on these skills when working on specific parts of the stack:

1. **Backend & Bot (lampa-server-api)**: 
   - Use when modifying source/server/.
   - Covers Dart Frog routing, Drift database schema, and Televerse Telegram bot commands.
   - *Action:* Refer to .github/skills/lampa-server-api/SKILL.md and its templates.

2. **Frontend Plugins (lampa-web-plugin)**: 
   - Use when modifying source/web/custom_plugins/.
   - Covers ES5 syntax, IIFE patterns, and Lampa global APIs.
   - *Action:* Refer to .github/skills/lampa-web-plugin/SKILL.md and its templates.

3. **Full-Stack Features (`lampa-fullstack-feature`)**:
   - Use when creating a complex feature that requires database changes, API endpoints, Telegram bot commands, and frontend UI.
   - Provides the step-by-step architectural workflow.
   - *Action:* Refer to `.github/skills/lampa-fullstack-feature/SKILL.md`.

4. **DeepWiki (CRITICAL FOR FRONTEND)**:
   - When working on frontend plugins, you **MUST** use the mcp_deepwiki tool to query the yumata/lampa-source repository.
   - Use it to understand how Lampa core components (Lampa.Activity, Lampa.Storage, Lampa.Network, etc.) work before writing code.

## 🏗️ Architecture Overview

**Main components (Docker Compose orchestrated):**
- lampa-frontend - Patched Lampa SPA (source/web/) served via nginx.
- lampa-server - Dart Frog backend (source/server/) with SQLite/Drift.
- 
ginx - Reverse proxy with optional Let's Encrypt.
- jacred - Jackett-compatible torrent indexer aggregator.
- 	orrserver - Torrent streaming.

**Data flow:**
Browser → nginx → lampa-frontend (SPA) → lampa-server (API + WebSocket) → SQLite database

## 🛠️ Build & Patching (Frontend)

The frontend is not built from scratch. Instead, it clones the original Lampa repository and patches it during the Docker build:
1. Clones yumata/lampa-source from GitHub.
2. Applies patches defined in source/web/patches.json via pply-modifications.js.
3. Runs gulp pack_github to output the final build.

**To modify core Lampa behavior:** Add a patch to patches.json (search and replace).
**To add features:** Create a custom plugin in source/web/custom_plugins/.

## 💻 Development Commands

`ash
# Full stack startup
docker compose up -d --build

# Rebuild specific service (e.g., after changing a plugin or backend code)
docker compose up -d --build lampa-frontend
docker compose up -d --build lampa-server

# Regenerate Drift database code (CRITICAL after DB schema changes)
cd source/server && dart run build_runner build --delete-conflicting-outputs

# View backend logs
docker compose logs -f lampa-server
`

## 📝 General Conventions

- **Language:** Write code variables and logic in **English**. Write UI text, Telegram bot responses, and user-facing comments in **Russian**.
- **Backend:** Dart 3.0+, always return JSON {'success': true} or {'error': '...'}.
- **Frontend:** Strict ES5 (no let/const/=>), use ar and unction(). No ES6 modules.
- **Logging:** Use print('[Component] message') in Dart for Docker log visibility.
