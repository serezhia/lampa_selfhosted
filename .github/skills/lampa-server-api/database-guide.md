# Database & Drift Guide

The Lampa backend uses SQLite with the **Drift** ORM.

## Schema Location
The database schema and queries are defined in:
`source/server/lib/database/database.dart`

## Adding a New Table

1. Define the table class extending `Table`:
```dart
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(Profiles, #id)();
  TextColumn get theme => text().withDefault(const Constant('dark'))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
}
```

2. Add the table to the `@DriftDatabase` annotation on the `AppDatabase` class:
```dart
@DriftDatabase(tables: [Profiles, Devices, UserSettings])
class AppDatabase extends _$AppDatabase { ... }
```

3. Add helper methods in `DataSource` (e.g., `source/server/lib/data_source.dart`):
```dart
Future<UserSetting> getSettings(int profileId) async {
  return await (db.select(db.userSettings)..where((t) => t.profileId.equals(profileId))).getSingle();
}
```

## Regenerating Code (CRITICAL)

Whenever you modify `database.dart` (add a table, change a column, add a query), you **MUST** regenerate the Drift boilerplate code.

Run this command in the terminal:
```bash
cd source/server
dart run build_runner build --delete-conflicting-outputs
```

If you don't run this, the Dart code will not compile, and the new tables/columns will not be available.
