// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Таблица пользователей
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get passwordHash => text().named('password_hash')();
  IntColumn get premium => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get telegramId => text().named('telegram_id').nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get firstName => text().named('first_name').nullable()();
  TextColumn get lastName => text().named('last_name').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Таблица профилей
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().named('user_id').references(Users, #id)();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('l_1'))();
  IntColumn get age => integer().withDefault(const Constant(18))();
  BoolColumn get adult => boolean().withDefault(const Constant(true))();
  BoolColumn get main => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}

/// Таблица устройств
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id').references(Users, #id)();
  TextColumn get name => text().withDefault(const Constant('Unknown'))();
  TextColumn get platform => text().withDefault(const Constant('unknown'))();
  TextColumn get token => text().unique()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeen => dateTime().named('last_seen').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Таблица закладок
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().named('profile_id').references(Profiles, #id)();
  TextColumn get type => text().withDefault(const Constant('like'))();
  IntColumn get cardId => integer().named('card_id')();
  TextColumn get data => text()(); // JSON string
  IntColumn get time => integer()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, type, cardId},
      ];
}

/// Таблица записей таймлайна (история просмотров)
class TimelineEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().named('profile_id').references(Profiles, #id)();
  TextColumn get hash => text()();
  RealColumn get percent => real().withDefault(const Constant(0))();
  RealColumn get time => real().withDefault(const Constant(0))();
  RealColumn get duration => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, hash},
      ];
}

/// Таблица изменений закладок (для синхронизации)
class BookmarkChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().named('profile_id').references(Profiles, #id)();
  IntColumn get version => integer()();
  TextColumn get action => text()(); // 'add' or 'remove'
  IntColumn get entityId => integer().named('entity_id')();
  TextColumn get type => text().nullable()();
  IntColumn get cardId => integer().named('card_id').nullable()();
  TextColumn get data => text().withDefault(const Constant('{}'))();
  IntColumn get time => integer()();
}

/// Таблица версий профилей
class ProfileVersions extends Table {
  IntColumn get profileId =>
      integer().named('profile_id').references(Profiles, #id)();
  IntColumn get bookmarkVersion =>
      integer().named('bookmark_version').withDefault(const Constant(0))();
  IntColumn get timelineVersion =>
      integer().named('timeline_version').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// Таблица уведомлений (notices)
/// type: 'simple' - произвольное уведомление (title, text, image)
/// type: 'card' - уведомление о фильме/сериале (data содержит JSON с card)
class Notices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noticeType => text()
      .named('type')
      .withDefault(const Constant('simple'))(); // 'simple' or 'card'
  TextColumn get title => text().nullable()();
  TextColumn get noticeText => text().named('notice_text').nullable()();
  TextColumn get image => text().nullable()();
  TextColumn get data => text().nullable()(); // JSON string для card type
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().named('expires_at').nullable()();
}

@DriftDatabase(
  tables: [
    Users,
    Profiles,
    Devices,
    Bookmarks,
    TimelineEntries,
    BookmarkChanges,
    ProfileVersions,
    Notices,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(notices);
        }
      },
    );
  }

  // =============== Users ===============

  Future<User?> getUserById(String id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<User?> getUserByTelegramId(String telegramId) =>
      (select(users)..where((u) => u.telegramId.equals(telegramId)))
          .getSingleOrNull();

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User> insertUser(UsersCompanion user) async {
    await into(users).insert(user);
    return (await getUserById(user.id.value))!;
  }

  Future<void> updateUser(User user) => update(users).replace(user);

  // =============== Profiles ===============

  Future<Profile?> getProfileById(int id) =>
      (select(profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<List<Profile>> getProfilesByUserId(String userId) =>
      (select(profiles)..where((p) => p.userId.equals(userId))).get();

  Future<Profile?> getMainProfile(String userId) => (select(profiles)
        ..where((p) => p.userId.equals(userId) & p.main.equals(true)))
      .getSingleOrNull();

  Future<Profile> insertProfile(ProfilesCompanion profile) async {
    final id = await into(profiles).insert(profile);
    return (await getProfileById(id))!;
  }

  Future<void> updateProfile(Profile profile) =>
      update(profiles).replace(profile);

  Future<void> deleteProfile(int id) =>
      (delete(profiles)..where((p) => p.id.equals(id))).go();

  /// Удаляет все закладки профиля
  Future<void> deleteBookmarksByProfileId(int profileId) =>
      (delete(bookmarks)..where((b) => b.profileId.equals(profileId))).go();

  /// Удаляет все записи timeline профиля
  Future<void> deleteTimelineByProfileId(int profileId) =>
      (delete(timelineEntries)..where((t) => t.profileId.equals(profileId)))
          .go();

  /// Удаляет все изменения закладок профиля
  Future<void> deleteBookmarkChangesByProfileId(int profileId) =>
      (delete(bookmarkChanges)..where((c) => c.profileId.equals(profileId)))
          .go();

  /// Удаляет версию профиля
  Future<void> deleteProfileVersion(int profileId) =>
      (delete(profileVersions)..where((v) => v.profileId.equals(profileId)))
          .go();

  // =============== Devices ===============

  Future<Device?> getDeviceById(String id) =>
      (select(devices)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<Device?> getDeviceByToken(String token) =>
      (select(devices)..where((d) => d.token.equals(token))).getSingleOrNull();

  Future<List<Device>> getDevicesByUserId(String userId) =>
      (select(devices)..where((d) => d.userId.equals(userId))).get();

  Future<Device> insertDevice(DevicesCompanion device) async {
    await into(devices).insert(device);
    return (await getDeviceById(device.id.value))!;
  }

  Future<void> updateDevice(Device device) => update(devices).replace(device);

  Future<void> updateDeviceLastSeen(String id) =>
      (update(devices)..where((d) => d.id.equals(id)))
          .write(DevicesCompanion(lastSeen: Value(DateTime.now())));

  Future<void> deleteDevice(String id) =>
      (delete(devices)..where((d) => d.id.equals(id))).go();

  // =============== Bookmarks ===============

  Future<Bookmark?> getBookmarkById(int id) =>
      (select(bookmarks)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<List<Bookmark>> getBookmarksByProfileId(int profileId) =>
      (select(bookmarks)..where((b) => b.profileId.equals(profileId))).get();

  Future<Bookmark?> getBookmarkByProfileTypeCard(
    int profileId,
    String type,
    int cardId,
  ) =>
      (select(bookmarks)
            ..where(
              (b) =>
                  b.profileId.equals(profileId) &
                  b.type.equals(type) &
                  b.cardId.equals(cardId),
            ))
          .getSingleOrNull();

  Future<Bookmark> insertBookmark(BookmarksCompanion bookmark) async {
    final id = await into(bookmarks).insert(bookmark);
    return (await getBookmarkById(id))!;
  }

  Future<void> deleteBookmark(int id) =>
      (delete(bookmarks)..where((b) => b.id.equals(id))).go();

  Future<void> deleteBookmarkByProfileTypeCard(
    int profileId,
    String type,
    int cardId,
  ) =>
      (delete(bookmarks)
            ..where(
              (b) =>
                  b.profileId.equals(profileId) &
                  b.type.equals(type) &
                  b.cardId.equals(cardId),
            ))
          .go();

  // =============== Timeline ===============

  Future<TimelineEntry?> getTimelineEntry(int profileId, String hash) =>
      (select(timelineEntries)
            ..where((t) => t.profileId.equals(profileId) & t.hash.equals(hash)))
          .getSingleOrNull();

  Future<List<TimelineEntry>> getTimelineByProfileId(int profileId) =>
      (select(timelineEntries)..where((t) => t.profileId.equals(profileId)))
          .get();

  Future<void> upsertTimelineEntry(TimelineEntriesCompanion entry) async {
    await into(timelineEntries).insertOnConflictUpdate(entry);
  }

  // =============== Bookmark Changes ===============

  Future<List<BookmarkChange>> getBookmarkChanges(
    int profileId,
    int sinceVersion,
  ) =>
      (select(bookmarkChanges)
            ..where(
              (c) =>
                  c.profileId.equals(profileId) &
                  c.version.isBiggerThan(Variable(sinceVersion)),
            )
            ..orderBy([(c) => OrderingTerm.asc(c.version)]))
          .get();

  Future<void> insertBookmarkChange(BookmarkChangesCompanion change) =>
      into(bookmarkChanges).insert(change);

  // =============== Profile Versions ===============

  Future<ProfileVersion?> getProfileVersion(int profileId) =>
      (select(profileVersions)..where((v) => v.profileId.equals(profileId)))
          .getSingleOrNull();

  Future<int> incrementBookmarkVersion(int profileId) async {
    final pv = await getProfileVersion(profileId);
    final newVersion = (pv?.bookmarkVersion ?? 0) + 1;

    await into(profileVersions).insertOnConflictUpdate(
      ProfileVersionsCompanion(
        profileId: Value(profileId),
        bookmarkVersion: Value(newVersion),
        timelineVersion: Value(pv?.timelineVersion ?? 0),
      ),
    );
    return newVersion;
  }

  Future<int> incrementTimelineVersion(int profileId) async {
    final pv = await getProfileVersion(profileId);
    final newVersion = (pv?.timelineVersion ?? 0) + 1;

    await into(profileVersions).insertOnConflictUpdate(
      ProfileVersionsCompanion(
        profileId: Value(profileId),
        bookmarkVersion: Value(pv?.bookmarkVersion ?? 0),
        timelineVersion: Value(newVersion),
      ),
    );
    return newVersion;
  }

  // =============== Notices ===============

  Future<Notice?> getNoticeById(int id) =>
      (select(notices)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<List<Notice>> getAllNotices() =>
      (select(notices)..orderBy([(n) => OrderingTerm.desc(n.createdAt)])).get();

  Future<List<Notice>> getActiveNotices() {
    final now = DateTime.now();
    return (select(notices)
          ..where(
            (n) =>
                n.active.equals(true) &
                (n.expiresAt.isNull() | n.expiresAt.isBiggerThanValue(now)),
          )
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();
  }

  Future<Notice> insertNotice(NoticesCompanion notice) async {
    final id = await into(notices).insert(notice);
    return (await getNoticeById(id))!;
  }

  Future<void> updateNotice(Notice notice) => update(notices).replace(notice);

  Future<void> deleteNotice(int id) =>
      (delete(notices)..where((n) => n.id.equals(id))).go();

  Future<void> toggleNoticeActive(int id, {required bool active}) async {
    await (update(notices)..where((n) => n.id.equals(id)))
        .write(NoticesCompanion(active: Value(active)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Use /app/data for persistent storage in Docker
    final dbFolder = Directory('/app/data');
    if (!dbFolder.existsSync()) {
      dbFolder.createSync(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'lampa.db'));
    return NativeDatabase.createInBackground(file);
  });
}
