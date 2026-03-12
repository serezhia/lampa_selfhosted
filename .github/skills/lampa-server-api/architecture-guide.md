# Lampa Server Architecture Guide

To keep the backend scalable, maintainable, and clean, we use a **Feature-Sliced Architecture** (Vertical Slicing) combined with **Clean Architecture** principles. 

Since our backend serves two primary interfaces—a **REST API** (via Dart Frog) and a **Telegram Bot** (via Televerse)—this architecture ensures business logic is shared and not duplicated.

## Directory Structure

```text
source/server/
├── routes/                     # Dart Frog HTTP Presentation Layer (Required by framework)
│   └── api/
│       ├── bookmarks/          # HTTP endpoints for bookmarks
│       ├── users/              # HTTP endpoints for users
│       └── _middleware.dart    # HTTP Auth & DI injection
│
└── lib/
    ├── core/                   # Shared Infrastructure
    │   ├── database/           # Drift setup, tables, and migrations
    │   ├── telegram/           # Bot initialization, global middleware
    │   ├── network/            # External API clients (e.g., Jackett)
    │   └── utils/              # Helpers, constants, extensions
    │
    ├── di/                     # Dependency Injection
    │   └── locator.dart        # Service locator (e.g., using get_it)
    │
    └── features/               # Vertical Feature Slices
        ├── bookmarks/
        │   ├── data/           # Repositories (talks to Drift DB)
        │   ├── domain/         # Business logic (Services, Entities)
        │   └── presentation/   # Telegram Bot handlers for this feature
        │
        └── users/
            ├── data/
            ├── domain/
            └── presentation/
```

## Feature Planning (CRITICAL)

Before writing any code for a new feature, you **MUST** create a Markdown file describing the feature and its development plan. This file should be placed in the root of the feature directory (e.g., `lib/features/{feature}/PLAN.md` or in the project root if it's a massive full-stack feature).

The plan must include:
1. **Overview:** What the feature does.
2. **Data Layer:** Required database tables, columns, and queries.
3. **Domain Layer:** Core business logic and services needed.
4. **Presentation Layer:** 
   - REST API endpoints (methods, paths, request/response bodies).
   - Telegram Bot commands and expected interactions.
5. **Step-by-Step Implementation Plan:** A checklist of tasks to complete the feature.

## The Layers Explained

### 1. Presentation Layer (HTTP & Telegram)
The presentation layer is responsible for receiving input and returning output. It contains **NO business logic**.
- **HTTP (Dart Frog):** Located in `routes/`. Parses JSON, calls the Domain Service, and returns a JSON response.
- **Telegram Bot:** Located in `lib/features/{feature}/presentation/bot_handlers.dart`. Parses Telegram messages/callbacks, calls the Domain Service, and sends a Telegram message back.

### 2. Domain Layer (Business Logic)
Located in `lib/features/{feature}/domain/`.
- **Services:** Contains the core business rules. It orchestrates data from repositories.
- **Entities:** Pure Dart classes representing business objects (independent of the database or HTTP).
- *Rule:* The Domain layer does not know about HTTP requests, Telegram contexts, or SQL queries.

### 3. Data Layer (Repositories)
Located in `lib/features/{feature}/data/`.
- **Repositories:** Abstracts the database (Drift). It executes SQL queries and returns Domain Entities.
- *Rule:* Only the Data layer interacts directly with the Drift database instance.

## Example: "Bookmarks" Feature

**1. Data Layer (`lib/features/bookmarks/data/bookmarks_repository.dart`)**
```dart
class BookmarksRepository {
  final AppDatabase _db;
  BookmarksRepository(this._db);

  Future<List<Bookmark>> getUserBookmarks(int userId) async {
    // Execute Drift query
    return await (_db.select(_db.bookmarks)..where((t) => t.userId.equals(userId))).get();
  }
}
```

**2. Domain Layer (`lib/features/bookmarks/domain/bookmarks_service.dart`)**
```dart
class BookmarksService {
  final BookmarksRepository _repository;
  BookmarksService(this._repository);

  Future<List<Bookmark>> getBookmarksForUser(int userId) async {
    // Business logic (e.g., filtering, sorting, validation)
    return await _repository.getUserBookmarks(userId);
  }
}
```

**3. Presentation: HTTP (`routes/api/bookmarks/index.dart`)**
```dart
Future<Response> onRequest(RequestContext context) async {
  final profile = context.read<Profile>();
  final service = locator<BookmarksService>(); // Get from DI
  
  final bookmarks = await service.getBookmarksForUser(profile.id);
  return Response.json(body: {'success': true, 'data': bookmarks});
}
```

**4. Presentation: Telegram (`lib/features/bookmarks/presentation/bot_handlers.dart`)**
```dart
void registerBookmarksHandlers(Bot bot) {
  bot.command('bookmarks', (ctx) async {
    final telegramId = ctx.from?.id;
    final service = locator<BookmarksService>(); // Get from DI
    
    // Note: You'd typically resolve the internal userId from the telegramId first
    final bookmarks = await service.getBookmarksForUser(internalUserId);
    
    await ctx.reply('Ваши закладки: ...');
  });
}
```

## Refactoring Strategy (How to migrate)
1. **Setup Core:** Move existing `database.dart` to `lib/core/database/`. Setup a simple DI locator in `lib/di/locator.dart`.
2. **Extract Features:** Take one massive file (like `data_source.dart` or `telegram_bot.dart`) and start breaking it down feature by feature (e.g., move all user-related DB queries to `UserRepository`).
3. **Wire up Bot:** Create a central `lib/core/telegram/bot_setup.dart` that imports all feature `bot_handlers.dart` and registers them.
