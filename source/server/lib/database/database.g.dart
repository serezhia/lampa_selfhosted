// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _premiumMeta =
      const VerificationMeta('premium');
  @override
  late final GeneratedColumn<int> premium = GeneratedColumn<int>(
      'premium', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _telegramIdMeta =
      const VerificationMeta('telegramId');
  @override
  late final GeneratedColumn<String> telegramId = GeneratedColumn<String>(
      'telegram_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _blockedMeta =
      const VerificationMeta('blocked');
  @override
  late final GeneratedColumn<bool> blocked = GeneratedColumn<bool>(
      'blocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("blocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        passwordHash,
        premium,
        createdAt,
        telegramId,
        phone,
        firstName,
        lastName,
        blocked
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('premium')) {
      context.handle(_premiumMeta,
          premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('telegram_id')) {
      context.handle(
          _telegramIdMeta,
          telegramId.isAcceptableOrUnknown(
              data['telegram_id']!, _telegramIdMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('blocked')) {
      context.handle(_blockedMeta,
          blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      premium: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}premium'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      telegramId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telegram_id']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      blocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}blocked'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String passwordHash;
  final int premium;
  final DateTime createdAt;
  final String? telegramId;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final bool blocked;
  const User(
      {required this.id,
      required this.email,
      required this.passwordHash,
      required this.premium,
      required this.createdAt,
      this.telegramId,
      this.phone,
      this.firstName,
      this.lastName,
      required this.blocked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['premium'] = Variable<int>(premium);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || telegramId != null) {
      map['telegram_id'] = Variable<String>(telegramId);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['blocked'] = Variable<bool>(blocked);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      passwordHash: Value(passwordHash),
      premium: Value(premium),
      createdAt: Value(createdAt),
      telegramId: telegramId == null && nullToAbsent
          ? const Value.absent()
          : Value(telegramId),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      blocked: Value(blocked),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      premium: serializer.fromJson<int>(json['premium']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      telegramId: serializer.fromJson<String?>(json['telegramId']),
      phone: serializer.fromJson<String?>(json['phone']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      blocked: serializer.fromJson<bool>(json['blocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'premium': serializer.toJson<int>(premium),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'telegramId': serializer.toJson<String?>(telegramId),
      'phone': serializer.toJson<String?>(phone),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'blocked': serializer.toJson<bool>(blocked),
    };
  }

  User copyWith(
          {String? id,
          String? email,
          String? passwordHash,
          int? premium,
          DateTime? createdAt,
          Value<String?> telegramId = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> firstName = const Value.absent(),
          Value<String?> lastName = const Value.absent(),
          bool? blocked}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        premium: premium ?? this.premium,
        createdAt: createdAt ?? this.createdAt,
        telegramId: telegramId.present ? telegramId.value : this.telegramId,
        phone: phone.present ? phone.value : this.phone,
        firstName: firstName.present ? firstName.value : this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        blocked: blocked ?? this.blocked,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      premium: data.premium.present ? data.premium.value : this.premium,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      telegramId:
          data.telegramId.present ? data.telegramId.value : this.telegramId,
      phone: data.phone.present ? data.phone.value : this.phone,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      blocked: data.blocked.present ? data.blocked.value : this.blocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('premium: $premium, ')
          ..write('createdAt: $createdAt, ')
          ..write('telegramId: $telegramId, ')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('blocked: $blocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, passwordHash, premium, createdAt,
      telegramId, phone, firstName, lastName, blocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.premium == this.premium &&
          other.createdAt == this.createdAt &&
          other.telegramId == this.telegramId &&
          other.phone == this.phone &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.blocked == this.blocked);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<int> premium;
  final Value<DateTime> createdAt;
  final Value<String?> telegramId;
  final Value<String?> phone;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<bool> blocked;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.premium = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.telegramId = const Value.absent(),
    this.phone = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.blocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String passwordHash,
    this.premium = const Value.absent(),
    required DateTime createdAt,
    this.telegramId = const Value.absent(),
    this.phone = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.blocked = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        passwordHash = Value(passwordHash),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<int>? premium,
    Expression<DateTime>? createdAt,
    Expression<String>? telegramId,
    Expression<String>? phone,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<bool>? blocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (premium != null) 'premium': premium,
      if (createdAt != null) 'created_at': createdAt,
      if (telegramId != null) 'telegram_id': telegramId,
      if (phone != null) 'phone': phone,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (blocked != null) 'blocked': blocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<int>? premium,
      Value<DateTime>? createdAt,
      Value<String?>? telegramId,
      Value<String?>? phone,
      Value<String?>? firstName,
      Value<String?>? lastName,
      Value<bool>? blocked,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      premium: premium ?? this.premium,
      createdAt: createdAt ?? this.createdAt,
      telegramId: telegramId ?? this.telegramId,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      blocked: blocked ?? this.blocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (premium.present) {
      map['premium'] = Variable<int>(premium.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (telegramId.present) {
      map['telegram_id'] = Variable<String>(telegramId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<bool>(blocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('premium: $premium, ')
          ..write('createdAt: $createdAt, ')
          ..write('telegramId: $telegramId, ')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('blocked: $blocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('l_1'));
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(18));
  static const VerificationMeta _adultMeta = const VerificationMeta('adult');
  @override
  late final GeneratedColumn<bool> adult = GeneratedColumn<bool>(
      'adult', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("adult" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _mainMeta = const VerificationMeta('main');
  @override
  late final GeneratedColumn<bool> main = GeneratedColumn<bool>(
      'main', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("main" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, icon, age, adult, main, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('adult')) {
      context.handle(
          _adultMeta, adult.isAcceptableOrUnknown(data['adult']!, _adultMeta));
    }
    if (data.containsKey('main')) {
      context.handle(
          _mainMeta, main.isAcceptableOrUnknown(data['main']!, _mainMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      adult: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}adult'])!,
      main: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}main'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String userId;
  final String name;
  final String icon;
  final int age;
  final bool adult;
  final bool main;
  final DateTime createdAt;
  const Profile(
      {required this.id,
      required this.userId,
      required this.name,
      required this.icon,
      required this.age,
      required this.adult,
      required this.main,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['age'] = Variable<int>(age);
    map['adult'] = Variable<bool>(adult);
    map['main'] = Variable<bool>(main);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      icon: Value(icon),
      age: Value(age),
      adult: Value(adult),
      main: Value(main),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      age: serializer.fromJson<int>(json['age']),
      adult: serializer.fromJson<bool>(json['adult']),
      main: serializer.fromJson<bool>(json['main']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'age': serializer.toJson<int>(age),
      'adult': serializer.toJson<bool>(adult),
      'main': serializer.toJson<bool>(main),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith(
          {int? id,
          String? userId,
          String? name,
          String? icon,
          int? age,
          bool? adult,
          bool? main,
          DateTime? createdAt}) =>
      Profile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        age: age ?? this.age,
        adult: adult ?? this.adult,
        main: main ?? this.main,
        createdAt: createdAt ?? this.createdAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      age: data.age.present ? data.age.value : this.age,
      adult: data.adult.present ? data.adult.value : this.adult,
      main: data.main.present ? data.main.value : this.main,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('age: $age, ')
          ..write('adult: $adult, ')
          ..write('main: $main, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, icon, age, adult, main, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.age == this.age &&
          other.adult == this.adult &&
          other.main == this.main &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> age;
  final Value<bool> adult;
  final Value<bool> main;
  final Value<DateTime> createdAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.age = const Value.absent(),
    this.adult = const Value.absent(),
    this.main = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String name,
    this.icon = const Value.absent(),
    this.age = const Value.absent(),
    this.adult = const Value.absent(),
    this.main = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : userId = Value(userId),
        name = Value(name);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? age,
    Expression<bool>? adult,
    Expression<bool>? main,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (age != null) 'age': age,
      if (adult != null) 'adult': adult,
      if (main != null) 'main': main,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? age,
      Value<bool>? adult,
      Value<bool>? main,
      Value<DateTime>? createdAt}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      age: age ?? this.age,
      adult: adult ?? this.adult,
      main: main ?? this.main,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (adult.present) {
      map['adult'] = Variable<bool>(adult.value);
    }
    if (main.present) {
      map['main'] = Variable<bool>(main.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('age: $age, ')
          ..write('adult: $adult, ')
          ..write('main: $main, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastSeenMeta =
      const VerificationMeta('lastSeen');
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
      'last_seen', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, platform, token, createdAt, lastSeen];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen']),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String userId;
  final String name;
  final String platform;
  final String token;
  final DateTime createdAt;
  final DateTime? lastSeen;
  const Device(
      {required this.id,
      required this.userId,
      required this.name,
      required this.platform,
      required this.token,
      required this.createdAt,
      this.lastSeen});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    map['token'] = Variable<String>(token);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      platform: Value(platform),
      token: Value(token),
      createdAt: Value(createdAt),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      token: serializer.fromJson<String>(json['token']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'token': serializer.toJson<String>(token),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
    };
  }

  Device copyWith(
          {String? id,
          String? userId,
          String? name,
          String? platform,
          String? token,
          DateTime? createdAt,
          Value<DateTime?> lastSeen = const Value.absent()}) =>
      Device(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        platform: platform ?? this.platform,
        token: token ?? this.token,
        createdAt: createdAt ?? this.createdAt,
        lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      token: data.token.present ? data.token.value : this.token,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, platform, token, createdAt, lastSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.token == this.token &&
          other.createdAt == this.createdAt &&
          other.lastSeen == this.lastSeen);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> platform;
  final Value<String> token;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastSeen;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.token = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String userId,
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    required String token,
    this.createdAt = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        token = Value(token);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? token,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (token != null) 'token': token,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String>? platform,
      Value<String>? token,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastSeen,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('like'));
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
      'card_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int> time = GeneratedColumn<int>(
      'time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, type, cardId, data, time, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {profileId, type, cardId},
      ];
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int profileId;
  final String type;
  final int cardId;
  final String data;
  final int time;
  final DateTime createdAt;
  const Bookmark(
      {required this.id,
      required this.profileId,
      required this.type,
      required this.cardId,
      required this.data,
      required this.time,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['type'] = Variable<String>(type);
    map['card_id'] = Variable<int>(cardId);
    map['data'] = Variable<String>(data);
    map['time'] = Variable<int>(time);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      type: Value(type),
      cardId: Value(cardId),
      data: Value(data),
      time: Value(time),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      type: serializer.fromJson<String>(json['type']),
      cardId: serializer.fromJson<int>(json['cardId']),
      data: serializer.fromJson<String>(json['data']),
      time: serializer.fromJson<int>(json['time']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'type': serializer.toJson<String>(type),
      'cardId': serializer.toJson<int>(cardId),
      'data': serializer.toJson<String>(data),
      'time': serializer.toJson<int>(time),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith(
          {int? id,
          int? profileId,
          String? type,
          int? cardId,
          String? data,
          int? time,
          DateTime? createdAt}) =>
      Bookmark(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        type: type ?? this.type,
        cardId: cardId ?? this.cardId,
        data: data ?? this.data,
        time: time ?? this.time,
        createdAt: createdAt ?? this.createdAt,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      type: data.type.present ? data.type.value : this.type,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      data: data.data.present ? data.data.value : this.data,
      time: data.time.present ? data.time.value : this.time,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('cardId: $cardId, ')
          ..write('data: $data, ')
          ..write('time: $time, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, type, cardId, data, time, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.type == this.type &&
          other.cardId == this.cardId &&
          other.data == this.data &&
          other.time == this.time &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> type;
  final Value<int> cardId;
  final Value<String> data;
  final Value<int> time;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.type = const Value.absent(),
    this.cardId = const Value.absent(),
    this.data = const Value.absent(),
    this.time = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    this.type = const Value.absent(),
    required int cardId,
    required String data,
    required int time,
    this.createdAt = const Value.absent(),
  })  : profileId = Value(profileId),
        cardId = Value(cardId),
        data = Value(data),
        time = Value(time);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? type,
    Expression<int>? cardId,
    Expression<String>? data,
    Expression<int>? time,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (type != null) 'type': type,
      if (cardId != null) 'card_id': cardId,
      if (data != null) 'data': data,
      if (time != null) 'time': time,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? type,
      Value<int>? cardId,
      Value<String>? data,
      Value<int>? time,
      Value<DateTime>? createdAt}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      type: type ?? this.type,
      cardId: cardId ?? this.cardId,
      data: data ?? this.data,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('type: $type, ')
          ..write('cardId: $cardId, ')
          ..write('data: $data, ')
          ..write('time: $time, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TimelineEntriesTable extends TimelineEntries
    with TableInfo<$TimelineEntriesTable, TimelineEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _percentMeta =
      const VerificationMeta('percent');
  @override
  late final GeneratedColumn<double> percent = GeneratedColumn<double>(
      'percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<double> time = GeneratedColumn<double>(
      'time', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
      'duration', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, hash, percent, time, duration, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TimelineEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('percent')) {
      context.handle(_percentMeta,
          percent.isAcceptableOrUnknown(data['percent']!, _percentMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {profileId, hash},
      ];
  @override
  TimelineEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      percent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percent'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}time'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}duration'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TimelineEntriesTable createAlias(String alias) {
    return $TimelineEntriesTable(attachedDatabase, alias);
  }
}

class TimelineEntry extends DataClass implements Insertable<TimelineEntry> {
  final int id;
  final int profileId;
  final String hash;
  final double percent;
  final double time;
  final double duration;
  final DateTime updatedAt;
  const TimelineEntry(
      {required this.id,
      required this.profileId,
      required this.hash,
      required this.percent,
      required this.time,
      required this.duration,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['hash'] = Variable<String>(hash);
    map['percent'] = Variable<double>(percent);
    map['time'] = Variable<double>(time);
    map['duration'] = Variable<double>(duration);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TimelineEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimelineEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      hash: Value(hash),
      percent: Value(percent),
      time: Value(time),
      duration: Value(duration),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimelineEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEntry(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      hash: serializer.fromJson<String>(json['hash']),
      percent: serializer.fromJson<double>(json['percent']),
      time: serializer.fromJson<double>(json['time']),
      duration: serializer.fromJson<double>(json['duration']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'hash': serializer.toJson<String>(hash),
      'percent': serializer.toJson<double>(percent),
      'time': serializer.toJson<double>(time),
      'duration': serializer.toJson<double>(duration),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TimelineEntry copyWith(
          {int? id,
          int? profileId,
          String? hash,
          double? percent,
          double? time,
          double? duration,
          DateTime? updatedAt}) =>
      TimelineEntry(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        hash: hash ?? this.hash,
        percent: percent ?? this.percent,
        time: time ?? this.time,
        duration: duration ?? this.duration,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TimelineEntry copyWithCompanion(TimelineEntriesCompanion data) {
    return TimelineEntry(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      hash: data.hash.present ? data.hash.value : this.hash,
      percent: data.percent.present ? data.percent.value : this.percent,
      time: data.time.present ? data.time.value : this.time,
      duration: data.duration.present ? data.duration.value : this.duration,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntry(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('hash: $hash, ')
          ..write('percent: $percent, ')
          ..write('time: $time, ')
          ..write('duration: $duration, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, hash, percent, time, duration, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEntry &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.hash == this.hash &&
          other.percent == this.percent &&
          other.time == this.time &&
          other.duration == this.duration &&
          other.updatedAt == this.updatedAt);
}

class TimelineEntriesCompanion extends UpdateCompanion<TimelineEntry> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> hash;
  final Value<double> percent;
  final Value<double> time;
  final Value<double> duration;
  final Value<DateTime> updatedAt;
  const TimelineEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.hash = const Value.absent(),
    this.percent = const Value.absent(),
    this.time = const Value.absent(),
    this.duration = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TimelineEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String hash,
    this.percent = const Value.absent(),
    this.time = const Value.absent(),
    this.duration = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : profileId = Value(profileId),
        hash = Value(hash);
  static Insertable<TimelineEntry> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? hash,
    Expression<double>? percent,
    Expression<double>? time,
    Expression<double>? duration,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (hash != null) 'hash': hash,
      if (percent != null) 'percent': percent,
      if (time != null) 'time': time,
      if (duration != null) 'duration': duration,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TimelineEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? hash,
      Value<double>? percent,
      Value<double>? time,
      Value<double>? duration,
      Value<DateTime>? updatedAt}) {
    return TimelineEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      hash: hash ?? this.hash,
      percent: percent ?? this.percent,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (percent.present) {
      map['percent'] = Variable<double>(percent.value);
    }
    if (time.present) {
      map['time'] = Variable<double>(time.value);
    }
    if (duration.present) {
      map['duration'] = Variable<double>(duration.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('hash: $hash, ')
          ..write('percent: $percent, ')
          ..write('time: $time, ')
          ..write('duration: $duration, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BookmarkChangesTable extends BookmarkChanges
    with TableInfo<$BookmarkChangesTable, BookmarkChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
      'card_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int> time = GeneratedColumn<int>(
      'time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, version, action, entityId, type, cardId, data, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_changes';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkChange> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkChange(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_id']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $BookmarkChangesTable createAlias(String alias) {
    return $BookmarkChangesTable(attachedDatabase, alias);
  }
}

class BookmarkChange extends DataClass implements Insertable<BookmarkChange> {
  final int id;
  final int profileId;
  final int version;
  final String action;
  final int entityId;
  final String? type;
  final int? cardId;
  final String data;
  final int time;
  const BookmarkChange(
      {required this.id,
      required this.profileId,
      required this.version,
      required this.action,
      required this.entityId,
      this.type,
      this.cardId,
      required this.data,
      required this.time});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['version'] = Variable<int>(version);
    map['action'] = Variable<String>(action);
    map['entity_id'] = Variable<int>(entityId);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || cardId != null) {
      map['card_id'] = Variable<int>(cardId);
    }
    map['data'] = Variable<String>(data);
    map['time'] = Variable<int>(time);
    return map;
  }

  BookmarkChangesCompanion toCompanion(bool nullToAbsent) {
    return BookmarkChangesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      version: Value(version),
      action: Value(action),
      entityId: Value(entityId),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      cardId:
          cardId == null && nullToAbsent ? const Value.absent() : Value(cardId),
      data: Value(data),
      time: Value(time),
    );
  }

  factory BookmarkChange.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkChange(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      version: serializer.fromJson<int>(json['version']),
      action: serializer.fromJson<String>(json['action']),
      entityId: serializer.fromJson<int>(json['entityId']),
      type: serializer.fromJson<String?>(json['type']),
      cardId: serializer.fromJson<int?>(json['cardId']),
      data: serializer.fromJson<String>(json['data']),
      time: serializer.fromJson<int>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'version': serializer.toJson<int>(version),
      'action': serializer.toJson<String>(action),
      'entityId': serializer.toJson<int>(entityId),
      'type': serializer.toJson<String?>(type),
      'cardId': serializer.toJson<int?>(cardId),
      'data': serializer.toJson<String>(data),
      'time': serializer.toJson<int>(time),
    };
  }

  BookmarkChange copyWith(
          {int? id,
          int? profileId,
          int? version,
          String? action,
          int? entityId,
          Value<String?> type = const Value.absent(),
          Value<int?> cardId = const Value.absent(),
          String? data,
          int? time}) =>
      BookmarkChange(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        version: version ?? this.version,
        action: action ?? this.action,
        entityId: entityId ?? this.entityId,
        type: type.present ? type.value : this.type,
        cardId: cardId.present ? cardId.value : this.cardId,
        data: data ?? this.data,
        time: time ?? this.time,
      );
  BookmarkChange copyWithCompanion(BookmarkChangesCompanion data) {
    return BookmarkChange(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      version: data.version.present ? data.version.value : this.version,
      action: data.action.present ? data.action.value : this.action,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      type: data.type.present ? data.type.value : this.type,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      data: data.data.present ? data.data.value : this.data,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkChange(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('version: $version, ')
          ..write('action: $action, ')
          ..write('entityId: $entityId, ')
          ..write('type: $type, ')
          ..write('cardId: $cardId, ')
          ..write('data: $data, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, version, action, entityId, type, cardId, data, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkChange &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.version == this.version &&
          other.action == this.action &&
          other.entityId == this.entityId &&
          other.type == this.type &&
          other.cardId == this.cardId &&
          other.data == this.data &&
          other.time == this.time);
}

class BookmarkChangesCompanion extends UpdateCompanion<BookmarkChange> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> version;
  final Value<String> action;
  final Value<int> entityId;
  final Value<String?> type;
  final Value<int?> cardId;
  final Value<String> data;
  final Value<int> time;
  const BookmarkChangesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.version = const Value.absent(),
    this.action = const Value.absent(),
    this.entityId = const Value.absent(),
    this.type = const Value.absent(),
    this.cardId = const Value.absent(),
    this.data = const Value.absent(),
    this.time = const Value.absent(),
  });
  BookmarkChangesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int version,
    required String action,
    required int entityId,
    this.type = const Value.absent(),
    this.cardId = const Value.absent(),
    this.data = const Value.absent(),
    required int time,
  })  : profileId = Value(profileId),
        version = Value(version),
        action = Value(action),
        entityId = Value(entityId),
        time = Value(time);
  static Insertable<BookmarkChange> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? version,
    Expression<String>? action,
    Expression<int>? entityId,
    Expression<String>? type,
    Expression<int>? cardId,
    Expression<String>? data,
    Expression<int>? time,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (version != null) 'version': version,
      if (action != null) 'action': action,
      if (entityId != null) 'entity_id': entityId,
      if (type != null) 'type': type,
      if (cardId != null) 'card_id': cardId,
      if (data != null) 'data': data,
      if (time != null) 'time': time,
    });
  }

  BookmarkChangesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<int>? version,
      Value<String>? action,
      Value<int>? entityId,
      Value<String?>? type,
      Value<int?>? cardId,
      Value<String>? data,
      Value<int>? time}) {
    return BookmarkChangesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      version: version ?? this.version,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      type: type ?? this.type,
      cardId: cardId ?? this.cardId,
      data: data ?? this.data,
      time: time ?? this.time,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkChangesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('version: $version, ')
          ..write('action: $action, ')
          ..write('entityId: $entityId, ')
          ..write('type: $type, ')
          ..write('cardId: $cardId, ')
          ..write('data: $data, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }
}

class $ProfileVersionsTable extends ProfileVersions
    with TableInfo<$ProfileVersionsTable, ProfileVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _bookmarkVersionMeta =
      const VerificationMeta('bookmarkVersion');
  @override
  late final GeneratedColumn<int> bookmarkVersion = GeneratedColumn<int>(
      'bookmark_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timelineVersionMeta =
      const VerificationMeta('timelineVersion');
  @override
  late final GeneratedColumn<int> timelineVersion = GeneratedColumn<int>(
      'timeline_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [profileId, bookmarkVersion, timelineVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_versions';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileVersion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('bookmark_version')) {
      context.handle(
          _bookmarkVersionMeta,
          bookmarkVersion.isAcceptableOrUnknown(
              data['bookmark_version']!, _bookmarkVersionMeta));
    }
    if (data.containsKey('timeline_version')) {
      context.handle(
          _timelineVersionMeta,
          timelineVersion.isAcceptableOrUnknown(
              data['timeline_version']!, _timelineVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileVersion(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      bookmarkVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bookmark_version'])!,
      timelineVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timeline_version'])!,
    );
  }

  @override
  $ProfileVersionsTable createAlias(String alias) {
    return $ProfileVersionsTable(attachedDatabase, alias);
  }
}

class ProfileVersion extends DataClass implements Insertable<ProfileVersion> {
  final int profileId;
  final int bookmarkVersion;
  final int timelineVersion;
  const ProfileVersion(
      {required this.profileId,
      required this.bookmarkVersion,
      required this.timelineVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['bookmark_version'] = Variable<int>(bookmarkVersion);
    map['timeline_version'] = Variable<int>(timelineVersion);
    return map;
  }

  ProfileVersionsCompanion toCompanion(bool nullToAbsent) {
    return ProfileVersionsCompanion(
      profileId: Value(profileId),
      bookmarkVersion: Value(bookmarkVersion),
      timelineVersion: Value(timelineVersion),
    );
  }

  factory ProfileVersion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileVersion(
      profileId: serializer.fromJson<int>(json['profileId']),
      bookmarkVersion: serializer.fromJson<int>(json['bookmarkVersion']),
      timelineVersion: serializer.fromJson<int>(json['timelineVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'bookmarkVersion': serializer.toJson<int>(bookmarkVersion),
      'timelineVersion': serializer.toJson<int>(timelineVersion),
    };
  }

  ProfileVersion copyWith(
          {int? profileId, int? bookmarkVersion, int? timelineVersion}) =>
      ProfileVersion(
        profileId: profileId ?? this.profileId,
        bookmarkVersion: bookmarkVersion ?? this.bookmarkVersion,
        timelineVersion: timelineVersion ?? this.timelineVersion,
      );
  ProfileVersion copyWithCompanion(ProfileVersionsCompanion data) {
    return ProfileVersion(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      bookmarkVersion: data.bookmarkVersion.present
          ? data.bookmarkVersion.value
          : this.bookmarkVersion,
      timelineVersion: data.timelineVersion.present
          ? data.timelineVersion.value
          : this.timelineVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileVersion(')
          ..write('profileId: $profileId, ')
          ..write('bookmarkVersion: $bookmarkVersion, ')
          ..write('timelineVersion: $timelineVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, bookmarkVersion, timelineVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileVersion &&
          other.profileId == this.profileId &&
          other.bookmarkVersion == this.bookmarkVersion &&
          other.timelineVersion == this.timelineVersion);
}

class ProfileVersionsCompanion extends UpdateCompanion<ProfileVersion> {
  final Value<int> profileId;
  final Value<int> bookmarkVersion;
  final Value<int> timelineVersion;
  const ProfileVersionsCompanion({
    this.profileId = const Value.absent(),
    this.bookmarkVersion = const Value.absent(),
    this.timelineVersion = const Value.absent(),
  });
  ProfileVersionsCompanion.insert({
    this.profileId = const Value.absent(),
    this.bookmarkVersion = const Value.absent(),
    this.timelineVersion = const Value.absent(),
  });
  static Insertable<ProfileVersion> custom({
    Expression<int>? profileId,
    Expression<int>? bookmarkVersion,
    Expression<int>? timelineVersion,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (bookmarkVersion != null) 'bookmark_version': bookmarkVersion,
      if (timelineVersion != null) 'timeline_version': timelineVersion,
    });
  }

  ProfileVersionsCompanion copyWith(
      {Value<int>? profileId,
      Value<int>? bookmarkVersion,
      Value<int>? timelineVersion}) {
    return ProfileVersionsCompanion(
      profileId: profileId ?? this.profileId,
      bookmarkVersion: bookmarkVersion ?? this.bookmarkVersion,
      timelineVersion: timelineVersion ?? this.timelineVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (bookmarkVersion.present) {
      map['bookmark_version'] = Variable<int>(bookmarkVersion.value);
    }
    if (timelineVersion.present) {
      map['timeline_version'] = Variable<int>(timelineVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileVersionsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('bookmarkVersion: $bookmarkVersion, ')
          ..write('timelineVersion: $timelineVersion')
          ..write(')'))
        .toString();
  }
}

class $NoticesTable extends Notices with TableInfo<$NoticesTable, Notice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _noticeTypeMeta =
      const VerificationMeta('noticeType');
  @override
  late final GeneratedColumn<String> noticeType = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('simple'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noticeTextMeta =
      const VerificationMeta('noticeText');
  @override
  late final GeneratedColumn<String> noticeText = GeneratedColumn<String>(
      'notice_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        noticeType,
        title,
        noticeText,
        image,
        data,
        active,
        createdAt,
        expiresAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notices';
  @override
  VerificationContext validateIntegrity(Insertable<Notice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(_noticeTypeMeta,
          noticeType.isAcceptableOrUnknown(data['type']!, _noticeTypeMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('notice_text')) {
      context.handle(
          _noticeTextMeta,
          noticeText.isAcceptableOrUnknown(
              data['notice_text']!, _noticeTextMeta));
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      noticeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      noticeText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notice_text']),
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $NoticesTable createAlias(String alias) {
    return $NoticesTable(attachedDatabase, alias);
  }
}

class Notice extends DataClass implements Insertable<Notice> {
  final int id;
  final String noticeType;
  final String? title;
  final String? noticeText;
  final String? image;
  final String? data;
  final bool active;
  final DateTime createdAt;
  final DateTime? expiresAt;
  const Notice(
      {required this.id,
      required this.noticeType,
      this.title,
      this.noticeText,
      this.image,
      this.data,
      required this.active,
      required this.createdAt,
      this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(noticeType);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || noticeText != null) {
      map['notice_text'] = Variable<String>(noticeText);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  NoticesCompanion toCompanion(bool nullToAbsent) {
    return NoticesCompanion(
      id: Value(id),
      noticeType: Value(noticeType),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      noticeText: noticeText == null && nullToAbsent
          ? const Value.absent()
          : Value(noticeText),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      active: Value(active),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory Notice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notice(
      id: serializer.fromJson<int>(json['id']),
      noticeType: serializer.fromJson<String>(json['noticeType']),
      title: serializer.fromJson<String?>(json['title']),
      noticeText: serializer.fromJson<String?>(json['noticeText']),
      image: serializer.fromJson<String?>(json['image']),
      data: serializer.fromJson<String?>(json['data']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noticeType': serializer.toJson<String>(noticeType),
      'title': serializer.toJson<String?>(title),
      'noticeText': serializer.toJson<String?>(noticeText),
      'image': serializer.toJson<String?>(image),
      'data': serializer.toJson<String?>(data),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  Notice copyWith(
          {int? id,
          String? noticeType,
          Value<String?> title = const Value.absent(),
          Value<String?> noticeText = const Value.absent(),
          Value<String?> image = const Value.absent(),
          Value<String?> data = const Value.absent(),
          bool? active,
          DateTime? createdAt,
          Value<DateTime?> expiresAt = const Value.absent()}) =>
      Notice(
        id: id ?? this.id,
        noticeType: noticeType ?? this.noticeType,
        title: title.present ? title.value : this.title,
        noticeText: noticeText.present ? noticeText.value : this.noticeText,
        image: image.present ? image.value : this.image,
        data: data.present ? data.value : this.data,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  Notice copyWithCompanion(NoticesCompanion data) {
    return Notice(
      id: data.id.present ? data.id.value : this.id,
      noticeType:
          data.noticeType.present ? data.noticeType.value : this.noticeType,
      title: data.title.present ? data.title.value : this.title,
      noticeText:
          data.noticeText.present ? data.noticeText.value : this.noticeText,
      image: data.image.present ? data.image.value : this.image,
      data: data.data.present ? data.data.value : this.data,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notice(')
          ..write('id: $id, ')
          ..write('noticeType: $noticeType, ')
          ..write('title: $title, ')
          ..write('noticeText: $noticeText, ')
          ..write('image: $image, ')
          ..write('data: $data, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noticeType, title, noticeText, image,
      data, active, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notice &&
          other.id == this.id &&
          other.noticeType == this.noticeType &&
          other.title == this.title &&
          other.noticeText == this.noticeText &&
          other.image == this.image &&
          other.data == this.data &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class NoticesCompanion extends UpdateCompanion<Notice> {
  final Value<int> id;
  final Value<String> noticeType;
  final Value<String?> title;
  final Value<String?> noticeText;
  final Value<String?> image;
  final Value<String?> data;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  const NoticesCompanion({
    this.id = const Value.absent(),
    this.noticeType = const Value.absent(),
    this.title = const Value.absent(),
    this.noticeText = const Value.absent(),
    this.image = const Value.absent(),
    this.data = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  NoticesCompanion.insert({
    this.id = const Value.absent(),
    this.noticeType = const Value.absent(),
    this.title = const Value.absent(),
    this.noticeText = const Value.absent(),
    this.image = const Value.absent(),
    this.data = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  static Insertable<Notice> custom({
    Expression<int>? id,
    Expression<String>? noticeType,
    Expression<String>? title,
    Expression<String>? noticeText,
    Expression<String>? image,
    Expression<String>? data,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noticeType != null) 'type': noticeType,
      if (title != null) 'title': title,
      if (noticeText != null) 'notice_text': noticeText,
      if (image != null) 'image': image,
      if (data != null) 'data': data,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  NoticesCompanion copyWith(
      {Value<int>? id,
      Value<String>? noticeType,
      Value<String?>? title,
      Value<String?>? noticeText,
      Value<String?>? image,
      Value<String?>? data,
      Value<bool>? active,
      Value<DateTime>? createdAt,
      Value<DateTime?>? expiresAt}) {
    return NoticesCompanion(
      id: id ?? this.id,
      noticeType: noticeType ?? this.noticeType,
      title: title ?? this.title,
      noticeText: noticeText ?? this.noticeText,
      image: image ?? this.image,
      data: data ?? this.data,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noticeType.present) {
      map['type'] = Variable<String>(noticeType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (noticeText.present) {
      map['notice_text'] = Variable<String>(noticeText.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoticesCompanion(')
          ..write('id: $id, ')
          ..write('noticeType: $noticeType, ')
          ..write('title: $title, ')
          ..write('noticeText: $noticeText, ')
          ..write('image: $image, ')
          ..write('data: $data, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingRegistrationsTable extends PendingRegistrations
    with TableInfo<$PendingRegistrationsTable, PendingRegistration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _telegramIdMeta =
      const VerificationMeta('telegramId');
  @override
  late final GeneratedColumn<String> telegramId = GeneratedColumn<String>(
      'telegram_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, telegramId, phone, firstName, lastName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_registrations';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingRegistration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('telegram_id')) {
      context.handle(
          _telegramIdMeta,
          telegramId.isAcceptableOrUnknown(
              data['telegram_id']!, _telegramIdMeta));
    } else if (isInserting) {
      context.missing(_telegramIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingRegistration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRegistration(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      telegramId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telegram_id'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingRegistrationsTable createAlias(String alias) {
    return $PendingRegistrationsTable(attachedDatabase, alias);
  }
}

class PendingRegistration extends DataClass
    implements Insertable<PendingRegistration> {
  final int id;
  final String telegramId;
  final String phone;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;
  const PendingRegistration(
      {required this.id,
      required this.telegramId,
      required this.phone,
      this.firstName,
      this.lastName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['telegram_id'] = Variable<String>(telegramId);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return PendingRegistrationsCompanion(
      id: Value(id),
      telegramId: Value(telegramId),
      phone: Value(phone),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      createdAt: Value(createdAt),
    );
  }

  factory PendingRegistration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRegistration(
      id: serializer.fromJson<int>(json['id']),
      telegramId: serializer.fromJson<String>(json['telegramId']),
      phone: serializer.fromJson<String>(json['phone']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'telegramId': serializer.toJson<String>(telegramId),
      'phone': serializer.toJson<String>(phone),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingRegistration copyWith(
          {int? id,
          String? telegramId,
          String? phone,
          Value<String?> firstName = const Value.absent(),
          Value<String?> lastName = const Value.absent(),
          DateTime? createdAt}) =>
      PendingRegistration(
        id: id ?? this.id,
        telegramId: telegramId ?? this.telegramId,
        phone: phone ?? this.phone,
        firstName: firstName.present ? firstName.value : this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingRegistration copyWithCompanion(PendingRegistrationsCompanion data) {
    return PendingRegistration(
      id: data.id.present ? data.id.value : this.id,
      telegramId:
          data.telegramId.present ? data.telegramId.value : this.telegramId,
      phone: data.phone.present ? data.phone.value : this.phone,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingRegistration(')
          ..write('id: $id, ')
          ..write('telegramId: $telegramId, ')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, telegramId, phone, firstName, lastName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingRegistration &&
          other.id == this.id &&
          other.telegramId == this.telegramId &&
          other.phone == this.phone &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.createdAt == this.createdAt);
}

class PendingRegistrationsCompanion
    extends UpdateCompanion<PendingRegistration> {
  final Value<int> id;
  final Value<String> telegramId;
  final Value<String> phone;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<DateTime> createdAt;
  const PendingRegistrationsCompanion({
    this.id = const Value.absent(),
    this.telegramId = const Value.absent(),
    this.phone = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingRegistrationsCompanion.insert({
    this.id = const Value.absent(),
    required String telegramId,
    required String phone,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : telegramId = Value(telegramId),
        phone = Value(phone);
  static Insertable<PendingRegistration> custom({
    Expression<int>? id,
    Expression<String>? telegramId,
    Expression<String>? phone,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (telegramId != null) 'telegram_id': telegramId,
      if (phone != null) 'phone': phone,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingRegistrationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? telegramId,
      Value<String>? phone,
      Value<String?>? firstName,
      Value<String?>? lastName,
      Value<DateTime>? createdAt}) {
    return PendingRegistrationsCompanion(
      id: id ?? this.id,
      telegramId: telegramId ?? this.telegramId,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (telegramId.present) {
      map['telegram_id'] = Variable<String>(telegramId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingRegistrationsCompanion(')
          ..write('id: $id, ')
          ..write('telegramId: $telegramId, ')
          ..write('phone: $phone, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InviteCodesTable extends InviteCodes
    with TableInfo<$InviteCodesTable, InviteCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InviteCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _oneTimeMeta =
      const VerificationMeta('oneTime');
  @override
  late final GeneratedColumn<bool> oneTime = GeneratedColumn<bool>(
      'one_time', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("one_time" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _usesLeftMeta =
      const VerificationMeta('usesLeft');
  @override
  late final GeneratedColumn<int> usesLeft = GeneratedColumn<int>(
      'uses_left', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, oneTime, usesLeft, createdAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invite_codes';
  @override
  VerificationContext validateIntegrity(Insertable<InviteCode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('one_time')) {
      context.handle(_oneTimeMeta,
          oneTime.isAcceptableOrUnknown(data['one_time']!, _oneTimeMeta));
    }
    if (data.containsKey('uses_left')) {
      context.handle(_usesLeftMeta,
          usesLeft.isAcceptableOrUnknown(data['uses_left']!, _usesLeftMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InviteCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InviteCode(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      oneTime: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}one_time'])!,
      usesLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uses_left'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $InviteCodesTable createAlias(String alias) {
    return $InviteCodesTable(attachedDatabase, alias);
  }
}

class InviteCode extends DataClass implements Insertable<InviteCode> {
  final int id;
  final String code;
  final bool oneTime;
  final int usesLeft;
  final DateTime createdAt;
  final DateTime? expiresAt;
  const InviteCode(
      {required this.id,
      required this.code,
      required this.oneTime,
      required this.usesLeft,
      required this.createdAt,
      this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['one_time'] = Variable<bool>(oneTime);
    map['uses_left'] = Variable<int>(usesLeft);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  InviteCodesCompanion toCompanion(bool nullToAbsent) {
    return InviteCodesCompanion(
      id: Value(id),
      code: Value(code),
      oneTime: Value(oneTime),
      usesLeft: Value(usesLeft),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory InviteCode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InviteCode(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      oneTime: serializer.fromJson<bool>(json['oneTime']),
      usesLeft: serializer.fromJson<int>(json['usesLeft']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'oneTime': serializer.toJson<bool>(oneTime),
      'usesLeft': serializer.toJson<int>(usesLeft),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  InviteCode copyWith(
          {int? id,
          String? code,
          bool? oneTime,
          int? usesLeft,
          DateTime? createdAt,
          Value<DateTime?> expiresAt = const Value.absent()}) =>
      InviteCode(
        id: id ?? this.id,
        code: code ?? this.code,
        oneTime: oneTime ?? this.oneTime,
        usesLeft: usesLeft ?? this.usesLeft,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  InviteCode copyWithCompanion(InviteCodesCompanion data) {
    return InviteCode(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      oneTime: data.oneTime.present ? data.oneTime.value : this.oneTime,
      usesLeft: data.usesLeft.present ? data.usesLeft.value : this.usesLeft,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InviteCode(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('oneTime: $oneTime, ')
          ..write('usesLeft: $usesLeft, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, oneTime, usesLeft, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InviteCode &&
          other.id == this.id &&
          other.code == this.code &&
          other.oneTime == this.oneTime &&
          other.usesLeft == this.usesLeft &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class InviteCodesCompanion extends UpdateCompanion<InviteCode> {
  final Value<int> id;
  final Value<String> code;
  final Value<bool> oneTime;
  final Value<int> usesLeft;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  const InviteCodesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.oneTime = const Value.absent(),
    this.usesLeft = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  InviteCodesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.oneTime = const Value.absent(),
    this.usesLeft = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  }) : code = Value(code);
  static Insertable<InviteCode> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<bool>? oneTime,
    Expression<int>? usesLeft,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (oneTime != null) 'one_time': oneTime,
      if (usesLeft != null) 'uses_left': usesLeft,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  InviteCodesCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<bool>? oneTime,
      Value<int>? usesLeft,
      Value<DateTime>? createdAt,
      Value<DateTime?>? expiresAt}) {
    return InviteCodesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      oneTime: oneTime ?? this.oneTime,
      usesLeft: usesLeft ?? this.usesLeft,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (oneTime.present) {
      map['one_time'] = Variable<bool>(oneTime.value);
    }
    if (usesLeft.present) {
      map['uses_left'] = Variable<int>(usesLeft.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InviteCodesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('oneTime: $oneTime, ')
          ..write('usesLeft: $usesLeft, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $LibraryItemsTable extends LibraryItems
    with TableInfo<$LibraryItemsTable, LibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
      'tmdb_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
      'season', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeMeta =
      const VerificationMeta('episode');
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _posterMeta = const VerificationMeta('poster');
  @override
  late final GeneratedColumn<String> poster = GeneratedColumn<String>(
      'poster', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _magnetUriMeta =
      const VerificationMeta('magnetUri');
  @override
  late final GeneratedColumn<String> magnetUri = GeneratedColumn<String>(
      'magnet_uri', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileIndexMeta =
      const VerificationMeta('fileIndex');
  @override
  late final GeneratedColumn<int> fileIndex = GeneratedColumn<int>(
      'file_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _audioIndexMeta =
      const VerificationMeta('audioIndex');
  @override
  late final GeneratedColumn<int> audioIndex = GeneratedColumn<int>(
      'audio_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _subtitleIndexMeta =
      const VerificationMeta('subtitleIndex');
  @override
  late final GeneratedColumn<int> subtitleIndex = GeneratedColumn<int>(
      'subtitle_index', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        tmdbId,
        type,
        season,
        episode,
        title,
        poster,
        magnetUri,
        status,
        progress,
        errorMessage,
        fileIndex,
        audioIndex,
        subtitleIndex,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_items';
  @override
  VerificationContext validateIntegrity(Insertable<LibraryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(_tmdbIdMeta,
          tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta));
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    }
    if (data.containsKey('episode')) {
      context.handle(_episodeMeta,
          episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('poster')) {
      context.handle(_posterMeta,
          poster.isAcceptableOrUnknown(data['poster']!, _posterMeta));
    }
    if (data.containsKey('magnet_uri')) {
      context.handle(_magnetUriMeta,
          magnetUri.isAcceptableOrUnknown(data['magnet_uri']!, _magnetUriMeta));
    } else if (isInserting) {
      context.missing(_magnetUriMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('file_index')) {
      context.handle(_fileIndexMeta,
          fileIndex.isAcceptableOrUnknown(data['file_index']!, _fileIndexMeta));
    }
    if (data.containsKey('audio_index')) {
      context.handle(
          _audioIndexMeta,
          audioIndex.isAcceptableOrUnknown(
              data['audio_index']!, _audioIndexMeta));
    }
    if (data.containsKey('subtitle_index')) {
      context.handle(
          _subtitleIndexMeta,
          subtitleIndex.isAcceptableOrUnknown(
              data['subtitle_index']!, _subtitleIndexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      tmdbId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tmdb_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season']),
      episode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      poster: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poster']),
      magnetUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}magnet_uri'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      fileIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_index']),
      audioIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}audio_index']),
      subtitleIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtitle_index']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LibraryItemsTable createAlias(String alias) {
    return $LibraryItemsTable(attachedDatabase, alias);
  }
}

class LibraryItem extends DataClass implements Insertable<LibraryItem> {
  final String id;
  final String userId;
  final int tmdbId;
  final String type;
  final int? season;
  final int? episode;
  final String title;
  final String? poster;
  final String magnetUri;
  final String status;
  final double progress;
  final String? errorMessage;
  final int? fileIndex;
  final int? audioIndex;
  final int? subtitleIndex;
  final DateTime createdAt;
  const LibraryItem(
      {required this.id,
      required this.userId,
      required this.tmdbId,
      required this.type,
      this.season,
      this.episode,
      required this.title,
      this.poster,
      required this.magnetUri,
      required this.status,
      required this.progress,
      this.errorMessage,
      this.fileIndex,
      this.audioIndex,
      this.subtitleIndex,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || episode != null) {
      map['episode'] = Variable<int>(episode);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || poster != null) {
      map['poster'] = Variable<String>(poster);
    }
    map['magnet_uri'] = Variable<String>(magnetUri);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || fileIndex != null) {
      map['file_index'] = Variable<int>(fileIndex);
    }
    if (!nullToAbsent || audioIndex != null) {
      map['audio_index'] = Variable<int>(audioIndex);
    }
    if (!nullToAbsent || subtitleIndex != null) {
      map['subtitle_index'] = Variable<int>(subtitleIndex);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LibraryItemsCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemsCompanion(
      id: Value(id),
      userId: Value(userId),
      tmdbId: Value(tmdbId),
      type: Value(type),
      season:
          season == null && nullToAbsent ? const Value.absent() : Value(season),
      episode: episode == null && nullToAbsent
          ? const Value.absent()
          : Value(episode),
      title: Value(title),
      poster:
          poster == null && nullToAbsent ? const Value.absent() : Value(poster),
      magnetUri: Value(magnetUri),
      status: Value(status),
      progress: Value(progress),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      fileIndex: fileIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(fileIndex),
      audioIndex: audioIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(audioIndex),
      subtitleIndex: subtitleIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitleIndex),
      createdAt: Value(createdAt),
    );
  }

  factory LibraryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryItem(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      type: serializer.fromJson<String>(json['type']),
      season: serializer.fromJson<int?>(json['season']),
      episode: serializer.fromJson<int?>(json['episode']),
      title: serializer.fromJson<String>(json['title']),
      poster: serializer.fromJson<String?>(json['poster']),
      magnetUri: serializer.fromJson<String>(json['magnetUri']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      fileIndex: serializer.fromJson<int?>(json['fileIndex']),
      audioIndex: serializer.fromJson<int?>(json['audioIndex']),
      subtitleIndex: serializer.fromJson<int?>(json['subtitleIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'tmdbId': serializer.toJson<int>(tmdbId),
      'type': serializer.toJson<String>(type),
      'season': serializer.toJson<int?>(season),
      'episode': serializer.toJson<int?>(episode),
      'title': serializer.toJson<String>(title),
      'poster': serializer.toJson<String?>(poster),
      'magnetUri': serializer.toJson<String>(magnetUri),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'fileIndex': serializer.toJson<int?>(fileIndex),
      'audioIndex': serializer.toJson<int?>(audioIndex),
      'subtitleIndex': serializer.toJson<int?>(subtitleIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LibraryItem copyWith(
          {String? id,
          String? userId,
          int? tmdbId,
          String? type,
          Value<int?> season = const Value.absent(),
          Value<int?> episode = const Value.absent(),
          String? title,
          Value<String?> poster = const Value.absent(),
          String? magnetUri,
          String? status,
          double? progress,
          Value<String?> errorMessage = const Value.absent(),
          Value<int?> fileIndex = const Value.absent(),
          Value<int?> audioIndex = const Value.absent(),
          Value<int?> subtitleIndex = const Value.absent(),
          DateTime? createdAt}) =>
      LibraryItem(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tmdbId: tmdbId ?? this.tmdbId,
        type: type ?? this.type,
        season: season.present ? season.value : this.season,
        episode: episode.present ? episode.value : this.episode,
        title: title ?? this.title,
        poster: poster.present ? poster.value : this.poster,
        magnetUri: magnetUri ?? this.magnetUri,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        fileIndex: fileIndex.present ? fileIndex.value : this.fileIndex,
        audioIndex: audioIndex.present ? audioIndex.value : this.audioIndex,
        subtitleIndex:
            subtitleIndex.present ? subtitleIndex.value : this.subtitleIndex,
        createdAt: createdAt ?? this.createdAt,
      );
  LibraryItem copyWithCompanion(LibraryItemsCompanion data) {
    return LibraryItem(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      type: data.type.present ? data.type.value : this.type,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      title: data.title.present ? data.title.value : this.title,
      poster: data.poster.present ? data.poster.value : this.poster,
      magnetUri: data.magnetUri.present ? data.magnetUri.value : this.magnetUri,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      fileIndex: data.fileIndex.present ? data.fileIndex.value : this.fileIndex,
      audioIndex:
          data.audioIndex.present ? data.audioIndex.value : this.audioIndex,
      subtitleIndex: data.subtitleIndex.present
          ? data.subtitleIndex.value
          : this.subtitleIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItem(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('type: $type, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('title: $title, ')
          ..write('poster: $poster, ')
          ..write('magnetUri: $magnetUri, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('fileIndex: $fileIndex, ')
          ..write('audioIndex: $audioIndex, ')
          ..write('subtitleIndex: $subtitleIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      tmdbId,
      type,
      season,
      episode,
      title,
      poster,
      magnetUri,
      status,
      progress,
      errorMessage,
      fileIndex,
      audioIndex,
      subtitleIndex,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryItem &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tmdbId == this.tmdbId &&
          other.type == this.type &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.title == this.title &&
          other.poster == this.poster &&
          other.magnetUri == this.magnetUri &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.errorMessage == this.errorMessage &&
          other.fileIndex == this.fileIndex &&
          other.audioIndex == this.audioIndex &&
          other.subtitleIndex == this.subtitleIndex &&
          other.createdAt == this.createdAt);
}

class LibraryItemsCompanion extends UpdateCompanion<LibraryItem> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> tmdbId;
  final Value<String> type;
  final Value<int?> season;
  final Value<int?> episode;
  final Value<String> title;
  final Value<String?> poster;
  final Value<String> magnetUri;
  final Value<String> status;
  final Value<double> progress;
  final Value<String?> errorMessage;
  final Value<int?> fileIndex;
  final Value<int?> audioIndex;
  final Value<int?> subtitleIndex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LibraryItemsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.type = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.title = const Value.absent(),
    this.poster = const Value.absent(),
    this.magnetUri = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.fileIndex = const Value.absent(),
    this.audioIndex = const Value.absent(),
    this.subtitleIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryItemsCompanion.insert({
    required String id,
    required String userId,
    required int tmdbId,
    required String type,
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    required String title,
    this.poster = const Value.absent(),
    required String magnetUri,
    required String status,
    this.progress = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.fileIndex = const Value.absent(),
    this.audioIndex = const Value.absent(),
    this.subtitleIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        tmdbId = Value(tmdbId),
        type = Value(type),
        title = Value(title),
        magnetUri = Value(magnetUri),
        status = Value(status);
  static Insertable<LibraryItem> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? tmdbId,
    Expression<String>? type,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<String>? title,
    Expression<String>? poster,
    Expression<String>? magnetUri,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? errorMessage,
    Expression<int>? fileIndex,
    Expression<int>? audioIndex,
    Expression<int>? subtitleIndex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (type != null) 'type': type,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (title != null) 'title': title,
      if (poster != null) 'poster': poster,
      if (magnetUri != null) 'magnet_uri': magnetUri,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (errorMessage != null) 'error_message': errorMessage,
      if (fileIndex != null) 'file_index': fileIndex,
      if (audioIndex != null) 'audio_index': audioIndex,
      if (subtitleIndex != null) 'subtitle_index': subtitleIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<int>? tmdbId,
      Value<String>? type,
      Value<int?>? season,
      Value<int?>? episode,
      Value<String>? title,
      Value<String?>? poster,
      Value<String>? magnetUri,
      Value<String>? status,
      Value<double>? progress,
      Value<String?>? errorMessage,
      Value<int?>? fileIndex,
      Value<int?>? audioIndex,
      Value<int?>? subtitleIndex,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LibraryItemsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tmdbId: tmdbId ?? this.tmdbId,
      type: type ?? this.type,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      magnetUri: magnetUri ?? this.magnetUri,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      fileIndex: fileIndex ?? this.fileIndex,
      audioIndex: audioIndex ?? this.audioIndex,
      subtitleIndex: subtitleIndex ?? this.subtitleIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (poster.present) {
      map['poster'] = Variable<String>(poster.value);
    }
    if (magnetUri.present) {
      map['magnet_uri'] = Variable<String>(magnetUri.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (fileIndex.present) {
      map['file_index'] = Variable<int>(fileIndex.value);
    }
    if (audioIndex.present) {
      map['audio_index'] = Variable<int>(audioIndex.value);
    }
    if (subtitleIndex.present) {
      map['subtitle_index'] = Variable<int>(subtitleIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('type: $type, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('title: $title, ')
          ..write('poster: $poster, ')
          ..write('magnetUri: $magnetUri, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('fileIndex: $fileIndex, ')
          ..write('audioIndex: $audioIndex, ')
          ..write('subtitleIndex: $subtitleIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StorageDataTable extends StorageData
    with TableInfo<$StorageDataTable, StorageDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, key, type, data, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_data';
  @override
  VerificationContext validateIntegrity(Insertable<StorageDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {profileId, key},
      ];
  @override
  StorageDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageDataData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StorageDataTable createAlias(String alias) {
    return $StorageDataTable(attachedDatabase, alias);
  }
}

class StorageDataData extends DataClass implements Insertable<StorageDataData> {
  final int id;
  final int profileId;
  final String key;
  final String type;
  final String data;
  final DateTime updatedAt;
  const StorageDataData(
      {required this.id,
      required this.profileId,
      required this.key,
      required this.type,
      required this.data,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['key'] = Variable<String>(key);
    map['type'] = Variable<String>(type);
    map['data'] = Variable<String>(data);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StorageDataCompanion toCompanion(bool nullToAbsent) {
    return StorageDataCompanion(
      id: Value(id),
      profileId: Value(profileId),
      key: Value(key),
      type: Value(type),
      data: Value(data),
      updatedAt: Value(updatedAt),
    );
  }

  factory StorageDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageDataData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      key: serializer.fromJson<String>(json['key']),
      type: serializer.fromJson<String>(json['type']),
      data: serializer.fromJson<String>(json['data']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'key': serializer.toJson<String>(key),
      'type': serializer.toJson<String>(type),
      'data': serializer.toJson<String>(data),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StorageDataData copyWith(
          {int? id,
          int? profileId,
          String? key,
          String? type,
          String? data,
          DateTime? updatedAt}) =>
      StorageDataData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        key: key ?? this.key,
        type: type ?? this.type,
        data: data ?? this.data,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StorageDataData copyWithCompanion(StorageDataCompanion data) {
    return StorageDataData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      key: data.key.present ? data.key.value : this.key,
      type: data.type.present ? data.type.value : this.type,
      data: data.data.present ? data.data.value : this.data,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageDataData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, key, type, data, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageDataData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.key == this.key &&
          other.type == this.type &&
          other.data == this.data &&
          other.updatedAt == this.updatedAt);
}

class StorageDataCompanion extends UpdateCompanion<StorageDataData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> key;
  final Value<String> type;
  final Value<String> data;
  final Value<DateTime> updatedAt;
  const StorageDataCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.key = const Value.absent(),
    this.type = const Value.absent(),
    this.data = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StorageDataCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String key,
    required String type,
    required String data,
    this.updatedAt = const Value.absent(),
  })  : profileId = Value(profileId),
        key = Value(key),
        type = Value(type),
        data = Value(data);
  static Insertable<StorageDataData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? key,
    Expression<String>? type,
    Expression<String>? data,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (key != null) 'key': key,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StorageDataCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? key,
      Value<String>? type,
      Value<String>? data,
      Value<DateTime>? updatedAt}) {
    return StorageDataCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      key: key ?? this.key,
      type: type ?? this.type,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageDataCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('key: $key, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserPluginsTable extends UserPlugins
    with TableInfo<$UserPluginsTable, UserPlugin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPluginsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, url, name, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_plugins';
  @override
  VerificationContext validateIntegrity(Insertable<UserPlugin> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userId, url},
      ];
  @override
  UserPlugin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlugin(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserPluginsTable createAlias(String alias) {
    return $UserPluginsTable(attachedDatabase, alias);
  }
}

class UserPlugin extends DataClass implements Insertable<UserPlugin> {
  final int id;
  final String userId;
  final String url;
  final String? name;
  final int status;
  final DateTime createdAt;
  const UserPlugin(
      {required this.id,
      required this.userId,
      required this.url,
      this.name,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserPluginsCompanion toCompanion(bool nullToAbsent) {
    return UserPluginsCompanion(
      id: Value(id),
      userId: Value(userId),
      url: Value(url),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory UserPlugin.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlugin(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      url: serializer.fromJson<String>(json['url']),
      name: serializer.fromJson<String?>(json['name']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'url': serializer.toJson<String>(url),
      'name': serializer.toJson<String?>(name),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserPlugin copyWith(
          {int? id,
          String? userId,
          String? url,
          Value<String?> name = const Value.absent(),
          int? status,
          DateTime? createdAt}) =>
      UserPlugin(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        url: url ?? this.url,
        name: name.present ? name.value : this.name,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  UserPlugin copyWithCompanion(UserPluginsCompanion data) {
    return UserPlugin(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      url: data.url.present ? data.url.value : this.url,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlugin(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('url: $url, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, url, name, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlugin &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.url == this.url &&
          other.name == this.name &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class UserPluginsCompanion extends UpdateCompanion<UserPlugin> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> url;
  final Value<String?> name;
  final Value<int> status;
  final Value<DateTime> createdAt;
  const UserPluginsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.url = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserPluginsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String url,
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : userId = Value(userId),
        url = Value(url);
  static Insertable<UserPlugin> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? url,
    Expression<String>? name,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (url != null) 'url': url,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserPluginsCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? url,
      Value<String?>? name,
      Value<int>? status,
      Value<DateTime>? createdAt}) {
    return UserPluginsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPluginsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('url: $url, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $TimelineEntriesTable timelineEntries =
      $TimelineEntriesTable(this);
  late final $BookmarkChangesTable bookmarkChanges =
      $BookmarkChangesTable(this);
  late final $ProfileVersionsTable profileVersions =
      $ProfileVersionsTable(this);
  late final $NoticesTable notices = $NoticesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PendingRegistrationsTable pendingRegistrations =
      $PendingRegistrationsTable(this);
  late final $InviteCodesTable inviteCodes = $InviteCodesTable(this);
  late final $LibraryItemsTable libraryItems = $LibraryItemsTable(this);
  late final $StorageDataTable storageData = $StorageDataTable(this);
  late final $UserPluginsTable userPlugins = $UserPluginsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        profiles,
        devices,
        bookmarks,
        timelineEntries,
        bookmarkChanges,
        profileVersions,
        notices,
        settings,
        pendingRegistrations,
        inviteCodes,
        libraryItems,
        storageData,
        userPlugins
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String passwordHash,
  Value<int> premium,
  required DateTime createdAt,
  Value<String?> telegramId,
  Value<String?> phone,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<bool> blocked,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> passwordHash,
  Value<int> premium,
  Value<DateTime> createdAt,
  Value<String?> telegramId,
  Value<String?> phone,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<bool> blocked,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<Profile>> _profilesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.profiles,
          aliasName: $_aliasNameGenerator(db.users.id, db.profiles.userId));

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DevicesTable, List<Device>> _devicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.devices,
          aliasName: $_aliasNameGenerator(db.users.id, db.devices.userId));

  $$DevicesTableProcessedTableManager get devicesRefs {
    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LibraryItemsTable, List<LibraryItem>>
      _libraryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.libraryItems,
          aliasName: $_aliasNameGenerator(db.users.id, db.libraryItems.userId));

  $$LibraryItemsTableProcessedTableManager get libraryItemsRefs {
    final manager = $$LibraryItemsTableTableManager($_db, $_db.libraryItems)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_libraryItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserPluginsTable, List<UserPlugin>>
      _userPluginsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userPlugins,
          aliasName: $_aliasNameGenerator(db.users.id, db.userPlugins.userId));

  $$UserPluginsTableProcessedTableManager get userPluginsRefs {
    final manager = $$UserPluginsTableTableManager($_db, $_db.userPlugins)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userPluginsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get premium => $composableBuilder(
      column: $table.premium, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get blocked => $composableBuilder(
      column: $table.blocked, builder: (column) => ColumnFilters(column));

  Expression<bool> profilesRefs(
      Expression<bool> Function($$ProfilesTableFilterComposer f) f) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> devicesRefs(
      Expression<bool> Function($$DevicesTableFilterComposer f) f) {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> libraryItemsRefs(
      Expression<bool> Function($$LibraryItemsTableFilterComposer f) f) {
    final $$LibraryItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.libraryItems,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibraryItemsTableFilterComposer(
              $db: $db,
              $table: $db.libraryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> userPluginsRefs(
      Expression<bool> Function($$UserPluginsTableFilterComposer f) f) {
    final $$UserPluginsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userPlugins,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserPluginsTableFilterComposer(
              $db: $db,
              $table: $db.userPlugins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get premium => $composableBuilder(
      column: $table.premium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get blocked => $composableBuilder(
      column: $table.blocked, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<int> get premium =>
      $composableBuilder(column: $table.premium, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => column);

  Expression<T> profilesRefs<T extends Object>(
      Expression<T> Function($$ProfilesTableAnnotationComposer a) f) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> devicesRefs<T extends Object>(
      Expression<T> Function($$DevicesTableAnnotationComposer a) f) {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> libraryItemsRefs<T extends Object>(
      Expression<T> Function($$LibraryItemsTableAnnotationComposer a) f) {
    final $$LibraryItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.libraryItems,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LibraryItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.libraryItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> userPluginsRefs<T extends Object>(
      Expression<T> Function($$UserPluginsTableAnnotationComposer a) f) {
    final $$UserPluginsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userPlugins,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserPluginsTableAnnotationComposer(
              $db: $db,
              $table: $db.userPlugins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool profilesRefs,
        bool devicesRefs,
        bool libraryItemsRefs,
        bool userPluginsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<int> premium = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> telegramId = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<bool> blocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            passwordHash: passwordHash,
            premium: premium,
            createdAt: createdAt,
            telegramId: telegramId,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            blocked: blocked,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String passwordHash,
            Value<int> premium = const Value.absent(),
            required DateTime createdAt,
            Value<String?> telegramId = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<bool> blocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            passwordHash: passwordHash,
            premium: premium,
            createdAt: createdAt,
            telegramId: telegramId,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            blocked: blocked,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profilesRefs = false,
              devicesRefs = false,
              libraryItemsRefs = false,
              userPluginsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (profilesRefs) db.profiles,
                if (devicesRefs) db.devices,
                if (libraryItemsRefs) db.libraryItems,
                if (userPluginsRefs) db.userPlugins
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedData<User, $UsersTable, Profile>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._profilesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).profilesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (devicesRefs)
                    await $_getPrefetchedData<User, $UsersTable, Device>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._devicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).devicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (libraryItemsRefs)
                    await $_getPrefetchedData<User, $UsersTable, LibraryItem>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._libraryItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .libraryItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (userPluginsRefs)
                    await $_getPrefetchedData<User, $UsersTable, UserPlugin>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._userPluginsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .userPluginsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function(
        {bool profilesRefs,
        bool devicesRefs,
        bool libraryItemsRefs,
        bool userPluginsRefs})>;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String userId,
  required String name,
  Value<String> icon,
  Value<int> age,
  Value<bool> adult,
  Value<bool> main,
  Value<DateTime> createdAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> name,
  Value<String> icon,
  Value<int> age,
  Value<bool> adult,
  Value<bool> main,
  Value<DateTime> createdAt,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.profiles.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
      _bookmarksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookmarks,
              aliasName:
                  $_aliasNameGenerator(db.profiles.id, db.bookmarks.profileId));

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager($_db, $_db.bookmarks)
        .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TimelineEntriesTable, List<TimelineEntry>>
      _timelineEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.timelineEntries,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.timelineEntries.profileId));

  $$TimelineEntriesTableProcessedTableManager get timelineEntriesRefs {
    final manager =
        $$TimelineEntriesTableTableManager($_db, $_db.timelineEntries)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_timelineEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookmarkChangesTable, List<BookmarkChange>>
      _bookmarkChangesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookmarkChanges,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.bookmarkChanges.profileId));

  $$BookmarkChangesTableProcessedTableManager get bookmarkChangesRefs {
    final manager =
        $$BookmarkChangesTableTableManager($_db, $_db.bookmarkChanges)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_bookmarkChangesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProfileVersionsTable, List<ProfileVersion>>
      _profileVersionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.profileVersions,
              aliasName: $_aliasNameGenerator(
                  db.profiles.id, db.profileVersions.profileId));

  $$ProfileVersionsTableProcessedTableManager get profileVersionsRefs {
    final manager =
        $$ProfileVersionsTableTableManager($_db, $_db.profileVersions)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_profileVersionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StorageDataTable, List<StorageDataData>>
      _storageDataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.storageData,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.storageData.profileId));

  $$StorageDataTableProcessedTableManager get storageDataRefs {
    final manager = $$StorageDataTableTableManager($_db, $_db.storageData)
        .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_storageDataRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get adult => $composableBuilder(
      column: $table.adult, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get main => $composableBuilder(
      column: $table.main, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> bookmarksRefs(
      Expression<bool> Function($$BookmarksTableFilterComposer f) f) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableFilterComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> timelineEntriesRefs(
      Expression<bool> Function($$TimelineEntriesTableFilterComposer f) f) {
    final $$TimelineEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timelineEntries,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimelineEntriesTableFilterComposer(
              $db: $db,
              $table: $db.timelineEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookmarkChangesRefs(
      Expression<bool> Function($$BookmarkChangesTableFilterComposer f) f) {
    final $$BookmarkChangesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarkChanges,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarkChangesTableFilterComposer(
              $db: $db,
              $table: $db.bookmarkChanges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> profileVersionsRefs(
      Expression<bool> Function($$ProfileVersionsTableFilterComposer f) f) {
    final $$ProfileVersionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profileVersions,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileVersionsTableFilterComposer(
              $db: $db,
              $table: $db.profileVersions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> storageDataRefs(
      Expression<bool> Function($$StorageDataTableFilterComposer f) f) {
    final $$StorageDataTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.storageData,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StorageDataTableFilterComposer(
              $db: $db,
              $table: $db.storageData,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get adult => $composableBuilder(
      column: $table.adult, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get main => $composableBuilder(
      column: $table.main, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<bool> get adult =>
      $composableBuilder(column: $table.adult, builder: (column) => column);

  GeneratedColumn<bool> get main =>
      $composableBuilder(column: $table.main, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> bookmarksRefs<T extends Object>(
      Expression<T> Function($$BookmarksTableAnnotationComposer a) f) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableAnnotationComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> timelineEntriesRefs<T extends Object>(
      Expression<T> Function($$TimelineEntriesTableAnnotationComposer a) f) {
    final $$TimelineEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timelineEntries,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimelineEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.timelineEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bookmarkChangesRefs<T extends Object>(
      Expression<T> Function($$BookmarkChangesTableAnnotationComposer a) f) {
    final $$BookmarkChangesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarkChanges,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarkChangesTableAnnotationComposer(
              $db: $db,
              $table: $db.bookmarkChanges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> profileVersionsRefs<T extends Object>(
      Expression<T> Function($$ProfileVersionsTableAnnotationComposer a) f) {
    final $$ProfileVersionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.profileVersions,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileVersionsTableAnnotationComposer(
              $db: $db,
              $table: $db.profileVersions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> storageDataRefs<T extends Object>(
      Expression<T> Function($$StorageDataTableAnnotationComposer a) f) {
    final $$StorageDataTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.storageData,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StorageDataTableAnnotationComposer(
              $db: $db,
              $table: $db.storageData,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool userId,
        bool bookmarksRefs,
        bool timelineEntriesRefs,
        bool bookmarkChangesRefs,
        bool profileVersionsRefs,
        bool storageDataRefs})> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<bool> adult = const Value.absent(),
            Value<bool> main = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            userId: userId,
            name: name,
            icon: icon,
            age: age,
            adult: adult,
            main: main,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String name,
            Value<String> icon = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<bool> adult = const Value.absent(),
            Value<bool> main = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            icon: icon,
            age: age,
            adult: adult,
            main: main,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              bookmarksRefs = false,
              timelineEntriesRefs = false,
              bookmarkChangesRefs = false,
              profileVersionsRefs = false,
              storageDataRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookmarksRefs) db.bookmarks,
                if (timelineEntriesRefs) db.timelineEntries,
                if (bookmarkChangesRefs) db.bookmarkChanges,
                if (profileVersionsRefs) db.profileVersions,
                if (storageDataRefs) db.storageData
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$ProfilesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ProfilesTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarksRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            Bookmark>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._bookmarksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .bookmarksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (timelineEntriesRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            TimelineEntry>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._timelineEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .timelineEntriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (bookmarkChangesRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            BookmarkChange>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._bookmarkChangesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .bookmarkChangesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (profileVersionsRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            ProfileVersion>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._profileVersionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .profileVersionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (storageDataRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable,
                            StorageDataData>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._storageDataRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .storageDataRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool userId,
        bool bookmarksRefs,
        bool timelineEntriesRefs,
        bool bookmarkChangesRefs,
        bool profileVersionsRefs,
        bool storageDataRefs})>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String userId,
  Value<String> name,
  Value<String> platform,
  required String token,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSeen,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String> platform,
  Value<String> token,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSeen,
  Value<int> rowid,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.devices.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool userId})> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSeen = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            userId: userId,
            name: name,
            platform: platform,
            token: token,
            createdAt: createdAt,
            lastSeen: lastSeen,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String> name = const Value.absent(),
            Value<String> platform = const Value.absent(),
            required String token,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSeen = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            platform: platform,
            token: token,
            createdAt: createdAt,
            lastSeen: lastSeen,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DevicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$DevicesTableReferences._userIdTable(db),
                    referencedColumn:
                        $$DevicesTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool userId})>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int profileId,
  Value<String> type,
  required int cardId,
  required String data,
  required int time,
  Value<DateTime> createdAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> type,
  Value<int> cardId,
  Value<String> data,
  Value<int> time,
  Value<DateTime> createdAt,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.bookmarks.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, $$BookmarksTableReferences),
    Bookmark,
    PrefetchHooks Function({bool profileId})> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> cardId = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<int> time = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            profileId: profileId,
            type: type,
            cardId: cardId,
            data: data,
            time: time,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            Value<String> type = const Value.absent(),
            required int cardId,
            required String data,
            required int time,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            profileId: profileId,
            type: type,
            cardId: cardId,
            data: data,
            time: time,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookmarksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$BookmarksTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$BookmarksTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, $$BookmarksTableReferences),
    Bookmark,
    PrefetchHooks Function({bool profileId})>;
typedef $$TimelineEntriesTableCreateCompanionBuilder = TimelineEntriesCompanion
    Function({
  Value<int> id,
  required int profileId,
  required String hash,
  Value<double> percent,
  Value<double> time,
  Value<double> duration,
  Value<DateTime> updatedAt,
});
typedef $$TimelineEntriesTableUpdateCompanionBuilder = TimelineEntriesCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> hash,
  Value<double> percent,
  Value<double> time,
  Value<double> duration,
  Value<DateTime> updatedAt,
});

final class $$TimelineEntriesTableReferences extends BaseReferences<
    _$AppDatabase, $TimelineEntriesTable, TimelineEntry> {
  $$TimelineEntriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.timelineEntries.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimelineEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percent => $composableBuilder(
      column: $table.percent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimelineEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percent => $composableBuilder(
      column: $table.percent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimelineEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<double> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<double> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimelineEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimelineEntriesTable,
    TimelineEntry,
    $$TimelineEntriesTableFilterComposer,
    $$TimelineEntriesTableOrderingComposer,
    $$TimelineEntriesTableAnnotationComposer,
    $$TimelineEntriesTableCreateCompanionBuilder,
    $$TimelineEntriesTableUpdateCompanionBuilder,
    (TimelineEntry, $$TimelineEntriesTableReferences),
    TimelineEntry,
    PrefetchHooks Function({bool profileId})> {
  $$TimelineEntriesTableTableManager(
      _$AppDatabase db, $TimelineEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<double> percent = const Value.absent(),
            Value<double> time = const Value.absent(),
            Value<double> duration = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TimelineEntriesCompanion(
            id: id,
            profileId: profileId,
            hash: hash,
            percent: percent,
            time: time,
            duration: duration,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required String hash,
            Value<double> percent = const Value.absent(),
            Value<double> time = const Value.absent(),
            Value<double> duration = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TimelineEntriesCompanion.insert(
            id: id,
            profileId: profileId,
            hash: hash,
            percent: percent,
            time: time,
            duration: duration,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TimelineEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$TimelineEntriesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$TimelineEntriesTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TimelineEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimelineEntriesTable,
    TimelineEntry,
    $$TimelineEntriesTableFilterComposer,
    $$TimelineEntriesTableOrderingComposer,
    $$TimelineEntriesTableAnnotationComposer,
    $$TimelineEntriesTableCreateCompanionBuilder,
    $$TimelineEntriesTableUpdateCompanionBuilder,
    (TimelineEntry, $$TimelineEntriesTableReferences),
    TimelineEntry,
    PrefetchHooks Function({bool profileId})>;
typedef $$BookmarkChangesTableCreateCompanionBuilder = BookmarkChangesCompanion
    Function({
  Value<int> id,
  required int profileId,
  required int version,
  required String action,
  required int entityId,
  Value<String?> type,
  Value<int?> cardId,
  Value<String> data,
  required int time,
});
typedef $$BookmarkChangesTableUpdateCompanionBuilder = BookmarkChangesCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<int> version,
  Value<String> action,
  Value<int> entityId,
  Value<String?> type,
  Value<int?> cardId,
  Value<String> data,
  Value<int> time,
});

final class $$BookmarkChangesTableReferences extends BaseReferences<
    _$AppDatabase, $BookmarkChangesTable, BookmarkChange> {
  $$BookmarkChangesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.bookmarkChanges.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookmarkChangesTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkChangesTable> {
  $$BookmarkChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarkChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkChangesTable> {
  $$BookmarkChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarkChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkChangesTable> {
  $$BookmarkChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarkChangesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarkChangesTable,
    BookmarkChange,
    $$BookmarkChangesTableFilterComposer,
    $$BookmarkChangesTableOrderingComposer,
    $$BookmarkChangesTableAnnotationComposer,
    $$BookmarkChangesTableCreateCompanionBuilder,
    $$BookmarkChangesTableUpdateCompanionBuilder,
    (BookmarkChange, $$BookmarkChangesTableReferences),
    BookmarkChange,
    PrefetchHooks Function({bool profileId})> {
  $$BookmarkChangesTableTableManager(
      _$AppDatabase db, $BookmarkChangesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<int> entityId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<int?> cardId = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<int> time = const Value.absent(),
          }) =>
              BookmarkChangesCompanion(
            id: id,
            profileId: profileId,
            version: version,
            action: action,
            entityId: entityId,
            type: type,
            cardId: cardId,
            data: data,
            time: time,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required int version,
            required String action,
            required int entityId,
            Value<String?> type = const Value.absent(),
            Value<int?> cardId = const Value.absent(),
            Value<String> data = const Value.absent(),
            required int time,
          }) =>
              BookmarkChangesCompanion.insert(
            id: id,
            profileId: profileId,
            version: version,
            action: action,
            entityId: entityId,
            type: type,
            cardId: cardId,
            data: data,
            time: time,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookmarkChangesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$BookmarkChangesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$BookmarkChangesTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookmarkChangesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarkChangesTable,
    BookmarkChange,
    $$BookmarkChangesTableFilterComposer,
    $$BookmarkChangesTableOrderingComposer,
    $$BookmarkChangesTableAnnotationComposer,
    $$BookmarkChangesTableCreateCompanionBuilder,
    $$BookmarkChangesTableUpdateCompanionBuilder,
    (BookmarkChange, $$BookmarkChangesTableReferences),
    BookmarkChange,
    PrefetchHooks Function({bool profileId})>;
typedef $$ProfileVersionsTableCreateCompanionBuilder = ProfileVersionsCompanion
    Function({
  Value<int> profileId,
  Value<int> bookmarkVersion,
  Value<int> timelineVersion,
});
typedef $$ProfileVersionsTableUpdateCompanionBuilder = ProfileVersionsCompanion
    Function({
  Value<int> profileId,
  Value<int> bookmarkVersion,
  Value<int> timelineVersion,
});

final class $$ProfileVersionsTableReferences extends BaseReferences<
    _$AppDatabase, $ProfileVersionsTable, ProfileVersion> {
  $$ProfileVersionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.profileVersions.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileVersionsTable> {
  $$ProfileVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get bookmarkVersion => $composableBuilder(
      column: $table.bookmarkVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timelineVersion => $composableBuilder(
      column: $table.timelineVersion,
      builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfileVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileVersionsTable> {
  $$ProfileVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get bookmarkVersion => $composableBuilder(
      column: $table.bookmarkVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timelineVersion => $composableBuilder(
      column: $table.timelineVersion,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfileVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileVersionsTable> {
  $$ProfileVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get bookmarkVersion => $composableBuilder(
      column: $table.bookmarkVersion, builder: (column) => column);

  GeneratedColumn<int> get timelineVersion => $composableBuilder(
      column: $table.timelineVersion, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfileVersionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfileVersionsTable,
    ProfileVersion,
    $$ProfileVersionsTableFilterComposer,
    $$ProfileVersionsTableOrderingComposer,
    $$ProfileVersionsTableAnnotationComposer,
    $$ProfileVersionsTableCreateCompanionBuilder,
    $$ProfileVersionsTableUpdateCompanionBuilder,
    (ProfileVersion, $$ProfileVersionsTableReferences),
    ProfileVersion,
    PrefetchHooks Function({bool profileId})> {
  $$ProfileVersionsTableTableManager(
      _$AppDatabase db, $ProfileVersionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            Value<int> bookmarkVersion = const Value.absent(),
            Value<int> timelineVersion = const Value.absent(),
          }) =>
              ProfileVersionsCompanion(
            profileId: profileId,
            bookmarkVersion: bookmarkVersion,
            timelineVersion: timelineVersion,
          ),
          createCompanionCallback: ({
            Value<int> profileId = const Value.absent(),
            Value<int> bookmarkVersion = const Value.absent(),
            Value<int> timelineVersion = const Value.absent(),
          }) =>
              ProfileVersionsCompanion.insert(
            profileId: profileId,
            bookmarkVersion: bookmarkVersion,
            timelineVersion: timelineVersion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProfileVersionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ProfileVersionsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ProfileVersionsTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProfileVersionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfileVersionsTable,
    ProfileVersion,
    $$ProfileVersionsTableFilterComposer,
    $$ProfileVersionsTableOrderingComposer,
    $$ProfileVersionsTableAnnotationComposer,
    $$ProfileVersionsTableCreateCompanionBuilder,
    $$ProfileVersionsTableUpdateCompanionBuilder,
    (ProfileVersion, $$ProfileVersionsTableReferences),
    ProfileVersion,
    PrefetchHooks Function({bool profileId})>;
typedef $$NoticesTableCreateCompanionBuilder = NoticesCompanion Function({
  Value<int> id,
  Value<String> noticeType,
  Value<String?> title,
  Value<String?> noticeText,
  Value<String?> image,
  Value<String?> data,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
});
typedef $$NoticesTableUpdateCompanionBuilder = NoticesCompanion Function({
  Value<int> id,
  Value<String> noticeType,
  Value<String?> title,
  Value<String?> noticeText,
  Value<String?> image,
  Value<String?> data,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
});

class $$NoticesTableFilterComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noticeType => $composableBuilder(
      column: $table.noticeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noticeText => $composableBuilder(
      column: $table.noticeText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$NoticesTableOrderingComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noticeType => $composableBuilder(
      column: $table.noticeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noticeText => $composableBuilder(
      column: $table.noticeText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$NoticesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noticeType => $composableBuilder(
      column: $table.noticeType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get noticeText => $composableBuilder(
      column: $table.noticeText, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$NoticesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NoticesTable,
    Notice,
    $$NoticesTableFilterComposer,
    $$NoticesTableOrderingComposer,
    $$NoticesTableAnnotationComposer,
    $$NoticesTableCreateCompanionBuilder,
    $$NoticesTableUpdateCompanionBuilder,
    (Notice, BaseReferences<_$AppDatabase, $NoticesTable, Notice>),
    Notice,
    PrefetchHooks Function()> {
  $$NoticesTableTableManager(_$AppDatabase db, $NoticesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> noticeType = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> noticeText = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
          }) =>
              NoticesCompanion(
            id: id,
            noticeType: noticeType,
            title: title,
            noticeText: noticeText,
            image: image,
            data: data,
            active: active,
            createdAt: createdAt,
            expiresAt: expiresAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> noticeType = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> noticeText = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
          }) =>
              NoticesCompanion.insert(
            id: id,
            noticeType: noticeType,
            title: title,
            noticeText: noticeText,
            image: image,
            data: data,
            active: active,
            createdAt: createdAt,
            expiresAt: expiresAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NoticesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NoticesTable,
    Notice,
    $$NoticesTableFilterComposer,
    $$NoticesTableOrderingComposer,
    $$NoticesTableAnnotationComposer,
    $$NoticesTableCreateCompanionBuilder,
    $$NoticesTableUpdateCompanionBuilder,
    (Notice, BaseReferences<_$AppDatabase, $NoticesTable, Notice>),
    Notice,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$PendingRegistrationsTableCreateCompanionBuilder
    = PendingRegistrationsCompanion Function({
  Value<int> id,
  required String telegramId,
  required String phone,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<DateTime> createdAt,
});
typedef $$PendingRegistrationsTableUpdateCompanionBuilder
    = PendingRegistrationsCompanion Function({
  Value<int> id,
  Value<String> telegramId,
  Value<String> phone,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<DateTime> createdAt,
});

class $$PendingRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingRegistrationsTable> {
  $$PendingRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PendingRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingRegistrationsTable> {
  $$PendingRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PendingRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingRegistrationsTable> {
  $$PendingRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get telegramId => $composableBuilder(
      column: $table.telegramId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingRegistrationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingRegistrationsTable,
    PendingRegistration,
    $$PendingRegistrationsTableFilterComposer,
    $$PendingRegistrationsTableOrderingComposer,
    $$PendingRegistrationsTableAnnotationComposer,
    $$PendingRegistrationsTableCreateCompanionBuilder,
    $$PendingRegistrationsTableUpdateCompanionBuilder,
    (
      PendingRegistration,
      BaseReferences<_$AppDatabase, $PendingRegistrationsTable,
          PendingRegistration>
    ),
    PendingRegistration,
    PrefetchHooks Function()> {
  $$PendingRegistrationsTableTableManager(
      _$AppDatabase db, $PendingRegistrationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingRegistrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingRegistrationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingRegistrationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> telegramId = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRegistrationsCompanion(
            id: id,
            telegramId: telegramId,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String telegramId,
            required String phone,
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRegistrationsCompanion.insert(
            id: id,
            telegramId: telegramId,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingRegistrationsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PendingRegistrationsTable,
        PendingRegistration,
        $$PendingRegistrationsTableFilterComposer,
        $$PendingRegistrationsTableOrderingComposer,
        $$PendingRegistrationsTableAnnotationComposer,
        $$PendingRegistrationsTableCreateCompanionBuilder,
        $$PendingRegistrationsTableUpdateCompanionBuilder,
        (
          PendingRegistration,
          BaseReferences<_$AppDatabase, $PendingRegistrationsTable,
              PendingRegistration>
        ),
        PendingRegistration,
        PrefetchHooks Function()>;
typedef $$InviteCodesTableCreateCompanionBuilder = InviteCodesCompanion
    Function({
  Value<int> id,
  required String code,
  Value<bool> oneTime,
  Value<int> usesLeft,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
});
typedef $$InviteCodesTableUpdateCompanionBuilder = InviteCodesCompanion
    Function({
  Value<int> id,
  Value<String> code,
  Value<bool> oneTime,
  Value<int> usesLeft,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
});

class $$InviteCodesTableFilterComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get oneTime => $composableBuilder(
      column: $table.oneTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usesLeft => $composableBuilder(
      column: $table.usesLeft, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$InviteCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get oneTime => $composableBuilder(
      column: $table.oneTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usesLeft => $composableBuilder(
      column: $table.usesLeft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$InviteCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get oneTime =>
      $composableBuilder(column: $table.oneTime, builder: (column) => column);

  GeneratedColumn<int> get usesLeft =>
      $composableBuilder(column: $table.usesLeft, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$InviteCodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InviteCodesTable,
    InviteCode,
    $$InviteCodesTableFilterComposer,
    $$InviteCodesTableOrderingComposer,
    $$InviteCodesTableAnnotationComposer,
    $$InviteCodesTableCreateCompanionBuilder,
    $$InviteCodesTableUpdateCompanionBuilder,
    (InviteCode, BaseReferences<_$AppDatabase, $InviteCodesTable, InviteCode>),
    InviteCode,
    PrefetchHooks Function()> {
  $$InviteCodesTableTableManager(_$AppDatabase db, $InviteCodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InviteCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InviteCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InviteCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<bool> oneTime = const Value.absent(),
            Value<int> usesLeft = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
          }) =>
              InviteCodesCompanion(
            id: id,
            code: code,
            oneTime: oneTime,
            usesLeft: usesLeft,
            createdAt: createdAt,
            expiresAt: expiresAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            Value<bool> oneTime = const Value.absent(),
            Value<int> usesLeft = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
          }) =>
              InviteCodesCompanion.insert(
            id: id,
            code: code,
            oneTime: oneTime,
            usesLeft: usesLeft,
            createdAt: createdAt,
            expiresAt: expiresAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InviteCodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InviteCodesTable,
    InviteCode,
    $$InviteCodesTableFilterComposer,
    $$InviteCodesTableOrderingComposer,
    $$InviteCodesTableAnnotationComposer,
    $$InviteCodesTableCreateCompanionBuilder,
    $$InviteCodesTableUpdateCompanionBuilder,
    (InviteCode, BaseReferences<_$AppDatabase, $InviteCodesTable, InviteCode>),
    InviteCode,
    PrefetchHooks Function()>;
typedef $$LibraryItemsTableCreateCompanionBuilder = LibraryItemsCompanion
    Function({
  required String id,
  required String userId,
  required int tmdbId,
  required String type,
  Value<int?> season,
  Value<int?> episode,
  required String title,
  Value<String?> poster,
  required String magnetUri,
  required String status,
  Value<double> progress,
  Value<String?> errorMessage,
  Value<int?> fileIndex,
  Value<int?> audioIndex,
  Value<int?> subtitleIndex,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LibraryItemsTableUpdateCompanionBuilder = LibraryItemsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<int> tmdbId,
  Value<String> type,
  Value<int?> season,
  Value<int?> episode,
  Value<String> title,
  Value<String?> poster,
  Value<String> magnetUri,
  Value<String> status,
  Value<double> progress,
  Value<String?> errorMessage,
  Value<int?> fileIndex,
  Value<int?> audioIndex,
  Value<int?> subtitleIndex,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$LibraryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem> {
  $$LibraryItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.libraryItems.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LibraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poster => $composableBuilder(
      column: $table.poster, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get magnetUri => $composableBuilder(
      column: $table.magnetUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileIndex => $composableBuilder(
      column: $table.fileIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get audioIndex => $composableBuilder(
      column: $table.audioIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtitleIndex => $composableBuilder(
      column: $table.subtitleIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LibraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tmdbId => $composableBuilder(
      column: $table.tmdbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poster => $composableBuilder(
      column: $table.poster, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get magnetUri => $composableBuilder(
      column: $table.magnetUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileIndex => $composableBuilder(
      column: $table.fileIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get audioIndex => $composableBuilder(
      column: $table.audioIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtitleIndex => $composableBuilder(
      column: $table.subtitleIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LibraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get poster =>
      $composableBuilder(column: $table.poster, builder: (column) => column);

  GeneratedColumn<String> get magnetUri =>
      $composableBuilder(column: $table.magnetUri, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get fileIndex =>
      $composableBuilder(column: $table.fileIndex, builder: (column) => column);

  GeneratedColumn<int> get audioIndex => $composableBuilder(
      column: $table.audioIndex, builder: (column) => column);

  GeneratedColumn<int> get subtitleIndex => $composableBuilder(
      column: $table.subtitleIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LibraryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LibraryItemsTable,
    LibraryItem,
    $$LibraryItemsTableFilterComposer,
    $$LibraryItemsTableOrderingComposer,
    $$LibraryItemsTableAnnotationComposer,
    $$LibraryItemsTableCreateCompanionBuilder,
    $$LibraryItemsTableUpdateCompanionBuilder,
    (LibraryItem, $$LibraryItemsTableReferences),
    LibraryItem,
    PrefetchHooks Function({bool userId})> {
  $$LibraryItemsTableTableManager(_$AppDatabase db, $LibraryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> tmdbId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> season = const Value.absent(),
            Value<int?> episode = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> poster = const Value.absent(),
            Value<String> magnetUri = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int?> fileIndex = const Value.absent(),
            Value<int?> audioIndex = const Value.absent(),
            Value<int?> subtitleIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryItemsCompanion(
            id: id,
            userId: userId,
            tmdbId: tmdbId,
            type: type,
            season: season,
            episode: episode,
            title: title,
            poster: poster,
            magnetUri: magnetUri,
            status: status,
            progress: progress,
            errorMessage: errorMessage,
            fileIndex: fileIndex,
            audioIndex: audioIndex,
            subtitleIndex: subtitleIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required int tmdbId,
            required String type,
            Value<int?> season = const Value.absent(),
            Value<int?> episode = const Value.absent(),
            required String title,
            Value<String?> poster = const Value.absent(),
            required String magnetUri,
            required String status,
            Value<double> progress = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int?> fileIndex = const Value.absent(),
            Value<int?> audioIndex = const Value.absent(),
            Value<int?> subtitleIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryItemsCompanion.insert(
            id: id,
            userId: userId,
            tmdbId: tmdbId,
            type: type,
            season: season,
            episode: episode,
            title: title,
            poster: poster,
            magnetUri: magnetUri,
            status: status,
            progress: progress,
            errorMessage: errorMessage,
            fileIndex: fileIndex,
            audioIndex: audioIndex,
            subtitleIndex: subtitleIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LibraryItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$LibraryItemsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$LibraryItemsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LibraryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LibraryItemsTable,
    LibraryItem,
    $$LibraryItemsTableFilterComposer,
    $$LibraryItemsTableOrderingComposer,
    $$LibraryItemsTableAnnotationComposer,
    $$LibraryItemsTableCreateCompanionBuilder,
    $$LibraryItemsTableUpdateCompanionBuilder,
    (LibraryItem, $$LibraryItemsTableReferences),
    LibraryItem,
    PrefetchHooks Function({bool userId})>;
typedef $$StorageDataTableCreateCompanionBuilder = StorageDataCompanion
    Function({
  Value<int> id,
  required int profileId,
  required String key,
  required String type,
  required String data,
  Value<DateTime> updatedAt,
});
typedef $$StorageDataTableUpdateCompanionBuilder = StorageDataCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> key,
  Value<String> type,
  Value<String> data,
  Value<DateTime> updatedAt,
});

final class $$StorageDataTableReferences
    extends BaseReferences<_$AppDatabase, $StorageDataTable, StorageDataData> {
  $$StorageDataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.storageData.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StorageDataTableFilterComposer
    extends Composer<_$AppDatabase, $StorageDataTable> {
  $$StorageDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StorageDataTableOrderingComposer
    extends Composer<_$AppDatabase, $StorageDataTable> {
  $$StorageDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StorageDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $StorageDataTable> {
  $$StorageDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StorageDataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StorageDataTable,
    StorageDataData,
    $$StorageDataTableFilterComposer,
    $$StorageDataTableOrderingComposer,
    $$StorageDataTableAnnotationComposer,
    $$StorageDataTableCreateCompanionBuilder,
    $$StorageDataTableUpdateCompanionBuilder,
    (StorageDataData, $$StorageDataTableReferences),
    StorageDataData,
    PrefetchHooks Function({bool profileId})> {
  $$StorageDataTableTableManager(_$AppDatabase db, $StorageDataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StorageDataCompanion(
            id: id,
            profileId: profileId,
            key: key,
            type: type,
            data: data,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required String key,
            required String type,
            required String data,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StorageDataCompanion.insert(
            id: id,
            profileId: profileId,
            key: key,
            type: type,
            data: data,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StorageDataTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$StorageDataTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$StorageDataTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StorageDataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StorageDataTable,
    StorageDataData,
    $$StorageDataTableFilterComposer,
    $$StorageDataTableOrderingComposer,
    $$StorageDataTableAnnotationComposer,
    $$StorageDataTableCreateCompanionBuilder,
    $$StorageDataTableUpdateCompanionBuilder,
    (StorageDataData, $$StorageDataTableReferences),
    StorageDataData,
    PrefetchHooks Function({bool profileId})>;
typedef $$UserPluginsTableCreateCompanionBuilder = UserPluginsCompanion
    Function({
  Value<int> id,
  required String userId,
  required String url,
  Value<String?> name,
  Value<int> status,
  Value<DateTime> createdAt,
});
typedef $$UserPluginsTableUpdateCompanionBuilder = UserPluginsCompanion
    Function({
  Value<int> id,
  Value<String> userId,
  Value<String> url,
  Value<String?> name,
  Value<int> status,
  Value<DateTime> createdAt,
});

final class $$UserPluginsTableReferences
    extends BaseReferences<_$AppDatabase, $UserPluginsTable, UserPlugin> {
  $$UserPluginsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.userPlugins.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserPluginsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPluginsTable> {
  $$UserPluginsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPluginsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPluginsTable> {
  $$UserPluginsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPluginsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPluginsTable> {
  $$UserPluginsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserPluginsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserPluginsTable,
    UserPlugin,
    $$UserPluginsTableFilterComposer,
    $$UserPluginsTableOrderingComposer,
    $$UserPluginsTableAnnotationComposer,
    $$UserPluginsTableCreateCompanionBuilder,
    $$UserPluginsTableUpdateCompanionBuilder,
    (UserPlugin, $$UserPluginsTableReferences),
    UserPlugin,
    PrefetchHooks Function({bool userId})> {
  $$UserPluginsTableTableManager(_$AppDatabase db, $UserPluginsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPluginsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPluginsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPluginsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UserPluginsCompanion(
            id: id,
            userId: userId,
            url: url,
            name: name,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String url,
            Value<String?> name = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UserPluginsCompanion.insert(
            id: id,
            userId: userId,
            url: url,
            name: name,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserPluginsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserPluginsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserPluginsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserPluginsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserPluginsTable,
    UserPlugin,
    $$UserPluginsTableFilterComposer,
    $$UserPluginsTableOrderingComposer,
    $$UserPluginsTableAnnotationComposer,
    $$UserPluginsTableCreateCompanionBuilder,
    $$UserPluginsTableUpdateCompanionBuilder,
    (UserPlugin, $$UserPluginsTableReferences),
    UserPlugin,
    PrefetchHooks Function({bool userId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$TimelineEntriesTableTableManager get timelineEntries =>
      $$TimelineEntriesTableTableManager(_db, _db.timelineEntries);
  $$BookmarkChangesTableTableManager get bookmarkChanges =>
      $$BookmarkChangesTableTableManager(_db, _db.bookmarkChanges);
  $$ProfileVersionsTableTableManager get profileVersions =>
      $$ProfileVersionsTableTableManager(_db, _db.profileVersions);
  $$NoticesTableTableManager get notices =>
      $$NoticesTableTableManager(_db, _db.notices);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PendingRegistrationsTableTableManager get pendingRegistrations =>
      $$PendingRegistrationsTableTableManager(_db, _db.pendingRegistrations);
  $$InviteCodesTableTableManager get inviteCodes =>
      $$InviteCodesTableTableManager(_db, _db.inviteCodes);
  $$LibraryItemsTableTableManager get libraryItems =>
      $$LibraryItemsTableTableManager(_db, _db.libraryItems);
  $$StorageDataTableTableManager get storageData =>
      $$StorageDataTableTableManager(_db, _db.storageData);
  $$UserPluginsTableTableManager get userPlugins =>
      $$UserPluginsTableTableManager(_db, _db.userPlugins);
}
