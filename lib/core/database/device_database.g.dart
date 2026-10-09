// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinVerifierMeta = const VerificationMeta(
    'pinVerifier',
  );
  @override
  late final GeneratedColumn<String> pinVerifier = GeneratedColumn<String>(
    'pin_verifier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    displayName,
    pinVerifier,
    pinSalt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('pin_verifier')) {
      context.handle(
        _pinVerifierMeta,
        pinVerifier.isAcceptableOrUnknown(
          data['pin_verifier']!,
          _pinVerifierMeta,
        ),
      );
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      pinVerifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_verifier'],
      ),
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String userId;
  final String displayName;
  final String? pinVerifier;
  final String? pinSalt;
  final DateTime createdAt;
  const LocalUser({
    required this.userId,
    required this.displayName,
    this.pinVerifier,
    this.pinSalt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || pinVerifier != null) {
      map['pin_verifier'] = Variable<String>(pinVerifier);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      userId: Value(userId),
      displayName: Value(displayName),
      pinVerifier: pinVerifier == null && nullToAbsent
          ? const Value.absent()
          : Value(pinVerifier),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      createdAt: Value(createdAt),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pinVerifier: serializer.fromJson<String?>(json['pinVerifier']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'pinVerifier': serializer.toJson<String?>(pinVerifier),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalUser copyWith({
    String? userId,
    String? displayName,
    Value<String?> pinVerifier = const Value.absent(),
    Value<String?> pinSalt = const Value.absent(),
    DateTime? createdAt,
  }) => LocalUser(
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    pinVerifier: pinVerifier.present ? pinVerifier.value : this.pinVerifier,
    pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      pinVerifier: data.pinVerifier.present
          ? data.pinVerifier.value
          : this.pinVerifier,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('pinVerifier: $pinVerifier, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, displayName, pinVerifier, pinSalt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.pinVerifier == this.pinVerifier &&
          other.pinSalt == this.pinSalt &&
          other.createdAt == this.createdAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String?> pinVerifier;
  final Value<String?> pinSalt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pinVerifier = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String userId,
    required String displayName,
    this.pinVerifier = const Value.absent(),
    this.pinSalt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<LocalUser> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? pinVerifier,
    Expression<String>? pinSalt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (pinVerifier != null) 'pin_verifier': pinVerifier,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? userId,
    Value<String>? displayName,
    Value<String?>? pinVerifier,
    Value<String?>? pinSalt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      pinVerifier: pinVerifier ?? this.pinVerifier,
      pinSalt: pinSalt ?? this.pinSalt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pinVerifier.present) {
      map['pin_verifier'] = Variable<String>(pinVerifier.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
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
    return (StringBuffer('LocalUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('pinVerifier: $pinVerifier, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PairedDevicesTable extends PairedDevices
    with TableInfo<$PairedDevicesTable, PairedDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairedDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    name,
    platform,
    publicKey,
    userId,
    pairedAt,
    lastSyncAt,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paired_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairedDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  PairedDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairedDevice(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $PairedDevicesTable createAlias(String alias) {
    return $PairedDevicesTable(attachedDatabase, alias);
  }
}

class PairedDevice extends DataClass implements Insertable<PairedDevice> {
  final String deviceId;
  final String name;
  final String platform;
  final String? publicKey;
  final String userId;
  final DateTime pairedAt;
  final DateTime? lastSyncAt;
  final DateTime? revokedAt;
  const PairedDevice({
    required this.deviceId,
    required this.name,
    required this.platform,
    this.publicKey,
    required this.userId,
    required this.pairedAt,
    this.lastSyncAt,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    map['user_id'] = Variable<String>(userId);
    map['paired_at'] = Variable<DateTime>(pairedAt);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    return map;
  }

  PairedDevicesCompanion toCompanion(bool nullToAbsent) {
    return PairedDevicesCompanion(
      deviceId: Value(deviceId),
      name: Value(name),
      platform: Value(platform),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      userId: Value(userId),
      pairedAt: Value(pairedAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory PairedDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairedDevice(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      userId: serializer.fromJson<String>(json['userId']),
      pairedAt: serializer.fromJson<DateTime>(json['pairedAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'publicKey': serializer.toJson<String?>(publicKey),
      'userId': serializer.toJson<String>(userId),
      'pairedAt': serializer.toJson<DateTime>(pairedAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
    };
  }

  PairedDevice copyWith({
    String? deviceId,
    String? name,
    String? platform,
    Value<String?> publicKey = const Value.absent(),
    String? userId,
    DateTime? pairedAt,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<DateTime?> revokedAt = const Value.absent(),
  }) => PairedDevice(
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    userId: userId ?? this.userId,
    pairedAt: pairedAt ?? this.pairedAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  PairedDevice copyWithCompanion(PairedDevicesCompanion data) {
    return PairedDevice(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevice(')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('publicKey: $publicKey, ')
          ..write('userId: $userId, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    name,
    platform,
    publicKey,
    userId,
    pairedAt,
    lastSyncAt,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairedDevice &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.publicKey == this.publicKey &&
          other.userId == this.userId &&
          other.pairedAt == this.pairedAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.revokedAt == this.revokedAt);
}

class PairedDevicesCompanion extends UpdateCompanion<PairedDevice> {
  final Value<String> deviceId;
  final Value<String> name;
  final Value<String> platform;
  final Value<String?> publicKey;
  final Value<String> userId;
  final Value<DateTime> pairedAt;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime?> revokedAt;
  final Value<int> rowid;
  const PairedDevicesCompanion({
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairedDevicesCompanion.insert({
    required String deviceId,
    required String name,
    required String platform,
    this.publicKey = const Value.absent(),
    required String userId,
    required DateTime pairedAt,
    this.lastSyncAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       name = Value(name),
       platform = Value(platform),
       userId = Value(userId),
       pairedAt = Value(pairedAt);
  static Insertable<PairedDevice> custom({
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? publicKey,
    Expression<String>? userId,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? revokedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (publicKey != null) 'public_key': publicKey,
      if (userId != null) 'user_id': userId,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairedDevicesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? name,
    Value<String>? platform,
    Value<String?>? publicKey,
    Value<String>? userId,
    Value<DateTime>? pairedAt,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime?>? revokedAt,
    Value<int>? rowid,
  }) {
    return PairedDevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      publicKey: publicKey ?? this.publicKey,
      userId: userId ?? this.userId,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      revokedAt: revokedAt ?? this.revokedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('publicKey: $publicKey, ')
          ..write('userId: $userId, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEncryptedMeta = const VerificationMeta(
    'isEncrypted',
  );
  @override
  late final GeneratedColumn<bool> isEncrypted = GeneratedColumn<bool>(
    'is_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keyVersionMeta = const VerificationMeta(
    'keyVersion',
  );
  @override
  late final GeneratedColumn<int> keyVersion = GeneratedColumn<int>(
    'key_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    workspaceId,
    type,
    ownerId,
    name,
    isEncrypted,
    keyVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_encrypted')) {
      context.handle(
        _isEncryptedMeta,
        isEncrypted.isAcceptableOrUnknown(
          data['is_encrypted']!,
          _isEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('key_version')) {
      context.handle(
        _keyVersionMeta,
        keyVersion.isAcceptableOrUnknown(data['key_version']!, _keyVersionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_encrypted'],
      )!,
      keyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_version'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String workspaceId;
  final String type;
  final String ownerId;
  final String name;
  final bool isEncrypted;
  final int keyVersion;
  const Workspace({
    required this.workspaceId,
    required this.type,
    required this.ownerId,
    required this.name,
    required this.isEncrypted,
    required this.keyVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['type'] = Variable<String>(type);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['is_encrypted'] = Variable<bool>(isEncrypted);
    map['key_version'] = Variable<int>(keyVersion);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      workspaceId: Value(workspaceId),
      type: Value(type),
      ownerId: Value(ownerId),
      name: Value(name),
      isEncrypted: Value(isEncrypted),
      keyVersion: Value(keyVersion),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      type: serializer.fromJson<String>(json['type']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      isEncrypted: serializer.fromJson<bool>(json['isEncrypted']),
      keyVersion: serializer.fromJson<int>(json['keyVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'type': serializer.toJson<String>(type),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'isEncrypted': serializer.toJson<bool>(isEncrypted),
      'keyVersion': serializer.toJson<int>(keyVersion),
    };
  }

  Workspace copyWith({
    String? workspaceId,
    String? type,
    String? ownerId,
    String? name,
    bool? isEncrypted,
    int? keyVersion,
  }) => Workspace(
    workspaceId: workspaceId ?? this.workspaceId,
    type: type ?? this.type,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    isEncrypted: isEncrypted ?? this.isEncrypted,
    keyVersion: keyVersion ?? this.keyVersion,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      type: data.type.present ? data.type.value : this.type,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      isEncrypted: data.isEncrypted.present
          ? data.isEncrypted.value
          : this.isEncrypted,
      keyVersion: data.keyVersion.present
          ? data.keyVersion.value
          : this.keyVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('workspaceId: $workspaceId, ')
          ..write('type: $type, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('keyVersion: $keyVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(workspaceId, type, ownerId, name, isEncrypted, keyVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.workspaceId == this.workspaceId &&
          other.type == this.type &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.isEncrypted == this.isEncrypted &&
          other.keyVersion == this.keyVersion);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> workspaceId;
  final Value<String> type;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<bool> isEncrypted;
  final Value<int> keyVersion;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.workspaceId = const Value.absent(),
    this.type = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.keyVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String workspaceId,
    required String type,
    required String ownerId,
    required String name,
    this.isEncrypted = const Value.absent(),
    this.keyVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       type = Value(type),
       ownerId = Value(ownerId),
       name = Value(name);
  static Insertable<Workspace> custom({
    Expression<String>? workspaceId,
    Expression<String>? type,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<bool>? isEncrypted,
    Expression<int>? keyVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (type != null) 'type': type,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (isEncrypted != null) 'is_encrypted': isEncrypted,
      if (keyVersion != null) 'key_version': keyVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? workspaceId,
    Value<String>? type,
    Value<String>? ownerId,
    Value<String>? name,
    Value<bool>? isEncrypted,
    Value<int>? keyVersion,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      keyVersion: keyVersion ?? this.keyVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isEncrypted.present) {
      map['is_encrypted'] = Variable<bool>(isEncrypted.value);
    }
    if (keyVersion.present) {
      map['key_version'] = Variable<int>(keyVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('type: $type, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('keyVersion: $keyVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserNotePreferencesTable extends UserNotePreferences
    with TableInfo<$UserNotePreferencesTable, UserNotePreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserNotePreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinOrderMeta = const VerificationMeta(
    'pinOrder',
  );
  @override
  late final GeneratedColumn<String> pinOrder = GeneratedColumn<String>(
    'pin_order',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorCodeMeta = const VerificationMeta(
    'colorCode',
  );
  @override
  late final GeneratedColumn<String> colorCode = GeneratedColumn<String>(
    'color_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewModeMeta = const VerificationMeta(
    'viewMode',
  );
  @override
  late final GeneratedColumn<String> viewMode = GeneratedColumn<String>(
    'view_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    noteId,
    isPinned,
    pinOrder,
    colorCode,
    viewMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_note_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserNotePreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('pin_order')) {
      context.handle(
        _pinOrderMeta,
        pinOrder.isAcceptableOrUnknown(data['pin_order']!, _pinOrderMeta),
      );
    }
    if (data.containsKey('color_code')) {
      context.handle(
        _colorCodeMeta,
        colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta),
      );
    }
    if (data.containsKey('view_mode')) {
      context.handle(
        _viewModeMeta,
        viewMode.isAcceptableOrUnknown(data['view_mode']!, _viewModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, noteId};
  @override
  UserNotePreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserNotePreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      pinOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_order'],
      ),
      colorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_code'],
      ),
      viewMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_mode'],
      ),
    );
  }

  @override
  $UserNotePreferencesTable createAlias(String alias) {
    return $UserNotePreferencesTable(attachedDatabase, alias);
  }
}

class UserNotePreference extends DataClass
    implements Insertable<UserNotePreference> {
  final String userId;
  final String noteId;
  final bool isPinned;
  final String? pinOrder;
  final String? colorCode;
  final String? viewMode;
  const UserNotePreference({
    required this.userId,
    required this.noteId,
    required this.isPinned,
    this.pinOrder,
    this.colorCode,
    this.viewMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['note_id'] = Variable<String>(noteId);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || pinOrder != null) {
      map['pin_order'] = Variable<String>(pinOrder);
    }
    if (!nullToAbsent || colorCode != null) {
      map['color_code'] = Variable<String>(colorCode);
    }
    if (!nullToAbsent || viewMode != null) {
      map['view_mode'] = Variable<String>(viewMode);
    }
    return map;
  }

  UserNotePreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserNotePreferencesCompanion(
      userId: Value(userId),
      noteId: Value(noteId),
      isPinned: Value(isPinned),
      pinOrder: pinOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(pinOrder),
      colorCode: colorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(colorCode),
      viewMode: viewMode == null && nullToAbsent
          ? const Value.absent()
          : Value(viewMode),
    );
  }

  factory UserNotePreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserNotePreference(
      userId: serializer.fromJson<String>(json['userId']),
      noteId: serializer.fromJson<String>(json['noteId']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      pinOrder: serializer.fromJson<String?>(json['pinOrder']),
      colorCode: serializer.fromJson<String?>(json['colorCode']),
      viewMode: serializer.fromJson<String?>(json['viewMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'noteId': serializer.toJson<String>(noteId),
      'isPinned': serializer.toJson<bool>(isPinned),
      'pinOrder': serializer.toJson<String?>(pinOrder),
      'colorCode': serializer.toJson<String?>(colorCode),
      'viewMode': serializer.toJson<String?>(viewMode),
    };
  }

  UserNotePreference copyWith({
    String? userId,
    String? noteId,
    bool? isPinned,
    Value<String?> pinOrder = const Value.absent(),
    Value<String?> colorCode = const Value.absent(),
    Value<String?> viewMode = const Value.absent(),
  }) => UserNotePreference(
    userId: userId ?? this.userId,
    noteId: noteId ?? this.noteId,
    isPinned: isPinned ?? this.isPinned,
    pinOrder: pinOrder.present ? pinOrder.value : this.pinOrder,
    colorCode: colorCode.present ? colorCode.value : this.colorCode,
    viewMode: viewMode.present ? viewMode.value : this.viewMode,
  );
  UserNotePreference copyWithCompanion(UserNotePreferencesCompanion data) {
    return UserNotePreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      pinOrder: data.pinOrder.present ? data.pinOrder.value : this.pinOrder,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
      viewMode: data.viewMode.present ? data.viewMode.value : this.viewMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserNotePreference(')
          ..write('userId: $userId, ')
          ..write('noteId: $noteId, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder, ')
          ..write('colorCode: $colorCode, ')
          ..write('viewMode: $viewMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, noteId, isPinned, pinOrder, colorCode, viewMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserNotePreference &&
          other.userId == this.userId &&
          other.noteId == this.noteId &&
          other.isPinned == this.isPinned &&
          other.pinOrder == this.pinOrder &&
          other.colorCode == this.colorCode &&
          other.viewMode == this.viewMode);
}

class UserNotePreferencesCompanion extends UpdateCompanion<UserNotePreference> {
  final Value<String> userId;
  final Value<String> noteId;
  final Value<bool> isPinned;
  final Value<String?> pinOrder;
  final Value<String?> colorCode;
  final Value<String?> viewMode;
  final Value<int> rowid;
  const UserNotePreferencesCompanion({
    this.userId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserNotePreferencesCompanion.insert({
    required String userId,
    required String noteId,
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.viewMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       noteId = Value(noteId);
  static Insertable<UserNotePreference> custom({
    Expression<String>? userId,
    Expression<String>? noteId,
    Expression<bool>? isPinned,
    Expression<String>? pinOrder,
    Expression<String>? colorCode,
    Expression<String>? viewMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (noteId != null) 'note_id': noteId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (pinOrder != null) 'pin_order': pinOrder,
      if (colorCode != null) 'color_code': colorCode,
      if (viewMode != null) 'view_mode': viewMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserNotePreferencesCompanion copyWith({
    Value<String>? userId,
    Value<String>? noteId,
    Value<bool>? isPinned,
    Value<String?>? pinOrder,
    Value<String?>? colorCode,
    Value<String?>? viewMode,
    Value<int>? rowid,
  }) {
    return UserNotePreferencesCompanion(
      userId: userId ?? this.userId,
      noteId: noteId ?? this.noteId,
      isPinned: isPinned ?? this.isPinned,
      pinOrder: pinOrder ?? this.pinOrder,
      colorCode: colorCode ?? this.colorCode,
      viewMode: viewMode ?? this.viewMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (pinOrder.present) {
      map['pin_order'] = Variable<String>(pinOrder.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<String>(colorCode.value);
    }
    if (viewMode.present) {
      map['view_mode'] = Variable<String>(viewMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserNotePreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('noteId: $noteId, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder, ')
          ..write('colorCode: $colorCode, ')
          ..write('viewMode: $viewMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DeviceDatabase extends GeneratedDatabase {
  _$DeviceDatabase(QueryExecutor e) : super(e);
  $DeviceDatabaseManager get managers => $DeviceDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $PairedDevicesTable pairedDevices = $PairedDevicesTable(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $UserNotePreferencesTable userNotePreferences =
      $UserNotePreferencesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUsers,
    pairedDevices,
    workspaces,
    userNotePreferences,
    appSettings,
  ];
}

typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String userId,
      required String displayName,
      Value<String?> pinVerifier,
      Value<String?> pinSalt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> userId,
      Value<String> displayName,
      Value<String?> pinVerifier,
      Value<String?> pinSalt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$DeviceDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$DeviceDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$DeviceDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinVerifier => $composableBuilder(
    column: $table.pinVerifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$DeviceDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$DeviceDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$DeviceDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> pinVerifier = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                userId: userId,
                displayName: displayName,
                pinVerifier: pinVerifier,
                pinSalt: pinSalt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String displayName,
                Value<String?> pinVerifier = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                userId: userId,
                displayName: displayName,
                pinVerifier: pinVerifier,
                pinSalt: pinSalt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$DeviceDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (
        LocalUser,
        BaseReferences<_$DeviceDatabase, $LocalUsersTable, LocalUser>,
      ),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$PairedDevicesTableCreateCompanionBuilder =
    PairedDevicesCompanion Function({
      required String deviceId,
      required String name,
      required String platform,
      Value<String?> publicKey,
      required String userId,
      required DateTime pairedAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });
typedef $$PairedDevicesTableUpdateCompanionBuilder =
    PairedDevicesCompanion Function({
      Value<String> deviceId,
      Value<String> name,
      Value<String> platform,
      Value<String?> publicKey,
      Value<String> userId,
      Value<DateTime> pairedAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });

class $$PairedDevicesTableFilterComposer
    extends Composer<_$DeviceDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PairedDevicesTableOrderingComposer
    extends Composer<_$DeviceDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairedDevicesTableAnnotationComposer
    extends Composer<_$DeviceDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);
}

class $$PairedDevicesTableTableManager
    extends
        RootTableManager<
          _$DeviceDatabase,
          $PairedDevicesTable,
          PairedDevice,
          $$PairedDevicesTableFilterComposer,
          $$PairedDevicesTableOrderingComposer,
          $$PairedDevicesTableAnnotationComposer,
          $$PairedDevicesTableCreateCompanionBuilder,
          $$PairedDevicesTableUpdateCompanionBuilder,
          (
            PairedDevice,
            BaseReferences<_$DeviceDatabase, $PairedDevicesTable, PairedDevice>,
          ),
          PairedDevice,
          PrefetchHooks Function()
        > {
  $$PairedDevicesTableTableManager(
    _$DeviceDatabase db,
    $PairedDevicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairedDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairedDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairedDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> pairedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion(
                deviceId: deviceId,
                name: name,
                platform: platform,
                publicKey: publicKey,
                userId: userId,
                pairedAt: pairedAt,
                lastSyncAt: lastSyncAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String name,
                required String platform,
                Value<String?> publicKey = const Value.absent(),
                required String userId,
                required DateTime pairedAt,
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion.insert(
                deviceId: deviceId,
                name: name,
                platform: platform,
                publicKey: publicKey,
                userId: userId,
                pairedAt: pairedAt,
                lastSyncAt: lastSyncAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PairedDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$DeviceDatabase,
      $PairedDevicesTable,
      PairedDevice,
      $$PairedDevicesTableFilterComposer,
      $$PairedDevicesTableOrderingComposer,
      $$PairedDevicesTableAnnotationComposer,
      $$PairedDevicesTableCreateCompanionBuilder,
      $$PairedDevicesTableUpdateCompanionBuilder,
      (
        PairedDevice,
        BaseReferences<_$DeviceDatabase, $PairedDevicesTable, PairedDevice>,
      ),
      PairedDevice,
      PrefetchHooks Function()
    >;
typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String workspaceId,
      required String type,
      required String ownerId,
      required String name,
      Value<bool> isEncrypted,
      Value<int> keyVersion,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> workspaceId,
      Value<String> type,
      Value<String> ownerId,
      Value<String> name,
      Value<bool> isEncrypted,
      Value<int> keyVersion,
      Value<int> rowid,
    });

class $$WorkspacesTableFilterComposer
    extends Composer<_$DeviceDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$DeviceDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$DeviceDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyVersion => $composableBuilder(
    column: $table.keyVersion,
    builder: (column) => column,
  );
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$DeviceDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            Workspace,
            BaseReferences<_$DeviceDatabase, $WorkspacesTable, Workspace>,
          ),
          Workspace,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$DeviceDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isEncrypted = const Value.absent(),
                Value<int> keyVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                workspaceId: workspaceId,
                type: type,
                ownerId: ownerId,
                name: name,
                isEncrypted: isEncrypted,
                keyVersion: keyVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required String type,
                required String ownerId,
                required String name,
                Value<bool> isEncrypted = const Value.absent(),
                Value<int> keyVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                workspaceId: workspaceId,
                type: type,
                ownerId: ownerId,
                name: name,
                isEncrypted: isEncrypted,
                keyVersion: keyVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$DeviceDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (
        Workspace,
        BaseReferences<_$DeviceDatabase, $WorkspacesTable, Workspace>,
      ),
      Workspace,
      PrefetchHooks Function()
    >;
typedef $$UserNotePreferencesTableCreateCompanionBuilder =
    UserNotePreferencesCompanion Function({
      required String userId,
      required String noteId,
      Value<bool> isPinned,
      Value<String?> pinOrder,
      Value<String?> colorCode,
      Value<String?> viewMode,
      Value<int> rowid,
    });
typedef $$UserNotePreferencesTableUpdateCompanionBuilder =
    UserNotePreferencesCompanion Function({
      Value<String> userId,
      Value<String> noteId,
      Value<bool> isPinned,
      Value<String?> pinOrder,
      Value<String?> colorCode,
      Value<String?> viewMode,
      Value<int> rowid,
    });

class $$UserNotePreferencesTableFilterComposer
    extends Composer<_$DeviceDatabase, $UserNotePreferencesTable> {
  $$UserNotePreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserNotePreferencesTableOrderingComposer
    extends Composer<_$DeviceDatabase, $UserNotePreferencesTable> {
  $$UserNotePreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewMode => $composableBuilder(
    column: $table.viewMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserNotePreferencesTableAnnotationComposer
    extends Composer<_$DeviceDatabase, $UserNotePreferencesTable> {
  $$UserNotePreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get pinOrder =>
      $composableBuilder(column: $table.pinOrder, builder: (column) => column);

  GeneratedColumn<String> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  GeneratedColumn<String> get viewMode =>
      $composableBuilder(column: $table.viewMode, builder: (column) => column);
}

class $$UserNotePreferencesTableTableManager
    extends
        RootTableManager<
          _$DeviceDatabase,
          $UserNotePreferencesTable,
          UserNotePreference,
          $$UserNotePreferencesTableFilterComposer,
          $$UserNotePreferencesTableOrderingComposer,
          $$UserNotePreferencesTableAnnotationComposer,
          $$UserNotePreferencesTableCreateCompanionBuilder,
          $$UserNotePreferencesTableUpdateCompanionBuilder,
          (
            UserNotePreference,
            BaseReferences<
              _$DeviceDatabase,
              $UserNotePreferencesTable,
              UserNotePreference
            >,
          ),
          UserNotePreference,
          PrefetchHooks Function()
        > {
  $$UserNotePreferencesTableTableManager(
    _$DeviceDatabase db,
    $UserNotePreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserNotePreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserNotePreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserNotePreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<String?> pinOrder = const Value.absent(),
                Value<String?> colorCode = const Value.absent(),
                Value<String?> viewMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserNotePreferencesCompanion(
                userId: userId,
                noteId: noteId,
                isPinned: isPinned,
                pinOrder: pinOrder,
                colorCode: colorCode,
                viewMode: viewMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String noteId,
                Value<bool> isPinned = const Value.absent(),
                Value<String?> pinOrder = const Value.absent(),
                Value<String?> colorCode = const Value.absent(),
                Value<String?> viewMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserNotePreferencesCompanion.insert(
                userId: userId,
                noteId: noteId,
                isPinned: isPinned,
                pinOrder: pinOrder,
                colorCode: colorCode,
                viewMode: viewMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserNotePreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$DeviceDatabase,
      $UserNotePreferencesTable,
      UserNotePreference,
      $$UserNotePreferencesTableFilterComposer,
      $$UserNotePreferencesTableOrderingComposer,
      $$UserNotePreferencesTableAnnotationComposer,
      $$UserNotePreferencesTableCreateCompanionBuilder,
      $$UserNotePreferencesTableUpdateCompanionBuilder,
      (
        UserNotePreference,
        BaseReferences<
          _$DeviceDatabase,
          $UserNotePreferencesTable,
          UserNotePreference
        >,
      ),
      UserNotePreference,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$DeviceDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$DeviceDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$DeviceDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$DeviceDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$DeviceDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$DeviceDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$DeviceDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$DeviceDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $DeviceDatabaseManager {
  final _$DeviceDatabase _db;
  $DeviceDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$PairedDevicesTableTableManager get pairedDevices =>
      $$PairedDevicesTableTableManager(_db, _db.pairedDevices);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$UserNotePreferencesTableTableManager get userNotePreferences =>
      $$UserNotePreferencesTableTableManager(_db, _db.userNotePreferences);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
