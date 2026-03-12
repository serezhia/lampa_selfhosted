---
name: lampa-server-api
description: Creates or modifies backend API routes, database schema, and Telegram bot commands for the Lampa Dart Frog server.
---

# Lampa Server API & Bot Development

This skill provides instructions for developing the Dart Frog backend and Telegram Bot for the Lampa Self-Hosted project.

## Core Architecture

We use a **Feature-Sliced Architecture** (Clean Architecture) to share business logic between the REST API and the Telegram Bot.

- **Framework:** Dart Frog (HTTP routes in source/server/routes/).
- **Bot Framework:** Televerse (Bot handlers in lib/features/{feature}/presentation/).
- **Database:** SQLite with Drift ORM (lib/core/database/).
- **Structure:** Code is divided into eatures/ (e.g., uth, ookmarks), each containing data/, domain/, and presentation/ layers.

## Development Guidelines

When asked to implement a backend feature, follow the layered approach:
1. **Data Layer:** Create/update Drift tables and write a Repository (lib/features/{feature}/data/).
2. **Domain Layer:** Write a Service containing business logic (lib/features/{feature}/domain/).
3. **Presentation (REST API):** Add a Dart Frog route that calls the Service (outes/api/{feature}/).
4. **Presentation (Telegram Bot):** Add a bot command handler that calls the Service (lib/features/{feature}/presentation/bot_handlers.dart).

## References & Templates

Please refer to the following files for specific implementation details and templates:

- [Architecture Guide](./architecture-guide.md) - **READ THIS FIRST** to understand the folder structure and layers.
- [REST API Route Template](./api-template.dart) - Standard Dart Frog route.
- [Telegram Bot Template](./bot-template.dart) - Standard Televerse command handler.
- [Database & Drift Guide](./database-guide.md) - Instructions for modifying the DB schema.

## Best Practices

- **Responses:** Always return JSON from API routes ({'success': true} or {'error': 'Message'}).
- **Logging:** Use print('[Component] message') for Docker log visibility.
- **Language:** English for code/variables, Russian for user-facing Telegram bot replies.
