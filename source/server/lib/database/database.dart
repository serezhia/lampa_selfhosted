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
  BoolColumn get blocked => boolean().withDefault(const Constant(false))();

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

/// Таблица настроек приложения (key-value)
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Таблица ожидающих регистраций (для режима одобрения админом)
class PendingRegistrations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get telegramId => text().named('telegram_id')();
  TextColumn get phone => text()();
  TextColumn get firstName => text().named('first_name').nullable()();
  TextColumn get lastName => text().named('last_name').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}

/// Таблица инвайт-кодов для регистрации
class InviteCodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  BoolColumn get oneTime =>
      boolean().named('one_time').withDefault(const Constant(true))();
  IntColumn get usesLeft =>
      integer().named('uses_left').withDefault(const Constant(1))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().named('expires_at').nullable()();
}

/// Таблица локальной библиотеки (загрузки)
class LibraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id').references(Users, #id)();
  IntColumn get tmdbId => integer().named('tmdb_id')();
  TextColumn get type => text()(); // 'movie' or 'tv'
  IntColumn get season => integer().nullable()();
  IntColumn get episode => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get poster => text().nullable()();
  TextColumn get magnetUri => text().named('magnet_uri')();
  TextColumn get status =>
      text()(); // 'pending', 'downloading', 'transcoding', 'ready', 'error'
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().named('error_message').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
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
    Settings,
    PendingRegistrations,
    InviteCodes,
    LibraryItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

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
        if (from < 3) {
          // Add blocked column to users
          await m.addColumn(users, users.blocked);
          // Create new tables
          await m.createTable(settings);
          await m.createTable(pendingRegistrations);
          await m.createTable(inviteCodes);
        }
        if (from < 4) {
          await m.createTable(libraryItems);
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

  /// Получить пользователей с пагинацией
  Future<(List<User>, int)> getUsersPage({
    required int offset,
    required int limit,
  }) async {
    final count =
        await (selectOnly(users)..addColumns([countAll()])).getSingle();
    final totalCount = count.read(countAll()) ?? 0;

    final userList = await (select(users)..limit(limit, offset: offset)).get();
    return (userList, totalCount);
  }

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

  // =============== Settings ===============

  Future<String?> getSetting(String key) async {
    final setting = await (select(settings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  // =============== Pending Registrations ===============

  Future<List<PendingRegistration>> getAllPendingRegistrations() =>
      (select(pendingRegistrations)
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get();

  /// Получить ожидающие регистрации с пагинацией
  Future<(List<PendingRegistration>, int)> getPendingRegistrationsPage({
    required int offset,
    required int limit,
  }) async {
    final count = await (selectOnly(pendingRegistrations)
          ..addColumns([countAll()]))
        .getSingle();
    final totalCount = count.read(countAll()) ?? 0;

    final list = await (select(pendingRegistrations)
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit, offset: offset))
        .get();
    return (list, totalCount);
  }

  Future<PendingRegistration?> getPendingRegistrationById(int id) =>
      (select(pendingRegistrations)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  Future<PendingRegistration?> getPendingRegistrationByTelegramId(
    String telegramId,
  ) =>
      (select(pendingRegistrations)
            ..where((p) => p.telegramId.equals(telegramId)))
          .getSingleOrNull();

  Future<PendingRegistration> insertPendingRegistration(
    PendingRegistrationsCompanion registration,
  ) async {
    final id = await into(pendingRegistrations).insert(registration);
    return (await getPendingRegistrationById(id))!;
  }

  Future<void> deletePendingRegistration(int id) =>
      (delete(pendingRegistrations)..where((p) => p.id.equals(id))).go();

  Future<void> deletePendingRegistrationByTelegramId(String telegramId) =>
      (delete(pendingRegistrations)
            ..where((p) => p.telegramId.equals(telegramId)))
          .go();

  // =============== Invite Codes ===============

  Future<List<InviteCode>> getAllInviteCodes() =>
      (select(inviteCodes)..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
          .get();

  Future<InviteCode?> getInviteCodeById(int id) =>
      (select(inviteCodes)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<InviteCode?> getInviteCodeByCode(String code) =>
      (select(inviteCodes)..where((c) => c.code.equals(code)))
          .getSingleOrNull();

  Future<InviteCode> insertInviteCode(InviteCodesCompanion code) async {
    final id = await into(inviteCodes).insert(code);
    return (await getInviteCodeById(id))!;
  }

  Future<void> updateInviteCode(InviteCode code) =>
      update(inviteCodes).replace(code);

  Future<void> deleteInviteCode(int id) =>
      (delete(inviteCodes)..where((c) => c.id.equals(id))).go();

  /// Использовать инвайт-код. Возвращает true если код валиден и был использован
  /// Операция атомарная - защита от race condition
  Future<bool> useInviteCode(String code) async {
    final now = DateTime.now();

    // Атомарно уменьшаем uses_left на 1 только если код существует, не истёк и ещё доступен
    final affectedRows = await (update(inviteCodes)
          ..where(
            (c) =>
                c.code.equals(code) &
                c.usesLeft.isBiggerThanValue(0) &
                (c.expiresAt.isNull() | c.expiresAt.isBiggerThanValue(now)),
          ))
        .write(
      InviteCodesCompanion.custom(
        usesLeft: const CustomExpression<int>('uses_left - 1'),
      ),
    );

    return affectedRows > 0;
  }

  // =============== User blocking ===============

  Future<void> blockUser(String userId) async {
    await (update(users)..where((u) => u.id.equals(userId)))
        .write(const UsersCompanion(blocked: Value(true)));
  }

  Future<void> unblockUser(String userId) async {
    await (update(users)..where((u) => u.id.equals(userId)))
        .write(const UsersCompanion(blocked: Value(false)));
  }

  /// Удаление пользователя и всех связанных данных (атомарно)
  Future<void> deleteUserWithData(String userId) async {
    await transaction(() async {
      // Получаем все профили пользователя
      final userProfiles = await getProfilesByUserId(userId);

      // Для каждого профиля удаляем связанные данные
      for (final profile in userProfiles) {
        await (delete(bookmarks)..where((b) => b.profileId.equals(profile.id)))
            .go();
        await (delete(timelineEntries)
              ..where((t) => t.profileId.equals(profile.id)))
            .go();
        await (delete(bookmarkChanges)
              ..where((c) => c.profileId.equals(profile.id)))
            .go();
        await (delete(profileVersions)
              ..where((v) => v.profileId.equals(profile.id)))
            .go();
      }

      // Удаляем профили
      await (delete(profiles)..where((p) => p.userId.equals(userId))).go();

      // Удаляем устройства
      await (delete(devices)..where((d) => d.userId.equals(userId))).go();

      // Удаляем загрузки
      await (delete(libraryItems)..where((l) => l.userId.equals(userId))).go();

      // Удаляем пользователя
      await (delete(users)..where((u) => u.id.equals(userId))).go();
    });
  }

  // =============== Library Items ===============

  Future<List<LibraryItem>> getLibraryItemsByUserId(String userId) =>
      (select(libraryItems)..where((l) => l.userId.equals(userId))).get();

  Future<LibraryItem?> getLibraryItemById(String id) =>
      (select(libraryItems)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<LibraryItem> insertLibraryItem(LibraryItemsCompanion item) async {
    await into(libraryItems).insert(item);
    return (await getLibraryItemById(item.id.value))!;
  }

  Future<void> updateLibraryItem(LibraryItem item) =>
      update(libraryItems).replace(item);

  Future<void> deleteLibraryItem(String id) =>
      (delete(libraryItems)..where((l) => l.id.equals(id))).go();
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
