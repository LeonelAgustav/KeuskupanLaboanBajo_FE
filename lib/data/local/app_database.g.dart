// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    email,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String nama;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const User({
    required this.id,
    required this.nama,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['email'] = Variable<String>(email);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      nama: Value(nama),
      email: Value(email),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      email: serializer.fromJson<String>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'email': serializer.toJson<String>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  User copyWith({
    String? id,
    String? nama,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => User(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, email, createdAt, updatedAt, deletedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.email == this.email &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> email;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String nama,
    required String email,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       email = Value(email);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? email,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
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
          ..write('nama: $nama, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeuskupansTable extends Keuskupans
    with TableInfo<$KeuskupansTable, Keuskupan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeuskupansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alamatMeta = const VerificationMeta('alamat');
  @override
  late final GeneratedColumn<String> alamat = GeneratedColumn<String>(
    'alamat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    alamat,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'keuskupans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Keuskupan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('alamat')) {
      context.handle(
        _alamatMeta,
        alamat.isAcceptableOrUnknown(data['alamat']!, _alamatMeta),
      );
    } else if (isInserting) {
      context.missing(_alamatMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Keuskupan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Keuskupan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      alamat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alamat'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $KeuskupansTable createAlias(String alias) {
    return $KeuskupansTable(attachedDatabase, alias);
  }
}

class Keuskupan extends DataClass implements Insertable<Keuskupan> {
  final String id;
  final String nama;
  final String alamat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const Keuskupan({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['alamat'] = Variable<String>(alamat);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  KeuskupansCompanion toCompanion(bool nullToAbsent) {
    return KeuskupansCompanion(
      id: Value(id),
      nama: Value(nama),
      alamat: Value(alamat),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Keuskupan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Keuskupan(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      alamat: serializer.fromJson<String>(json['alamat']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'alamat': serializer.toJson<String>(alamat),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Keuskupan copyWith({
    String? id,
    String? nama,
    String? alamat,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => Keuskupan(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    alamat: alamat ?? this.alamat,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Keuskupan copyWithCompanion(KeuskupansCompanion data) {
    return Keuskupan(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      alamat: data.alamat.present ? data.alamat.value : this.alamat,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Keuskupan(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('alamat: $alamat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, alamat, createdAt, updatedAt, deletedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Keuskupan &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.alamat == this.alamat &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class KeuskupansCompanion extends UpdateCompanion<Keuskupan> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> alamat;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const KeuskupansCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.alamat = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeuskupansCompanion.insert({
    required String id,
    required String nama,
    required String alamat,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       alamat = Value(alamat);
  static Insertable<Keuskupan> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? alamat,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (alamat != null) 'alamat': alamat,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeuskupansCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? alamat,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return KeuskupansCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (alamat.present) {
      map['alamat'] = Variable<String>(alamat.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeuskupansCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('alamat: $alamat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParokisTable extends Parokis with TableInfo<$ParokisTable, Paroki> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParokisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alamatMeta = const VerificationMeta('alamat');
  @override
  late final GeneratedColumn<String> alamat = GeneratedColumn<String>(
    'alamat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keuskupanIdMeta = const VerificationMeta(
    'keuskupanId',
  );
  @override
  late final GeneratedColumn<String> keuskupanId = GeneratedColumn<String>(
    'keuskupan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES keuskupans(id)',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    alamat,
    keuskupanId,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parokis';
  @override
  VerificationContext validateIntegrity(
    Insertable<Paroki> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('alamat')) {
      context.handle(
        _alamatMeta,
        alamat.isAcceptableOrUnknown(data['alamat']!, _alamatMeta),
      );
    } else if (isInserting) {
      context.missing(_alamatMeta);
    }
    if (data.containsKey('keuskupan_id')) {
      context.handle(
        _keuskupanIdMeta,
        keuskupanId.isAcceptableOrUnknown(
          data['keuskupan_id']!,
          _keuskupanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_keuskupanIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Paroki map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Paroki(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      alamat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alamat'],
      )!,
      keuskupanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keuskupan_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ParokisTable createAlias(String alias) {
    return $ParokisTable(attachedDatabase, alias);
  }
}

class Paroki extends DataClass implements Insertable<Paroki> {
  final String id;
  final String nama;
  final String alamat;
  final String keuskupanId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const Paroki({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.keuskupanId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['alamat'] = Variable<String>(alamat);
    map['keuskupan_id'] = Variable<String>(keuskupanId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ParokisCompanion toCompanion(bool nullToAbsent) {
    return ParokisCompanion(
      id: Value(id),
      nama: Value(nama),
      alamat: Value(alamat),
      keuskupanId: Value(keuskupanId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Paroki.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Paroki(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      alamat: serializer.fromJson<String>(json['alamat']),
      keuskupanId: serializer.fromJson<String>(json['keuskupanId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'alamat': serializer.toJson<String>(alamat),
      'keuskupanId': serializer.toJson<String>(keuskupanId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Paroki copyWith({
    String? id,
    String? nama,
    String? alamat,
    String? keuskupanId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => Paroki(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    alamat: alamat ?? this.alamat,
    keuskupanId: keuskupanId ?? this.keuskupanId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Paroki copyWithCompanion(ParokisCompanion data) {
    return Paroki(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      alamat: data.alamat.present ? data.alamat.value : this.alamat,
      keuskupanId: data.keuskupanId.present
          ? data.keuskupanId.value
          : this.keuskupanId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Paroki(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('alamat: $alamat, ')
          ..write('keuskupanId: $keuskupanId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nama,
    alamat,
    keuskupanId,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Paroki &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.alamat == this.alamat &&
          other.keuskupanId == this.keuskupanId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class ParokisCompanion extends UpdateCompanion<Paroki> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> alamat;
  final Value<String> keuskupanId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ParokisCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.alamat = const Value.absent(),
    this.keuskupanId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParokisCompanion.insert({
    required String id,
    required String nama,
    required String alamat,
    required String keuskupanId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       alamat = Value(alamat),
       keuskupanId = Value(keuskupanId);
  static Insertable<Paroki> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? alamat,
    Expression<String>? keuskupanId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (alamat != null) 'alamat': alamat,
      if (keuskupanId != null) 'keuskupan_id': keuskupanId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParokisCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? alamat,
    Value<String>? keuskupanId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ParokisCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      keuskupanId: keuskupanId ?? this.keuskupanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (alamat.present) {
      map['alamat'] = Variable<String>(alamat.value);
    }
    if (keuskupanId.present) {
      map['keuskupan_id'] = Variable<String>(keuskupanId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParokisCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('alamat: $alamat, ')
          ..write('keuskupanId: $keuskupanId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JenisTable extends Jenis with TableInfo<$JenisTable, Jeni> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JenisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nama,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jenis';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jeni> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jeni map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jeni(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $JenisTable createAlias(String alias) {
    return $JenisTable(attachedDatabase, alias);
  }
}

class Jeni extends DataClass implements Insertable<Jeni> {
  final String id;
  final String nama;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const Jeni({
    required this.id,
    required this.nama,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  JenisCompanion toCompanion(bool nullToAbsent) {
    return JenisCompanion(
      id: Value(id),
      nama: Value(nama),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Jeni.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jeni(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Jeni copyWith({
    String? id,
    String? nama,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => Jeni(
    id: id ?? this.id,
    nama: nama ?? this.nama,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Jeni copyWithCompanion(JenisCompanion data) {
    return Jeni(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jeni(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, createdAt, updatedAt, deletedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jeni &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class JenisCompanion extends UpdateCompanion<Jeni> {
  final Value<String> id;
  final Value<String> nama;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const JenisCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JenisCompanion.insert({
    required String id,
    required String nama,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama);
  static Insertable<Jeni> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JenisCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return JenisCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JenisCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AkunsTable extends Akuns with TableInfo<$AkunsTable, Akun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AkunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kodeMeta = const VerificationMeta('kode');
  @override
  late final GeneratedColumn<String> kode = GeneratedColumn<String>(
    'kode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jenisIdMeta = const VerificationMeta(
    'jenisId',
  );
  @override
  late final GeneratedColumn<String> jenisId = GeneratedColumn<String>(
    'jenis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES jenis(id)',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kode,
    nama,
    jenisId,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'akuns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Akun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kode')) {
      context.handle(
        _kodeMeta,
        kode.isAcceptableOrUnknown(data['kode']!, _kodeMeta),
      );
    } else if (isInserting) {
      context.missing(_kodeMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('jenis_id')) {
      context.handle(
        _jenisIdMeta,
        jenisId.isAcceptableOrUnknown(data['jenis_id']!, _jenisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jenisIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Akun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Akun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kode'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      jenisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $AkunsTable createAlias(String alias) {
    return $AkunsTable(attachedDatabase, alias);
  }
}

class Akun extends DataClass implements Insertable<Akun> {
  final String id;
  final String kode;
  final String nama;
  final String jenisId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const Akun({
    required this.id,
    required this.kode,
    required this.nama,
    required this.jenisId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kode'] = Variable<String>(kode);
    map['nama'] = Variable<String>(nama);
    map['jenis_id'] = Variable<String>(jenisId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  AkunsCompanion toCompanion(bool nullToAbsent) {
    return AkunsCompanion(
      id: Value(id),
      kode: Value(kode),
      nama: Value(nama),
      jenisId: Value(jenisId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Akun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Akun(
      id: serializer.fromJson<String>(json['id']),
      kode: serializer.fromJson<String>(json['kode']),
      nama: serializer.fromJson<String>(json['nama']),
      jenisId: serializer.fromJson<String>(json['jenisId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kode': serializer.toJson<String>(kode),
      'nama': serializer.toJson<String>(nama),
      'jenisId': serializer.toJson<String>(jenisId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Akun copyWith({
    String? id,
    String? kode,
    String? nama,
    String? jenisId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => Akun(
    id: id ?? this.id,
    kode: kode ?? this.kode,
    nama: nama ?? this.nama,
    jenisId: jenisId ?? this.jenisId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Akun copyWithCompanion(AkunsCompanion data) {
    return Akun(
      id: data.id.present ? data.id.value : this.id,
      kode: data.kode.present ? data.kode.value : this.kode,
      nama: data.nama.present ? data.nama.value : this.nama,
      jenisId: data.jenisId.present ? data.jenisId.value : this.jenisId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Akun(')
          ..write('id: $id, ')
          ..write('kode: $kode, ')
          ..write('nama: $nama, ')
          ..write('jenisId: $jenisId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kode,
    nama,
    jenisId,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Akun &&
          other.id == this.id &&
          other.kode == this.kode &&
          other.nama == this.nama &&
          other.jenisId == this.jenisId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class AkunsCompanion extends UpdateCompanion<Akun> {
  final Value<String> id;
  final Value<String> kode;
  final Value<String> nama;
  final Value<String> jenisId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const AkunsCompanion({
    this.id = const Value.absent(),
    this.kode = const Value.absent(),
    this.nama = const Value.absent(),
    this.jenisId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AkunsCompanion.insert({
    required String id,
    required String kode,
    required String nama,
    required String jenisId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kode = Value(kode),
       nama = Value(nama),
       jenisId = Value(jenisId);
  static Insertable<Akun> custom({
    Expression<String>? id,
    Expression<String>? kode,
    Expression<String>? nama,
    Expression<String>? jenisId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kode != null) 'kode': kode,
      if (nama != null) 'nama': nama,
      if (jenisId != null) 'jenis_id': jenisId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AkunsCompanion copyWith({
    Value<String>? id,
    Value<String>? kode,
    Value<String>? nama,
    Value<String>? jenisId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return AkunsCompanion(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      jenisId: jenisId ?? this.jenisId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kode.present) {
      map['kode'] = Variable<String>(kode.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (jenisId.present) {
      map['jenis_id'] = Variable<String>(jenisId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AkunsCompanion(')
          ..write('id: $id, ')
          ..write('kode: $kode, ')
          ..write('nama: $nama, ')
          ..write('jenisId: $jenisId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JurnalsTable extends Jurnals with TableInfo<$JurnalsTable, Jurnal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JurnalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keuskupanIdMeta = const VerificationMeta(
    'keuskupanId',
  );
  @override
  late final GeneratedColumn<String> keuskupanId = GeneratedColumn<String>(
    'keuskupan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES keuskupans(id)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> tanggal =
      GeneratedColumn<String>(
        'tanggal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($JurnalsTable.$convertertanggal);
  static const VerificationMeta _deskripsiMeta = const VerificationMeta(
    'deskripsi',
  );
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
    'deskripsi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noBuktiMeta = const VerificationMeta(
    'noBukti',
  );
  @override
  late final GeneratedColumn<String> noBukti = GeneratedColumn<String>(
    'no_bukti',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    keuskupanId,
    tanggal,
    deskripsi,
    noBukti,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jurnals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jurnal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('keuskupan_id')) {
      context.handle(
        _keuskupanIdMeta,
        keuskupanId.isAcceptableOrUnknown(
          data['keuskupan_id']!,
          _keuskupanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_keuskupanIdMeta);
    }
    if (data.containsKey('deskripsi')) {
      context.handle(
        _deskripsiMeta,
        deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta),
      );
    }
    if (data.containsKey('no_bukti')) {
      context.handle(
        _noBuktiMeta,
        noBukti.isAcceptableOrUnknown(data['no_bukti']!, _noBuktiMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jurnal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jurnal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      keuskupanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keuskupan_id'],
      )!,
      tanggal: $JurnalsTable.$convertertanggal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tanggal'],
        )!,
      ),
      deskripsi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deskripsi'],
      ),
      noBukti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no_bukti'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $JurnalsTable createAlias(String alias) {
    return $JurnalsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertertanggal =
      const DateToStringConverter();
}

class Jurnal extends DataClass implements Insertable<Jurnal> {
  final String id;
  final String keuskupanId;
  final DateTime tanggal;
  final String? deskripsi;
  final String? noBukti;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const Jurnal({
    required this.id,
    required this.keuskupanId,
    required this.tanggal,
    this.deskripsi,
    this.noBukti,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['keuskupan_id'] = Variable<String>(keuskupanId);
    {
      map['tanggal'] = Variable<String>(
        $JurnalsTable.$convertertanggal.toSql(tanggal),
      );
    }
    if (!nullToAbsent || deskripsi != null) {
      map['deskripsi'] = Variable<String>(deskripsi);
    }
    if (!nullToAbsent || noBukti != null) {
      map['no_bukti'] = Variable<String>(noBukti);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  JurnalsCompanion toCompanion(bool nullToAbsent) {
    return JurnalsCompanion(
      id: Value(id),
      keuskupanId: Value(keuskupanId),
      tanggal: Value(tanggal),
      deskripsi: deskripsi == null && nullToAbsent
          ? const Value.absent()
          : Value(deskripsi),
      noBukti: noBukti == null && nullToAbsent
          ? const Value.absent()
          : Value(noBukti),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Jurnal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jurnal(
      id: serializer.fromJson<String>(json['id']),
      keuskupanId: serializer.fromJson<String>(json['keuskupanId']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      deskripsi: serializer.fromJson<String?>(json['deskripsi']),
      noBukti: serializer.fromJson<String?>(json['noBukti']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'keuskupanId': serializer.toJson<String>(keuskupanId),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'deskripsi': serializer.toJson<String?>(deskripsi),
      'noBukti': serializer.toJson<String?>(noBukti),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Jurnal copyWith({
    String? id,
    String? keuskupanId,
    DateTime? tanggal,
    Value<String?> deskripsi = const Value.absent(),
    Value<String?> noBukti = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => Jurnal(
    id: id ?? this.id,
    keuskupanId: keuskupanId ?? this.keuskupanId,
    tanggal: tanggal ?? this.tanggal,
    deskripsi: deskripsi.present ? deskripsi.value : this.deskripsi,
    noBukti: noBukti.present ? noBukti.value : this.noBukti,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Jurnal copyWithCompanion(JurnalsCompanion data) {
    return Jurnal(
      id: data.id.present ? data.id.value : this.id,
      keuskupanId: data.keuskupanId.present
          ? data.keuskupanId.value
          : this.keuskupanId,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      noBukti: data.noBukti.present ? data.noBukti.value : this.noBukti,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jurnal(')
          ..write('id: $id, ')
          ..write('keuskupanId: $keuskupanId, ')
          ..write('tanggal: $tanggal, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('noBukti: $noBukti, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    keuskupanId,
    tanggal,
    deskripsi,
    noBukti,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jurnal &&
          other.id == this.id &&
          other.keuskupanId == this.keuskupanId &&
          other.tanggal == this.tanggal &&
          other.deskripsi == this.deskripsi &&
          other.noBukti == this.noBukti &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class JurnalsCompanion extends UpdateCompanion<Jurnal> {
  final Value<String> id;
  final Value<String> keuskupanId;
  final Value<DateTime> tanggal;
  final Value<String?> deskripsi;
  final Value<String?> noBukti;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const JurnalsCompanion({
    this.id = const Value.absent(),
    this.keuskupanId = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.noBukti = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JurnalsCompanion.insert({
    required String id,
    required String keuskupanId,
    required DateTime tanggal,
    this.deskripsi = const Value.absent(),
    this.noBukti = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       keuskupanId = Value(keuskupanId),
       tanggal = Value(tanggal);
  static Insertable<Jurnal> custom({
    Expression<String>? id,
    Expression<String>? keuskupanId,
    Expression<String>? tanggal,
    Expression<String>? deskripsi,
    Expression<String>? noBukti,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keuskupanId != null) 'keuskupan_id': keuskupanId,
      if (tanggal != null) 'tanggal': tanggal,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (noBukti != null) 'no_bukti': noBukti,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JurnalsCompanion copyWith({
    Value<String>? id,
    Value<String>? keuskupanId,
    Value<DateTime>? tanggal,
    Value<String?>? deskripsi,
    Value<String?>? noBukti,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return JurnalsCompanion(
      id: id ?? this.id,
      keuskupanId: keuskupanId ?? this.keuskupanId,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      noBukti: noBukti ?? this.noBukti,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (keuskupanId.present) {
      map['keuskupan_id'] = Variable<String>(keuskupanId.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<String>(
        $JurnalsTable.$convertertanggal.toSql(tanggal.value),
      );
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (noBukti.present) {
      map['no_bukti'] = Variable<String>(noBukti.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JurnalsCompanion(')
          ..write('id: $id, ')
          ..write('keuskupanId: $keuskupanId, ')
          ..write('tanggal: $tanggal, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('noBukti: $noBukti, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetilJurnalsTable extends DetilJurnals
    with TableInfo<$DetilJurnalsTable, DetilJurnal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetilJurnalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jurnalIdMeta = const VerificationMeta(
    'jurnalId',
  );
  @override
  late final GeneratedColumn<String> jurnalId = GeneratedColumn<String>(
    'jurnal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES jurnals(id)',
  );
  static const VerificationMeta _akunIdMeta = const VerificationMeta('akunId');
  @override
  late final GeneratedColumn<String> akunId = GeneratedColumn<String>(
    'akun_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES akuns(id)',
  );
  static const VerificationMeta _parokiIdMeta = const VerificationMeta(
    'parokiId',
  );
  @override
  late final GeneratedColumn<String> parokiId = GeneratedColumn<String>(
    'paroki_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES parokis(id)',
  );
  static const VerificationMeta _debitMeta = const VerificationMeta('debit');
  @override
  late final GeneratedColumn<double> debit = GeneratedColumn<double>(
    'debit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kreditMeta = const VerificationMeta('kredit');
  @override
  late final GeneratedColumn<double> kredit = GeneratedColumn<double>(
    'kredit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _keteranganMeta = const VerificationMeta(
    'keterangan',
  );
  @override
  late final GeneratedColumn<String> keterangan = GeneratedColumn<String>(
    'keterangan',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurnalId,
    akunId,
    parokiId,
    debit,
    kredit,
    keterangan,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detil_jurnals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetilJurnal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('jurnal_id')) {
      context.handle(
        _jurnalIdMeta,
        jurnalId.isAcceptableOrUnknown(data['jurnal_id']!, _jurnalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurnalIdMeta);
    }
    if (data.containsKey('akun_id')) {
      context.handle(
        _akunIdMeta,
        akunId.isAcceptableOrUnknown(data['akun_id']!, _akunIdMeta),
      );
    } else if (isInserting) {
      context.missing(_akunIdMeta);
    }
    if (data.containsKey('paroki_id')) {
      context.handle(
        _parokiIdMeta,
        parokiId.isAcceptableOrUnknown(data['paroki_id']!, _parokiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parokiIdMeta);
    }
    if (data.containsKey('debit')) {
      context.handle(
        _debitMeta,
        debit.isAcceptableOrUnknown(data['debit']!, _debitMeta),
      );
    }
    if (data.containsKey('kredit')) {
      context.handle(
        _kreditMeta,
        kredit.isAcceptableOrUnknown(data['kredit']!, _kreditMeta),
      );
    }
    if (data.containsKey('keterangan')) {
      context.handle(
        _keteranganMeta,
        keterangan.isAcceptableOrUnknown(data['keterangan']!, _keteranganMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetilJurnal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetilJurnal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jurnalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurnal_id'],
      )!,
      akunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}akun_id'],
      )!,
      parokiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paroki_id'],
      )!,
      debit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debit'],
      ),
      kredit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kredit'],
      ),
      keterangan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keterangan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $DetilJurnalsTable createAlias(String alias) {
    return $DetilJurnalsTable(attachedDatabase, alias);
  }
}

class DetilJurnal extends DataClass implements Insertable<DetilJurnal> {
  final String id;
  final String jurnalId;
  final String akunId;
  final String parokiId;
  final double? debit;
  final double? kredit;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;
  const DetilJurnal({
    required this.id,
    required this.jurnalId,
    required this.akunId,
    required this.parokiId,
    this.debit,
    this.kredit,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['jurnal_id'] = Variable<String>(jurnalId);
    map['akun_id'] = Variable<String>(akunId);
    map['paroki_id'] = Variable<String>(parokiId);
    if (!nullToAbsent || debit != null) {
      map['debit'] = Variable<double>(debit);
    }
    if (!nullToAbsent || kredit != null) {
      map['kredit'] = Variable<double>(kredit);
    }
    if (!nullToAbsent || keterangan != null) {
      map['keterangan'] = Variable<String>(keterangan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  DetilJurnalsCompanion toCompanion(bool nullToAbsent) {
    return DetilJurnalsCompanion(
      id: Value(id),
      jurnalId: Value(jurnalId),
      akunId: Value(akunId),
      parokiId: Value(parokiId),
      debit: debit == null && nullToAbsent
          ? const Value.absent()
          : Value(debit),
      kredit: kredit == null && nullToAbsent
          ? const Value.absent()
          : Value(kredit),
      keterangan: keterangan == null && nullToAbsent
          ? const Value.absent()
          : Value(keterangan),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }

  factory DetilJurnal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetilJurnal(
      id: serializer.fromJson<String>(json['id']),
      jurnalId: serializer.fromJson<String>(json['jurnalId']),
      akunId: serializer.fromJson<String>(json['akunId']),
      parokiId: serializer.fromJson<String>(json['parokiId']),
      debit: serializer.fromJson<double?>(json['debit']),
      kredit: serializer.fromJson<double?>(json['kredit']),
      keterangan: serializer.fromJson<String?>(json['keterangan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jurnalId': serializer.toJson<String>(jurnalId),
      'akunId': serializer.toJson<String>(akunId),
      'parokiId': serializer.toJson<String>(parokiId),
      'debit': serializer.toJson<double?>(debit),
      'kredit': serializer.toJson<double?>(kredit),
      'keterangan': serializer.toJson<String?>(keterangan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  DetilJurnal copyWith({
    String? id,
    String? jurnalId,
    String? akunId,
    String? parokiId,
    Value<double?> debit = const Value.absent(),
    Value<double?> kredit = const Value.absent(),
    Value<String?> keterangan = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSynced,
  }) => DetilJurnal(
    id: id ?? this.id,
    jurnalId: jurnalId ?? this.jurnalId,
    akunId: akunId ?? this.akunId,
    parokiId: parokiId ?? this.parokiId,
    debit: debit.present ? debit.value : this.debit,
    kredit: kredit.present ? kredit.value : this.kredit,
    keterangan: keterangan.present ? keterangan.value : this.keterangan,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  DetilJurnal copyWithCompanion(DetilJurnalsCompanion data) {
    return DetilJurnal(
      id: data.id.present ? data.id.value : this.id,
      jurnalId: data.jurnalId.present ? data.jurnalId.value : this.jurnalId,
      akunId: data.akunId.present ? data.akunId.value : this.akunId,
      parokiId: data.parokiId.present ? data.parokiId.value : this.parokiId,
      debit: data.debit.present ? data.debit.value : this.debit,
      kredit: data.kredit.present ? data.kredit.value : this.kredit,
      keterangan: data.keterangan.present
          ? data.keterangan.value
          : this.keterangan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetilJurnal(')
          ..write('id: $id, ')
          ..write('jurnalId: $jurnalId, ')
          ..write('akunId: $akunId, ')
          ..write('parokiId: $parokiId, ')
          ..write('debit: $debit, ')
          ..write('kredit: $kredit, ')
          ..write('keterangan: $keterangan, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurnalId,
    akunId,
    parokiId,
    debit,
    kredit,
    keterangan,
    createdAt,
    updatedAt,
    deletedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetilJurnal &&
          other.id == this.id &&
          other.jurnalId == this.jurnalId &&
          other.akunId == this.akunId &&
          other.parokiId == this.parokiId &&
          other.debit == this.debit &&
          other.kredit == this.kredit &&
          other.keterangan == this.keterangan &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isSynced == this.isSynced);
}

class DetilJurnalsCompanion extends UpdateCompanion<DetilJurnal> {
  final Value<String> id;
  final Value<String> jurnalId;
  final Value<String> akunId;
  final Value<String> parokiId;
  final Value<double?> debit;
  final Value<double?> kredit;
  final Value<String?> keterangan;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const DetilJurnalsCompanion({
    this.id = const Value.absent(),
    this.jurnalId = const Value.absent(),
    this.akunId = const Value.absent(),
    this.parokiId = const Value.absent(),
    this.debit = const Value.absent(),
    this.kredit = const Value.absent(),
    this.keterangan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetilJurnalsCompanion.insert({
    required String id,
    required String jurnalId,
    required String akunId,
    required String parokiId,
    this.debit = const Value.absent(),
    this.kredit = const Value.absent(),
    this.keterangan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jurnalId = Value(jurnalId),
       akunId = Value(akunId),
       parokiId = Value(parokiId);
  static Insertable<DetilJurnal> custom({
    Expression<String>? id,
    Expression<String>? jurnalId,
    Expression<String>? akunId,
    Expression<String>? parokiId,
    Expression<double>? debit,
    Expression<double>? kredit,
    Expression<String>? keterangan,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurnalId != null) 'jurnal_id': jurnalId,
      if (akunId != null) 'akun_id': akunId,
      if (parokiId != null) 'paroki_id': parokiId,
      if (debit != null) 'debit': debit,
      if (kredit != null) 'kredit': kredit,
      if (keterangan != null) 'keterangan': keterangan,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetilJurnalsCompanion copyWith({
    Value<String>? id,
    Value<String>? jurnalId,
    Value<String>? akunId,
    Value<String>? parokiId,
    Value<double?>? debit,
    Value<double?>? kredit,
    Value<String?>? keterangan,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return DetilJurnalsCompanion(
      id: id ?? this.id,
      jurnalId: jurnalId ?? this.jurnalId,
      akunId: akunId ?? this.akunId,
      parokiId: parokiId ?? this.parokiId,
      debit: debit ?? this.debit,
      kredit: kredit ?? this.kredit,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jurnalId.present) {
      map['jurnal_id'] = Variable<String>(jurnalId.value);
    }
    if (akunId.present) {
      map['akun_id'] = Variable<String>(akunId.value);
    }
    if (parokiId.present) {
      map['paroki_id'] = Variable<String>(parokiId.value);
    }
    if (debit.present) {
      map['debit'] = Variable<double>(debit.value);
    }
    if (kredit.present) {
      map['kredit'] = Variable<double>(kredit.value);
    }
    if (keterangan.present) {
      map['keterangan'] = Variable<String>(keterangan.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetilJurnalsCompanion(')
          ..write('id: $id, ')
          ..write('jurnalId: $jurnalId, ')
          ..write('akunId: $akunId, ')
          ..write('parokiId: $parokiId, ')
          ..write('debit: $debit, ')
          ..write('kredit: $kredit, ')
          ..write('keterangan: $keterangan, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    rowId,
    operation,
    payload,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final int id;
  final String targetTable;
  final String rowId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  const SyncQueue({
    required this.id,
    required this.targetTable,
    required this.rowId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['row_id'] = Variable<String>(rowId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      rowId: Value(rowId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory SyncQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'rowId': serializer.toJson<String>(rowId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncQueue copyWith({
    int? id,
    String? targetTable,
    String? rowId,
    String? operation,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  }) => SyncQueue(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    rowId: rowId ?? this.rowId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    rowId,
    operation,
    payload,
    createdAt,
    retryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.rowId == this.rowId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<String> rowId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    required String rowId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  }) : targetTable = Value(targetTable),
       rowId = Value(rowId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueue> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<String>? rowId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (rowId != null) 'row_id': rowId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  SyncQueuesCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<String>? rowId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      rowId: rowId ?? this.rowId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $KeuskupansTable keuskupans = $KeuskupansTable(this);
  late final $ParokisTable parokis = $ParokisTable(this);
  late final $JenisTable jenis = $JenisTable(this);
  late final $AkunsTable akuns = $AkunsTable(this);
  late final $JurnalsTable jurnals = $JurnalsTable(this);
  late final $DetilJurnalsTable detilJurnals = $DetilJurnalsTable(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    keuskupans,
    parokis,
    jenis,
    akuns,
    jurnals,
    detilJurnals,
    syncQueues,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String nama,
      required String email,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> email,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                nama: nama,
                email: email,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String email,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                nama: nama,
                email: email,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$KeuskupansTableCreateCompanionBuilder =
    KeuskupansCompanion Function({
      required String id,
      required String nama,
      required String alamat,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$KeuskupansTableUpdateCompanionBuilder =
    KeuskupansCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> alamat,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$KeuskupansTableReferences
    extends BaseReferences<_$AppDatabase, $KeuskupansTable, Keuskupan> {
  $$KeuskupansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ParokisTable, List<Paroki>> _parokisRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.parokis,
    aliasName: 'keuskupans__id__parokis__keuskupan_id',
  );

  $$ParokisTableProcessedTableManager get parokisRefs {
    final manager = $$ParokisTableTableManager(
      $_db,
      $_db.parokis,
    ).filter((f) => f.keuskupanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_parokisRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JurnalsTable, List<Jurnal>> _jurnalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jurnals,
    aliasName: 'keuskupans__id__jurnals__keuskupan_id',
  );

  $$JurnalsTableProcessedTableManager get jurnalsRefs {
    final manager = $$JurnalsTableTableManager(
      $_db,
      $_db.jurnals,
    ).filter((f) => f.keuskupanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jurnalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$KeuskupansTableFilterComposer
    extends Composer<_$AppDatabase, $KeuskupansTable> {
  $$KeuskupansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> parokisRefs(
    Expression<bool> Function($$ParokisTableFilterComposer f) f,
  ) {
    final $$ParokisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parokis,
      getReferencedColumn: (t) => t.keuskupanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParokisTableFilterComposer(
            $db: $db,
            $table: $db.parokis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jurnalsRefs(
    Expression<bool> Function($$JurnalsTableFilterComposer f) f,
  ) {
    final $$JurnalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jurnals,
      getReferencedColumn: (t) => t.keuskupanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JurnalsTableFilterComposer(
            $db: $db,
            $table: $db.jurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KeuskupansTableOrderingComposer
    extends Composer<_$AppDatabase, $KeuskupansTable> {
  $$KeuskupansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeuskupansTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeuskupansTable> {
  $$KeuskupansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get alamat =>
      $composableBuilder(column: $table.alamat, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> parokisRefs<T extends Object>(
    Expression<T> Function($$ParokisTableAnnotationComposer a) f,
  ) {
    final $$ParokisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parokis,
      getReferencedColumn: (t) => t.keuskupanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParokisTableAnnotationComposer(
            $db: $db,
            $table: $db.parokis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jurnalsRefs<T extends Object>(
    Expression<T> Function($$JurnalsTableAnnotationComposer a) f,
  ) {
    final $$JurnalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jurnals,
      getReferencedColumn: (t) => t.keuskupanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JurnalsTableAnnotationComposer(
            $db: $db,
            $table: $db.jurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KeuskupansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeuskupansTable,
          Keuskupan,
          $$KeuskupansTableFilterComposer,
          $$KeuskupansTableOrderingComposer,
          $$KeuskupansTableAnnotationComposer,
          $$KeuskupansTableCreateCompanionBuilder,
          $$KeuskupansTableUpdateCompanionBuilder,
          (Keuskupan, $$KeuskupansTableReferences),
          Keuskupan,
          PrefetchHooks Function({bool parokisRefs, bool jurnalsRefs})
        > {
  $$KeuskupansTableTableManager(_$AppDatabase db, $KeuskupansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeuskupansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeuskupansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeuskupansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> alamat = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeuskupansCompanion(
                id: id,
                nama: nama,
                alamat: alamat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String alamat,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeuskupansCompanion.insert(
                id: id,
                nama: nama,
                alamat: alamat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$KeuskupansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parokisRefs = false, jurnalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (parokisRefs) db.parokis,
                if (jurnalsRefs) db.jurnals,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (parokisRefs)
                    await $_getPrefetchedData<
                      Keuskupan,
                      $KeuskupansTable,
                      Paroki
                    >(
                      currentTable: table,
                      referencedTable: $$KeuskupansTableReferences
                          ._parokisRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$KeuskupansTableReferences(
                            db,
                            table,
                            p0,
                          ).parokisRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.keuskupanId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (jurnalsRefs)
                    await $_getPrefetchedData<
                      Keuskupan,
                      $KeuskupansTable,
                      Jurnal
                    >(
                      currentTable: table,
                      referencedTable: $$KeuskupansTableReferences
                          ._jurnalsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$KeuskupansTableReferences(
                            db,
                            table,
                            p0,
                          ).jurnalsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.keuskupanId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$KeuskupansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeuskupansTable,
      Keuskupan,
      $$KeuskupansTableFilterComposer,
      $$KeuskupansTableOrderingComposer,
      $$KeuskupansTableAnnotationComposer,
      $$KeuskupansTableCreateCompanionBuilder,
      $$KeuskupansTableUpdateCompanionBuilder,
      (Keuskupan, $$KeuskupansTableReferences),
      Keuskupan,
      PrefetchHooks Function({bool parokisRefs, bool jurnalsRefs})
    >;
typedef $$ParokisTableCreateCompanionBuilder =
    ParokisCompanion Function({
      required String id,
      required String nama,
      required String alamat,
      required String keuskupanId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ParokisTableUpdateCompanionBuilder =
    ParokisCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> alamat,
      Value<String> keuskupanId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ParokisTableReferences
    extends BaseReferences<_$AppDatabase, $ParokisTable, Paroki> {
  $$ParokisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KeuskupansTable _keuskupanIdTable(_$AppDatabase db) =>
      db.keuskupans.createAlias('parokis__keuskupan_id__keuskupans__id');

  $$KeuskupansTableProcessedTableManager get keuskupanId {
    final $_column = $_itemColumn<String>('keuskupan_id')!;

    final manager = $$KeuskupansTableTableManager(
      $_db,
      $_db.keuskupans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_keuskupanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetilJurnalsTable, List<DetilJurnal>>
  _detilJurnalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detilJurnals,
    aliasName: 'parokis__id__detil_jurnals__paroki_id',
  );

  $$DetilJurnalsTableProcessedTableManager get detilJurnalsRefs {
    final manager = $$DetilJurnalsTableTableManager(
      $_db,
      $_db.detilJurnals,
    ).filter((f) => f.parokiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detilJurnalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParokisTableFilterComposer
    extends Composer<_$AppDatabase, $ParokisTable> {
  $$ParokisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$KeuskupansTableFilterComposer get keuskupanId {
    final $$KeuskupansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableFilterComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detilJurnalsRefs(
    Expression<bool> Function($$DetilJurnalsTableFilterComposer f) f,
  ) {
    final $$DetilJurnalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.parokiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableFilterComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParokisTableOrderingComposer
    extends Composer<_$AppDatabase, $ParokisTable> {
  $$ParokisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alamat => $composableBuilder(
    column: $table.alamat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$KeuskupansTableOrderingComposer get keuskupanId {
    final $$KeuskupansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableOrderingComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParokisTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParokisTable> {
  $$ParokisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get alamat =>
      $composableBuilder(column: $table.alamat, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$KeuskupansTableAnnotationComposer get keuskupanId {
    final $$KeuskupansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableAnnotationComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> detilJurnalsRefs<T extends Object>(
    Expression<T> Function($$DetilJurnalsTableAnnotationComposer a) f,
  ) {
    final $$DetilJurnalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.parokiId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableAnnotationComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParokisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParokisTable,
          Paroki,
          $$ParokisTableFilterComposer,
          $$ParokisTableOrderingComposer,
          $$ParokisTableAnnotationComposer,
          $$ParokisTableCreateCompanionBuilder,
          $$ParokisTableUpdateCompanionBuilder,
          (Paroki, $$ParokisTableReferences),
          Paroki,
          PrefetchHooks Function({bool keuskupanId, bool detilJurnalsRefs})
        > {
  $$ParokisTableTableManager(_$AppDatabase db, $ParokisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParokisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParokisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParokisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> alamat = const Value.absent(),
                Value<String> keuskupanId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParokisCompanion(
                id: id,
                nama: nama,
                alamat: alamat,
                keuskupanId: keuskupanId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String alamat,
                required String keuskupanId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParokisCompanion.insert(
                id: id,
                nama: nama,
                alamat: alamat,
                keuskupanId: keuskupanId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParokisTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({keuskupanId = false, detilJurnalsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (detilJurnalsRefs) db.detilJurnals,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (keuskupanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.keuskupanId,
                                    referencedTable: $$ParokisTableReferences
                                        ._keuskupanIdTable(db),
                                    referencedColumn: $$ParokisTableReferences
                                        ._keuskupanIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (detilJurnalsRefs)
                        await $_getPrefetchedData<
                          Paroki,
                          $ParokisTable,
                          DetilJurnal
                        >(
                          currentTable: table,
                          referencedTable: $$ParokisTableReferences
                              ._detilJurnalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ParokisTableReferences(
                                db,
                                table,
                                p0,
                              ).detilJurnalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.parokiId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ParokisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParokisTable,
      Paroki,
      $$ParokisTableFilterComposer,
      $$ParokisTableOrderingComposer,
      $$ParokisTableAnnotationComposer,
      $$ParokisTableCreateCompanionBuilder,
      $$ParokisTableUpdateCompanionBuilder,
      (Paroki, $$ParokisTableReferences),
      Paroki,
      PrefetchHooks Function({bool keuskupanId, bool detilJurnalsRefs})
    >;
typedef $$JenisTableCreateCompanionBuilder =
    JenisCompanion Function({
      required String id,
      required String nama,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$JenisTableUpdateCompanionBuilder =
    JenisCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$JenisTableReferences
    extends BaseReferences<_$AppDatabase, $JenisTable, Jeni> {
  $$JenisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AkunsTable, List<Akun>> _akunsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.akuns,
    aliasName: 'jenis__id__akuns__jenis_id',
  );

  $$AkunsTableProcessedTableManager get akunsRefs {
    final manager = $$AkunsTableTableManager(
      $_db,
      $_db.akuns,
    ).filter((f) => f.jenisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_akunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JenisTableFilterComposer extends Composer<_$AppDatabase, $JenisTable> {
  $$JenisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> akunsRefs(
    Expression<bool> Function($$AkunsTableFilterComposer f) f,
  ) {
    final $$AkunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.jenisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableFilterComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JenisTableOrderingComposer
    extends Composer<_$AppDatabase, $JenisTable> {
  $$JenisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JenisTableAnnotationComposer
    extends Composer<_$AppDatabase, $JenisTable> {
  $$JenisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> akunsRefs<T extends Object>(
    Expression<T> Function($$AkunsTableAnnotationComposer a) f,
  ) {
    final $$AkunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.jenisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableAnnotationComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JenisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JenisTable,
          Jeni,
          $$JenisTableFilterComposer,
          $$JenisTableOrderingComposer,
          $$JenisTableAnnotationComposer,
          $$JenisTableCreateCompanionBuilder,
          $$JenisTableUpdateCompanionBuilder,
          (Jeni, $$JenisTableReferences),
          Jeni,
          PrefetchHooks Function({bool akunsRefs})
        > {
  $$JenisTableTableManager(_$AppDatabase db, $JenisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JenisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JenisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JenisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JenisCompanion(
                id: id,
                nama: nama,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JenisCompanion.insert(
                id: id,
                nama: nama,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JenisTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({akunsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (akunsRefs) db.akuns],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (akunsRefs)
                    await $_getPrefetchedData<Jeni, $JenisTable, Akun>(
                      currentTable: table,
                      referencedTable: $$JenisTableReferences._akunsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$JenisTableReferences(db, table, p0).akunsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.jenisId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JenisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JenisTable,
      Jeni,
      $$JenisTableFilterComposer,
      $$JenisTableOrderingComposer,
      $$JenisTableAnnotationComposer,
      $$JenisTableCreateCompanionBuilder,
      $$JenisTableUpdateCompanionBuilder,
      (Jeni, $$JenisTableReferences),
      Jeni,
      PrefetchHooks Function({bool akunsRefs})
    >;
typedef $$AkunsTableCreateCompanionBuilder =
    AkunsCompanion Function({
      required String id,
      required String kode,
      required String nama,
      required String jenisId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$AkunsTableUpdateCompanionBuilder =
    AkunsCompanion Function({
      Value<String> id,
      Value<String> kode,
      Value<String> nama,
      Value<String> jenisId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$AkunsTableReferences
    extends BaseReferences<_$AppDatabase, $AkunsTable, Akun> {
  $$AkunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JenisTable _jenisIdTable(_$AppDatabase db) =>
      db.jenis.createAlias('akuns__jenis_id__jenis__id');

  $$JenisTableProcessedTableManager get jenisId {
    final $_column = $_itemColumn<String>('jenis_id')!;

    final manager = $$JenisTableTableManager(
      $_db,
      $_db.jenis,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jenisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetilJurnalsTable, List<DetilJurnal>>
  _detilJurnalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detilJurnals,
    aliasName: 'akuns__id__detil_jurnals__akun_id',
  );

  $$DetilJurnalsTableProcessedTableManager get detilJurnalsRefs {
    final manager = $$DetilJurnalsTableTableManager(
      $_db,
      $_db.detilJurnals,
    ).filter((f) => f.akunId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detilJurnalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AkunsTableFilterComposer extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kode => $composableBuilder(
    column: $table.kode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$JenisTableFilterComposer get jenisId {
    final $$JenisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jenisId,
      referencedTable: $db.jenis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JenisTableFilterComposer(
            $db: $db,
            $table: $db.jenis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detilJurnalsRefs(
    Expression<bool> Function($$DetilJurnalsTableFilterComposer f) f,
  ) {
    final $$DetilJurnalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableFilterComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AkunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kode => $composableBuilder(
    column: $table.kode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$JenisTableOrderingComposer get jenisId {
    final $$JenisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jenisId,
      referencedTable: $db.jenis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JenisTableOrderingComposer(
            $db: $db,
            $table: $db.jenis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AkunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AkunsTable> {
  $$AkunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kode =>
      $composableBuilder(column: $table.kode, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$JenisTableAnnotationComposer get jenisId {
    final $$JenisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jenisId,
      referencedTable: $db.jenis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JenisTableAnnotationComposer(
            $db: $db,
            $table: $db.jenis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> detilJurnalsRefs<T extends Object>(
    Expression<T> Function($$DetilJurnalsTableAnnotationComposer a) f,
  ) {
    final $$DetilJurnalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.akunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableAnnotationComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AkunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AkunsTable,
          Akun,
          $$AkunsTableFilterComposer,
          $$AkunsTableOrderingComposer,
          $$AkunsTableAnnotationComposer,
          $$AkunsTableCreateCompanionBuilder,
          $$AkunsTableUpdateCompanionBuilder,
          (Akun, $$AkunsTableReferences),
          Akun,
          PrefetchHooks Function({bool jenisId, bool detilJurnalsRefs})
        > {
  $$AkunsTableTableManager(_$AppDatabase db, $AkunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AkunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AkunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AkunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kode = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> jenisId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AkunsCompanion(
                id: id,
                kode: kode,
                nama: nama,
                jenisId: jenisId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kode,
                required String nama,
                required String jenisId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AkunsCompanion.insert(
                id: id,
                kode: kode,
                nama: nama,
                jenisId: jenisId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AkunsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({jenisId = false, detilJurnalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (detilJurnalsRefs) db.detilJurnals],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (jenisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jenisId,
                                referencedTable: $$AkunsTableReferences
                                    ._jenisIdTable(db),
                                referencedColumn: $$AkunsTableReferences
                                    ._jenisIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detilJurnalsRefs)
                    await $_getPrefetchedData<Akun, $AkunsTable, DetilJurnal>(
                      currentTable: table,
                      referencedTable: $$AkunsTableReferences
                          ._detilJurnalsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AkunsTableReferences(
                        db,
                        table,
                        p0,
                      ).detilJurnalsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.akunId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AkunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AkunsTable,
      Akun,
      $$AkunsTableFilterComposer,
      $$AkunsTableOrderingComposer,
      $$AkunsTableAnnotationComposer,
      $$AkunsTableCreateCompanionBuilder,
      $$AkunsTableUpdateCompanionBuilder,
      (Akun, $$AkunsTableReferences),
      Akun,
      PrefetchHooks Function({bool jenisId, bool detilJurnalsRefs})
    >;
typedef $$JurnalsTableCreateCompanionBuilder =
    JurnalsCompanion Function({
      required String id,
      required String keuskupanId,
      required DateTime tanggal,
      Value<String?> deskripsi,
      Value<String?> noBukti,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$JurnalsTableUpdateCompanionBuilder =
    JurnalsCompanion Function({
      Value<String> id,
      Value<String> keuskupanId,
      Value<DateTime> tanggal,
      Value<String?> deskripsi,
      Value<String?> noBukti,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$JurnalsTableReferences
    extends BaseReferences<_$AppDatabase, $JurnalsTable, Jurnal> {
  $$JurnalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KeuskupansTable _keuskupanIdTable(_$AppDatabase db) =>
      db.keuskupans.createAlias('jurnals__keuskupan_id__keuskupans__id');

  $$KeuskupansTableProcessedTableManager get keuskupanId {
    final $_column = $_itemColumn<String>('keuskupan_id')!;

    final manager = $$KeuskupansTableTableManager(
      $_db,
      $_db.keuskupans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_keuskupanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetilJurnalsTable, List<DetilJurnal>>
  _detilJurnalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detilJurnals,
    aliasName: 'jurnals__id__detil_jurnals__jurnal_id',
  );

  $$DetilJurnalsTableProcessedTableManager get detilJurnalsRefs {
    final manager = $$DetilJurnalsTableTableManager(
      $_db,
      $_db.detilJurnals,
    ).filter((f) => f.jurnalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detilJurnalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JurnalsTableFilterComposer
    extends Composer<_$AppDatabase, $JurnalsTable> {
  $$JurnalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get tanggal =>
      $composableBuilder(
        column: $table.tanggal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noBukti => $composableBuilder(
    column: $table.noBukti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$KeuskupansTableFilterComposer get keuskupanId {
    final $$KeuskupansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableFilterComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detilJurnalsRefs(
    Expression<bool> Function($$DetilJurnalsTableFilterComposer f) f,
  ) {
    final $$DetilJurnalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.jurnalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableFilterComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JurnalsTableOrderingComposer
    extends Composer<_$AppDatabase, $JurnalsTable> {
  $$JurnalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noBukti => $composableBuilder(
    column: $table.noBukti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$KeuskupansTableOrderingComposer get keuskupanId {
    final $$KeuskupansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableOrderingComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JurnalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JurnalsTable> {
  $$JurnalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumn<String> get noBukti =>
      $composableBuilder(column: $table.noBukti, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$KeuskupansTableAnnotationComposer get keuskupanId {
    final $$KeuskupansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keuskupanId,
      referencedTable: $db.keuskupans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KeuskupansTableAnnotationComposer(
            $db: $db,
            $table: $db.keuskupans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> detilJurnalsRefs<T extends Object>(
    Expression<T> Function($$DetilJurnalsTableAnnotationComposer a) f,
  ) {
    final $$DetilJurnalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detilJurnals,
      getReferencedColumn: (t) => t.jurnalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetilJurnalsTableAnnotationComposer(
            $db: $db,
            $table: $db.detilJurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JurnalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JurnalsTable,
          Jurnal,
          $$JurnalsTableFilterComposer,
          $$JurnalsTableOrderingComposer,
          $$JurnalsTableAnnotationComposer,
          $$JurnalsTableCreateCompanionBuilder,
          $$JurnalsTableUpdateCompanionBuilder,
          (Jurnal, $$JurnalsTableReferences),
          Jurnal,
          PrefetchHooks Function({bool keuskupanId, bool detilJurnalsRefs})
        > {
  $$JurnalsTableTableManager(_$AppDatabase db, $JurnalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JurnalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JurnalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JurnalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> keuskupanId = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<String?> deskripsi = const Value.absent(),
                Value<String?> noBukti = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JurnalsCompanion(
                id: id,
                keuskupanId: keuskupanId,
                tanggal: tanggal,
                deskripsi: deskripsi,
                noBukti: noBukti,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String keuskupanId,
                required DateTime tanggal,
                Value<String?> deskripsi = const Value.absent(),
                Value<String?> noBukti = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JurnalsCompanion.insert(
                id: id,
                keuskupanId: keuskupanId,
                tanggal: tanggal,
                deskripsi: deskripsi,
                noBukti: noBukti,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JurnalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({keuskupanId = false, detilJurnalsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (detilJurnalsRefs) db.detilJurnals,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (keuskupanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.keuskupanId,
                                    referencedTable: $$JurnalsTableReferences
                                        ._keuskupanIdTable(db),
                                    referencedColumn: $$JurnalsTableReferences
                                        ._keuskupanIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (detilJurnalsRefs)
                        await $_getPrefetchedData<
                          Jurnal,
                          $JurnalsTable,
                          DetilJurnal
                        >(
                          currentTable: table,
                          referencedTable: $$JurnalsTableReferences
                              ._detilJurnalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JurnalsTableReferences(
                                db,
                                table,
                                p0,
                              ).detilJurnalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jurnalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JurnalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JurnalsTable,
      Jurnal,
      $$JurnalsTableFilterComposer,
      $$JurnalsTableOrderingComposer,
      $$JurnalsTableAnnotationComposer,
      $$JurnalsTableCreateCompanionBuilder,
      $$JurnalsTableUpdateCompanionBuilder,
      (Jurnal, $$JurnalsTableReferences),
      Jurnal,
      PrefetchHooks Function({bool keuskupanId, bool detilJurnalsRefs})
    >;
typedef $$DetilJurnalsTableCreateCompanionBuilder =
    DetilJurnalsCompanion Function({
      required String id,
      required String jurnalId,
      required String akunId,
      required String parokiId,
      Value<double?> debit,
      Value<double?> kredit,
      Value<String?> keterangan,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$DetilJurnalsTableUpdateCompanionBuilder =
    DetilJurnalsCompanion Function({
      Value<String> id,
      Value<String> jurnalId,
      Value<String> akunId,
      Value<String> parokiId,
      Value<double?> debit,
      Value<double?> kredit,
      Value<String?> keterangan,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$DetilJurnalsTableReferences
    extends BaseReferences<_$AppDatabase, $DetilJurnalsTable, DetilJurnal> {
  $$DetilJurnalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JurnalsTable _jurnalIdTable(_$AppDatabase db) =>
      db.jurnals.createAlias('detil_jurnals__jurnal_id__jurnals__id');

  $$JurnalsTableProcessedTableManager get jurnalId {
    final $_column = $_itemColumn<String>('jurnal_id')!;

    final manager = $$JurnalsTableTableManager(
      $_db,
      $_db.jurnals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jurnalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AkunsTable _akunIdTable(_$AppDatabase db) =>
      db.akuns.createAlias('detil_jurnals__akun_id__akuns__id');

  $$AkunsTableProcessedTableManager get akunId {
    final $_column = $_itemColumn<String>('akun_id')!;

    final manager = $$AkunsTableTableManager(
      $_db,
      $_db.akuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_akunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ParokisTable _parokiIdTable(_$AppDatabase db) =>
      db.parokis.createAlias('detil_jurnals__paroki_id__parokis__id');

  $$ParokisTableProcessedTableManager get parokiId {
    final $_column = $_itemColumn<String>('paroki_id')!;

    final manager = $$ParokisTableTableManager(
      $_db,
      $_db.parokis,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parokiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetilJurnalsTableFilterComposer
    extends Composer<_$AppDatabase, $DetilJurnalsTable> {
  $$DetilJurnalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kredit => $composableBuilder(
    column: $table.kredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$JurnalsTableFilterComposer get jurnalId {
    final $$JurnalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurnalId,
      referencedTable: $db.jurnals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JurnalsTableFilterComposer(
            $db: $db,
            $table: $db.jurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AkunsTableFilterComposer get akunId {
    final $$AkunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableFilterComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParokisTableFilterComposer get parokiId {
    final $$ParokisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parokiId,
      referencedTable: $db.parokis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParokisTableFilterComposer(
            $db: $db,
            $table: $db.parokis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetilJurnalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetilJurnalsTable> {
  $$DetilJurnalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debit => $composableBuilder(
    column: $table.debit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kredit => $composableBuilder(
    column: $table.kredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$JurnalsTableOrderingComposer get jurnalId {
    final $$JurnalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurnalId,
      referencedTable: $db.jurnals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JurnalsTableOrderingComposer(
            $db: $db,
            $table: $db.jurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AkunsTableOrderingComposer get akunId {
    final $$AkunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableOrderingComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParokisTableOrderingComposer get parokiId {
    final $$ParokisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parokiId,
      referencedTable: $db.parokis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParokisTableOrderingComposer(
            $db: $db,
            $table: $db.parokis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetilJurnalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetilJurnalsTable> {
  $$DetilJurnalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get debit =>
      $composableBuilder(column: $table.debit, builder: (column) => column);

  GeneratedColumn<double> get kredit =>
      $composableBuilder(column: $table.kredit, builder: (column) => column);

  GeneratedColumn<String> get keterangan => $composableBuilder(
    column: $table.keterangan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$JurnalsTableAnnotationComposer get jurnalId {
    final $$JurnalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jurnalId,
      referencedTable: $db.jurnals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JurnalsTableAnnotationComposer(
            $db: $db,
            $table: $db.jurnals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AkunsTableAnnotationComposer get akunId {
    final $$AkunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.akunId,
      referencedTable: $db.akuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AkunsTableAnnotationComposer(
            $db: $db,
            $table: $db.akuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ParokisTableAnnotationComposer get parokiId {
    final $$ParokisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parokiId,
      referencedTable: $db.parokis,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParokisTableAnnotationComposer(
            $db: $db,
            $table: $db.parokis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetilJurnalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetilJurnalsTable,
          DetilJurnal,
          $$DetilJurnalsTableFilterComposer,
          $$DetilJurnalsTableOrderingComposer,
          $$DetilJurnalsTableAnnotationComposer,
          $$DetilJurnalsTableCreateCompanionBuilder,
          $$DetilJurnalsTableUpdateCompanionBuilder,
          (DetilJurnal, $$DetilJurnalsTableReferences),
          DetilJurnal,
          PrefetchHooks Function({bool jurnalId, bool akunId, bool parokiId})
        > {
  $$DetilJurnalsTableTableManager(_$AppDatabase db, $DetilJurnalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetilJurnalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetilJurnalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetilJurnalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jurnalId = const Value.absent(),
                Value<String> akunId = const Value.absent(),
                Value<String> parokiId = const Value.absent(),
                Value<double?> debit = const Value.absent(),
                Value<double?> kredit = const Value.absent(),
                Value<String?> keterangan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DetilJurnalsCompanion(
                id: id,
                jurnalId: jurnalId,
                akunId: akunId,
                parokiId: parokiId,
                debit: debit,
                kredit: kredit,
                keterangan: keterangan,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jurnalId,
                required String akunId,
                required String parokiId,
                Value<double?> debit = const Value.absent(),
                Value<double?> kredit = const Value.absent(),
                Value<String?> keterangan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DetilJurnalsCompanion.insert(
                id: id,
                jurnalId: jurnalId,
                akunId: akunId,
                parokiId: parokiId,
                debit: debit,
                kredit: kredit,
                keterangan: keterangan,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DetilJurnalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({jurnalId = false, akunId = false, parokiId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (jurnalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.jurnalId,
                                    referencedTable:
                                        $$DetilJurnalsTableReferences
                                            ._jurnalIdTable(db),
                                    referencedColumn:
                                        $$DetilJurnalsTableReferences
                                            ._jurnalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (akunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.akunId,
                                    referencedTable:
                                        $$DetilJurnalsTableReferences
                                            ._akunIdTable(db),
                                    referencedColumn:
                                        $$DetilJurnalsTableReferences
                                            ._akunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (parokiId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parokiId,
                                    referencedTable:
                                        $$DetilJurnalsTableReferences
                                            ._parokiIdTable(db),
                                    referencedColumn:
                                        $$DetilJurnalsTableReferences
                                            ._parokiIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DetilJurnalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetilJurnalsTable,
      DetilJurnal,
      $$DetilJurnalsTableFilterComposer,
      $$DetilJurnalsTableOrderingComposer,
      $$DetilJurnalsTableAnnotationComposer,
      $$DetilJurnalsTableCreateCompanionBuilder,
      $$DetilJurnalsTableUpdateCompanionBuilder,
      (DetilJurnal, $$DetilJurnalsTableReferences),
      DetilJurnal,
      PrefetchHooks Function({bool jurnalId, bool akunId, bool parokiId})
    >;
typedef $$SyncQueuesTableCreateCompanionBuilder =
    SyncQueuesCompanion Function({
      Value<int> id,
      required String targetTable,
      required String rowId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });
typedef $$SyncQueuesTableUpdateCompanionBuilder =
    SyncQueuesCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<String> rowId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$SyncQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueuesTable,
          SyncQueue,
          $$SyncQueuesTableFilterComposer,
          $$SyncQueuesTableOrderingComposer,
          $$SyncQueuesTableAnnotationComposer,
          $$SyncQueuesTableCreateCompanionBuilder,
          $$SyncQueuesTableUpdateCompanionBuilder,
          (
            SyncQueue,
            BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>,
          ),
          SyncQueue,
          PrefetchHooks Function()
        > {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueuesCompanion(
                id: id,
                targetTable: targetTable,
                rowId: rowId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                required String rowId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueuesCompanion.insert(
                id: id,
                targetTable: targetTable,
                rowId: rowId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueuesTable,
      SyncQueue,
      $$SyncQueuesTableFilterComposer,
      $$SyncQueuesTableOrderingComposer,
      $$SyncQueuesTableAnnotationComposer,
      $$SyncQueuesTableCreateCompanionBuilder,
      $$SyncQueuesTableUpdateCompanionBuilder,
      (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
      SyncQueue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$KeuskupansTableTableManager get keuskupans =>
      $$KeuskupansTableTableManager(_db, _db.keuskupans);
  $$ParokisTableTableManager get parokis =>
      $$ParokisTableTableManager(_db, _db.parokis);
  $$JenisTableTableManager get jenis =>
      $$JenisTableTableManager(_db, _db.jenis);
  $$AkunsTableTableManager get akuns =>
      $$AkunsTableTableManager(_db, _db.akuns);
  $$JurnalsTableTableManager get jurnals =>
      $$JurnalsTableTableManager(_db, _db.jurnals);
  $$DetilJurnalsTableTableManager get detilJurnals =>
      $$DetilJurnalsTableTableManager(_db, _db.detilJurnals);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
}
