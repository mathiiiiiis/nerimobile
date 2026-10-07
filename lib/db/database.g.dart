// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AnnouncementsTable extends Announcements
    with TableInfo<$AnnouncementsTable, AnnouncementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'announcements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnnouncementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnnouncementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnnouncementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $AnnouncementsTable createAlias(String alias) {
    return $AnnouncementsTable(attachedDatabase, alias);
  }
}

class AnnouncementRow extends DataClass implements Insertable<AnnouncementRow> {
  final String id;
  final String payload;
  final int position;
  const AnnouncementRow({
    required this.id,
    required this.payload,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['position'] = Variable<int>(position);
    return map;
  }

  AnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return AnnouncementsCompanion(
      id: Value(id),
      payload: Value(payload),
      position: Value(position),
    );
  }

  factory AnnouncementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnnouncementRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'position': serializer.toJson<int>(position),
    };
  }

  AnnouncementRow copyWith({String? id, String? payload, int? position}) =>
      AnnouncementRow(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        position: position ?? this.position,
      );
  AnnouncementRow copyWithCompanion(AnnouncementsCompanion data) {
    return AnnouncementRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnnouncementRow(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnnouncementRow &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.position == this.position);
}

class AnnouncementsCompanion extends UpdateCompanion<AnnouncementRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> position;
  final Value<int> rowid;
  const AnnouncementsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnouncementsCompanion.insert({
    required String id,
    required String payload,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload),
       position = Value(position);
  static Insertable<AnnouncementRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnouncementsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return AnnouncementsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnouncementsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels
    with TableInfo<$ChannelsTable, ChannelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessagedAtMeta = const VerificationMeta(
    'lastMessagedAt',
  );
  @override
  late final GeneratedColumn<int> lastMessagedAt = GeneratedColumn<int>(
    'last_messaged_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
    'permissions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    name,
    order,
    serverId,
    icon,
    categoryId,
    lastMessagedAt,
    permissions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('last_messaged_at')) {
      context.handle(
        _lastMessagedAtMeta,
        lastMessagedAt.isAcceptableOrUnknown(
          data['last_messaged_at']!,
          _lastMessagedAtMeta,
        ),
      );
    }
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChannelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      lastMessagedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_messaged_at'],
      ),
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions'],
      ),
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class ChannelRow extends DataClass implements Insertable<ChannelRow> {
  final String id;
  final int type;
  final String? name;
  final int? order;
  final String? serverId;
  final String? icon;
  final String? categoryId;
  final int? lastMessagedAt;
  final String? permissions;
  const ChannelRow({
    required this.id,
    required this.type,
    this.name,
    this.order,
    this.serverId,
    this.icon,
    this.categoryId,
    this.lastMessagedAt,
    this.permissions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || lastMessagedAt != null) {
      map['last_messaged_at'] = Variable<int>(lastMessagedAt);
    }
    if (!nullToAbsent || permissions != null) {
      map['permissions'] = Variable<String>(permissions);
    }
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      id: Value(id),
      type: Value(type),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      lastMessagedAt: lastMessagedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagedAt),
      permissions: permissions == null && nullToAbsent
          ? const Value.absent()
          : Value(permissions),
    );
  }

  factory ChannelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      name: serializer.fromJson<String?>(json['name']),
      order: serializer.fromJson<int?>(json['order']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      icon: serializer.fromJson<String?>(json['icon']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      lastMessagedAt: serializer.fromJson<int?>(json['lastMessagedAt']),
      permissions: serializer.fromJson<String?>(json['permissions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'name': serializer.toJson<String?>(name),
      'order': serializer.toJson<int?>(order),
      'serverId': serializer.toJson<String?>(serverId),
      'icon': serializer.toJson<String?>(icon),
      'categoryId': serializer.toJson<String?>(categoryId),
      'lastMessagedAt': serializer.toJson<int?>(lastMessagedAt),
      'permissions': serializer.toJson<String?>(permissions),
    };
  }

  ChannelRow copyWith({
    String? id,
    int? type,
    Value<String?> name = const Value.absent(),
    Value<int?> order = const Value.absent(),
    Value<String?> serverId = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<int?> lastMessagedAt = const Value.absent(),
    Value<String?> permissions = const Value.absent(),
  }) => ChannelRow(
    id: id ?? this.id,
    type: type ?? this.type,
    name: name.present ? name.value : this.name,
    order: order.present ? order.value : this.order,
    serverId: serverId.present ? serverId.value : this.serverId,
    icon: icon.present ? icon.value : this.icon,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    lastMessagedAt: lastMessagedAt.present
        ? lastMessagedAt.value
        : this.lastMessagedAt,
    permissions: permissions.present ? permissions.value : this.permissions,
  );
  ChannelRow copyWithCompanion(ChannelsCompanion data) {
    return ChannelRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      order: data.order.present ? data.order.value : this.order,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      icon: data.icon.present ? data.icon.value : this.icon,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      lastMessagedAt: data.lastMessagedAt.present
          ? data.lastMessagedAt.value
          : this.lastMessagedAt,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('serverId: $serverId, ')
          ..write('icon: $icon, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastMessagedAt: $lastMessagedAt, ')
          ..write('permissions: $permissions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    name,
    order,
    serverId,
    icon,
    categoryId,
    lastMessagedAt,
    permissions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.order == this.order &&
          other.serverId == this.serverId &&
          other.icon == this.icon &&
          other.categoryId == this.categoryId &&
          other.lastMessagedAt == this.lastMessagedAt &&
          other.permissions == this.permissions);
}

class ChannelsCompanion extends UpdateCompanion<ChannelRow> {
  final Value<String> id;
  final Value<int> type;
  final Value<String?> name;
  final Value<int?> order;
  final Value<String?> serverId;
  final Value<String?> icon;
  final Value<String?> categoryId;
  final Value<int?> lastMessagedAt;
  final Value<String?> permissions;
  final Value<int> rowid;
  const ChannelsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.serverId = const Value.absent(),
    this.icon = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastMessagedAt = const Value.absent(),
    this.permissions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelsCompanion.insert({
    required String id,
    required int type,
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.serverId = const Value.absent(),
    this.icon = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.lastMessagedAt = const Value.absent(),
    this.permissions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type);
  static Insertable<ChannelRow> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<String>? name,
    Expression<int>? order,
    Expression<String>? serverId,
    Expression<String>? icon,
    Expression<String>? categoryId,
    Expression<int>? lastMessagedAt,
    Expression<String>? permissions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
      if (serverId != null) 'server_id': serverId,
      if (icon != null) 'icon': icon,
      if (categoryId != null) 'category_id': categoryId,
      if (lastMessagedAt != null) 'last_messaged_at': lastMessagedAt,
      if (permissions != null) 'permissions': permissions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelsCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<String?>? name,
    Value<int?>? order,
    Value<String?>? serverId,
    Value<String?>? icon,
    Value<String?>? categoryId,
    Value<int?>? lastMessagedAt,
    Value<String?>? permissions,
    Value<int>? rowid,
  }) {
    return ChannelsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      order: order ?? this.order,
      serverId: serverId ?? this.serverId,
      icon: icon ?? this.icon,
      categoryId: categoryId ?? this.categoryId,
      lastMessagedAt: lastMessagedAt ?? this.lastMessagedAt,
      permissions: permissions ?? this.permissions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (lastMessagedAt.present) {
      map['last_messaged_at'] = Variable<int>(lastMessagedAt.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('serverId: $serverId, ')
          ..write('icon: $icon, ')
          ..write('categoryId: $categoryId, ')
          ..write('lastMessagedAt: $lastMessagedAt, ')
          ..write('permissions: $permissions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DismissedAnnouncementsTable extends DismissedAnnouncements
    with TableInfo<$DismissedAnnouncementsTable, DismissedAnnouncementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DismissedAnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dismissed_announcements';
  @override
  VerificationContext validateIntegrity(
    Insertable<DismissedAnnouncementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DismissedAnnouncementRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DismissedAnnouncementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $DismissedAnnouncementsTable createAlias(String alias) {
    return $DismissedAnnouncementsTable(attachedDatabase, alias);
  }
}

class DismissedAnnouncementRow extends DataClass
    implements Insertable<DismissedAnnouncementRow> {
  final String id;
  const DismissedAnnouncementRow({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    return map;
  }

  DismissedAnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return DismissedAnnouncementsCompanion(id: Value(id));
  }

  factory DismissedAnnouncementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DismissedAnnouncementRow(
      id: serializer.fromJson<String>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<String>(id)};
  }

  DismissedAnnouncementRow copyWith({String? id}) =>
      DismissedAnnouncementRow(id: id ?? this.id);
  DismissedAnnouncementRow copyWithCompanion(
    DismissedAnnouncementsCompanion data,
  ) {
    return DismissedAnnouncementRow(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DismissedAnnouncementRow(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DismissedAnnouncementRow && other.id == this.id);
}

class DismissedAnnouncementsCompanion
    extends UpdateCompanion<DismissedAnnouncementRow> {
  final Value<String> id;
  final Value<int> rowid;
  const DismissedAnnouncementsCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DismissedAnnouncementsCompanion.insert({
    required String id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DismissedAnnouncementRow> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DismissedAnnouncementsCompanion copyWith({
    Value<String>? id,
    Value<int>? rowid,
  }) {
    return DismissedAnnouncementsCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DismissedAnnouncementsCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteGifsTable extends FavoriteGifs
    with TableInfo<$FavoriteGifsTable, FavoriteGifRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteGifsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previewUrlMeta = const VerificationMeta(
    'previewUrl',
  );
  @override
  late final GeneratedColumn<String> previewUrl = GeneratedColumn<String>(
    'preview_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previewWidthMeta = const VerificationMeta(
    'previewWidth',
  );
  @override
  late final GeneratedColumn<int> previewWidth = GeneratedColumn<int>(
    'preview_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previewHeightMeta = const VerificationMeta(
    'previewHeight',
  );
  @override
  late final GeneratedColumn<int> previewHeight = GeneratedColumn<int>(
    'preview_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<int> savedAt = GeneratedColumn<int>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    previewUrl,
    previewWidth,
    previewHeight,
    source,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_gifs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteGifRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('preview_url')) {
      context.handle(
        _previewUrlMeta,
        previewUrl.isAcceptableOrUnknown(data['preview_url']!, _previewUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_previewUrlMeta);
    }
    if (data.containsKey('preview_width')) {
      context.handle(
        _previewWidthMeta,
        previewWidth.isAcceptableOrUnknown(
          data['preview_width']!,
          _previewWidthMeta,
        ),
      );
    }
    if (data.containsKey('preview_height')) {
      context.handle(
        _previewHeightMeta,
        previewHeight.isAcceptableOrUnknown(
          data['preview_height']!,
          _previewHeightMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  FavoriteGifRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteGifRow(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      previewUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_url'],
      )!,
      previewWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preview_width'],
      ),
      previewHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preview_height'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $FavoriteGifsTable createAlias(String alias) {
    return $FavoriteGifsTable(attachedDatabase, alias);
  }
}

class FavoriteGifRow extends DataClass implements Insertable<FavoriteGifRow> {
  final String url;
  final String previewUrl;
  final int? previewWidth;
  final int? previewHeight;
  final String source;
  final int savedAt;
  const FavoriteGifRow({
    required this.url,
    required this.previewUrl,
    this.previewWidth,
    this.previewHeight,
    required this.source,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['preview_url'] = Variable<String>(previewUrl);
    if (!nullToAbsent || previewWidth != null) {
      map['preview_width'] = Variable<int>(previewWidth);
    }
    if (!nullToAbsent || previewHeight != null) {
      map['preview_height'] = Variable<int>(previewHeight);
    }
    map['source'] = Variable<String>(source);
    map['saved_at'] = Variable<int>(savedAt);
    return map;
  }

  FavoriteGifsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteGifsCompanion(
      url: Value(url),
      previewUrl: Value(previewUrl),
      previewWidth: previewWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(previewWidth),
      previewHeight: previewHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(previewHeight),
      source: Value(source),
      savedAt: Value(savedAt),
    );
  }

  factory FavoriteGifRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteGifRow(
      url: serializer.fromJson<String>(json['url']),
      previewUrl: serializer.fromJson<String>(json['previewUrl']),
      previewWidth: serializer.fromJson<int?>(json['previewWidth']),
      previewHeight: serializer.fromJson<int?>(json['previewHeight']),
      source: serializer.fromJson<String>(json['source']),
      savedAt: serializer.fromJson<int>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'previewUrl': serializer.toJson<String>(previewUrl),
      'previewWidth': serializer.toJson<int?>(previewWidth),
      'previewHeight': serializer.toJson<int?>(previewHeight),
      'source': serializer.toJson<String>(source),
      'savedAt': serializer.toJson<int>(savedAt),
    };
  }

  FavoriteGifRow copyWith({
    String? url,
    String? previewUrl,
    Value<int?> previewWidth = const Value.absent(),
    Value<int?> previewHeight = const Value.absent(),
    String? source,
    int? savedAt,
  }) => FavoriteGifRow(
    url: url ?? this.url,
    previewUrl: previewUrl ?? this.previewUrl,
    previewWidth: previewWidth.present ? previewWidth.value : this.previewWidth,
    previewHeight: previewHeight.present
        ? previewHeight.value
        : this.previewHeight,
    source: source ?? this.source,
    savedAt: savedAt ?? this.savedAt,
  );
  FavoriteGifRow copyWithCompanion(FavoriteGifsCompanion data) {
    return FavoriteGifRow(
      url: data.url.present ? data.url.value : this.url,
      previewUrl: data.previewUrl.present
          ? data.previewUrl.value
          : this.previewUrl,
      previewWidth: data.previewWidth.present
          ? data.previewWidth.value
          : this.previewWidth,
      previewHeight: data.previewHeight.present
          ? data.previewHeight.value
          : this.previewHeight,
      source: data.source.present ? data.source.value : this.source,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteGifRow(')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('previewWidth: $previewWidth, ')
          ..write('previewHeight: $previewHeight, ')
          ..write('source: $source, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    previewUrl,
    previewWidth,
    previewHeight,
    source,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteGifRow &&
          other.url == this.url &&
          other.previewUrl == this.previewUrl &&
          other.previewWidth == this.previewWidth &&
          other.previewHeight == this.previewHeight &&
          other.source == this.source &&
          other.savedAt == this.savedAt);
}

class FavoriteGifsCompanion extends UpdateCompanion<FavoriteGifRow> {
  final Value<String> url;
  final Value<String> previewUrl;
  final Value<int?> previewWidth;
  final Value<int?> previewHeight;
  final Value<String> source;
  final Value<int> savedAt;
  final Value<int> rowid;
  const FavoriteGifsCompanion({
    this.url = const Value.absent(),
    this.previewUrl = const Value.absent(),
    this.previewWidth = const Value.absent(),
    this.previewHeight = const Value.absent(),
    this.source = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteGifsCompanion.insert({
    required String url,
    required String previewUrl,
    this.previewWidth = const Value.absent(),
    this.previewHeight = const Value.absent(),
    required String source,
    required int savedAt,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       previewUrl = Value(previewUrl),
       source = Value(source),
       savedAt = Value(savedAt);
  static Insertable<FavoriteGifRow> custom({
    Expression<String>? url,
    Expression<String>? previewUrl,
    Expression<int>? previewWidth,
    Expression<int>? previewHeight,
    Expression<String>? source,
    Expression<int>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (previewUrl != null) 'preview_url': previewUrl,
      if (previewWidth != null) 'preview_width': previewWidth,
      if (previewHeight != null) 'preview_height': previewHeight,
      if (source != null) 'source': source,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteGifsCompanion copyWith({
    Value<String>? url,
    Value<String>? previewUrl,
    Value<int?>? previewWidth,
    Value<int?>? previewHeight,
    Value<String>? source,
    Value<int>? savedAt,
    Value<int>? rowid,
  }) {
    return FavoriteGifsCompanion(
      url: url ?? this.url,
      previewUrl: previewUrl ?? this.previewUrl,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
      source: source ?? this.source,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (previewUrl.present) {
      map['preview_url'] = Variable<String>(previewUrl.value);
    }
    if (previewWidth.present) {
      map['preview_width'] = Variable<int>(previewWidth.value);
    }
    if (previewHeight.present) {
      map['preview_height'] = Variable<int>(previewHeight.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteGifsCompanion(')
          ..write('url: $url, ')
          ..write('previewUrl: $previewUrl, ')
          ..write('previewWidth: $previewWidth, ')
          ..write('previewHeight: $previewHeight, ')
          ..write('source: $source, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxesTable extends Inboxes with TableInfo<$InboxesTable, InboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientIdMeta = const VerificationMeta(
    'recipientId',
  );
  @override
  late final GeneratedColumn<String> recipientId = GeneratedColumn<String>(
    'recipient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    channelId,
    recipientId,
    lastSeen,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inboxes';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('recipient_id')) {
      context.handle(
        _recipientIdMeta,
        recipientId.isAcceptableOrUnknown(
          data['recipient_id']!,
          _recipientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipientIdMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
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
  Set<GeneratedColumn> get $primaryKey => {channelId};
  @override
  InboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      recipientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_id'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InboxesTable createAlias(String alias) {
    return $InboxesTable(attachedDatabase, alias);
  }
}

class InboxRow extends DataClass implements Insertable<InboxRow> {
  final String id;
  final String channelId;
  final String recipientId;
  final int? lastSeen;
  final int createdAt;
  const InboxRow({
    required this.id,
    required this.channelId,
    required this.recipientId,
    this.lastSeen,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['channel_id'] = Variable<String>(channelId);
    map['recipient_id'] = Variable<String>(recipientId);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<int>(lastSeen);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  InboxesCompanion toCompanion(bool nullToAbsent) {
    return InboxesCompanion(
      id: Value(id),
      channelId: Value(channelId),
      recipientId: Value(recipientId),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      createdAt: Value(createdAt),
    );
  }

  factory InboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxRow(
      id: serializer.fromJson<String>(json['id']),
      channelId: serializer.fromJson<String>(json['channelId']),
      recipientId: serializer.fromJson<String>(json['recipientId']),
      lastSeen: serializer.fromJson<int?>(json['lastSeen']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'channelId': serializer.toJson<String>(channelId),
      'recipientId': serializer.toJson<String>(recipientId),
      'lastSeen': serializer.toJson<int?>(lastSeen),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  InboxRow copyWith({
    String? id,
    String? channelId,
    String? recipientId,
    Value<int?> lastSeen = const Value.absent(),
    int? createdAt,
  }) => InboxRow(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    recipientId: recipientId ?? this.recipientId,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    createdAt: createdAt ?? this.createdAt,
  );
  InboxRow copyWithCompanion(InboxesCompanion data) {
    return InboxRow(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      recipientId: data.recipientId.present
          ? data.recipientId.value
          : this.recipientId,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxRow(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('recipientId: $recipientId, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, channelId, recipientId, lastSeen, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxRow &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.recipientId == this.recipientId &&
          other.lastSeen == this.lastSeen &&
          other.createdAt == this.createdAt);
}

class InboxesCompanion extends UpdateCompanion<InboxRow> {
  final Value<String> id;
  final Value<String> channelId;
  final Value<String> recipientId;
  final Value<int?> lastSeen;
  final Value<int> createdAt;
  final Value<int> rowid;
  const InboxesCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.recipientId = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxesCompanion.insert({
    required String id,
    required String channelId,
    required String recipientId,
    this.lastSeen = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       channelId = Value(channelId),
       recipientId = Value(recipientId),
       createdAt = Value(createdAt);
  static Insertable<InboxRow> custom({
    Expression<String>? id,
    Expression<String>? channelId,
    Expression<String>? recipientId,
    Expression<int>? lastSeen,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (recipientId != null) 'recipient_id': recipientId,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxesCompanion copyWith({
    Value<String>? id,
    Value<String>? channelId,
    Value<String>? recipientId,
    Value<int?>? lastSeen,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return InboxesCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      recipientId: recipientId ?? this.recipientId,
      lastSeen: lastSeen ?? this.lastSeen,
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
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (recipientId.present) {
      map['recipient_id'] = Variable<String>(recipientId.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxesCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('recipientId: $recipientId, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderedServerIdsTable extends OrderedServerIds
    with TableInfo<$OrderedServerIdsTable, OrderedServerIdRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderedServerIdsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ordered_server_ids';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderedServerIdRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderedServerIdRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderedServerIdRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $OrderedServerIdsTable createAlias(String alias) {
    return $OrderedServerIdsTable(attachedDatabase, alias);
  }
}

class OrderedServerIdRow extends DataClass
    implements Insertable<OrderedServerIdRow> {
  final String id;
  final int position;
  const OrderedServerIdRow({required this.id, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['position'] = Variable<int>(position);
    return map;
  }

  OrderedServerIdsCompanion toCompanion(bool nullToAbsent) {
    return OrderedServerIdsCompanion(id: Value(id), position: Value(position));
  }

  factory OrderedServerIdRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderedServerIdRow(
      id: serializer.fromJson<String>(json['id']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'position': serializer.toJson<int>(position),
    };
  }

  OrderedServerIdRow copyWith({String? id, int? position}) =>
      OrderedServerIdRow(
        id: id ?? this.id,
        position: position ?? this.position,
      );
  OrderedServerIdRow copyWithCompanion(OrderedServerIdsCompanion data) {
    return OrderedServerIdRow(
      id: data.id.present ? data.id.value : this.id,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderedServerIdRow(')
          ..write('id: $id, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderedServerIdRow &&
          other.id == this.id &&
          other.position == this.position);
}

class OrderedServerIdsCompanion extends UpdateCompanion<OrderedServerIdRow> {
  final Value<String> id;
  final Value<int> position;
  final Value<int> rowid;
  const OrderedServerIdsCompanion({
    this.id = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderedServerIdsCompanion.insert({
    required String id,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       position = Value(position);
  static Insertable<OrderedServerIdRow> custom({
    Expression<String>? id,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderedServerIdsCompanion copyWith({
    Value<String>? id,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return OrderedServerIdsCompanion(
      id: id ?? this.id,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderedServerIdsCompanion(')
          ..write('id: $id, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentEmojisTable extends RecentEmojis
    with TableInfo<$RecentEmojisTable, RecentEmojiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentEmojisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customMeta = const VerificationMeta('custom');
  @override
  late final GeneratedColumn<bool> custom = GeneratedColumn<bool>(
    'custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<int> usedAt = GeneratedColumn<int>(
    'used_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [emoji, custom, usedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_emojis';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentEmojiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('custom')) {
      context.handle(
        _customMeta,
        custom.isAcceptableOrUnknown(data['custom']!, _customMeta),
      );
    }
    if (data.containsKey('used_at')) {
      context.handle(
        _usedAtMeta,
        usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_usedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {emoji};
  @override
  RecentEmojiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentEmojiRow(
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      custom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}custom'],
      )!,
      usedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used_at'],
      )!,
    );
  }

  @override
  $RecentEmojisTable createAlias(String alias) {
    return $RecentEmojisTable(attachedDatabase, alias);
  }
}

class RecentEmojiRow extends DataClass implements Insertable<RecentEmojiRow> {
  final String emoji;
  final bool custom;
  final int usedAt;
  const RecentEmojiRow({
    required this.emoji,
    required this.custom,
    required this.usedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['emoji'] = Variable<String>(emoji);
    map['custom'] = Variable<bool>(custom);
    map['used_at'] = Variable<int>(usedAt);
    return map;
  }

  RecentEmojisCompanion toCompanion(bool nullToAbsent) {
    return RecentEmojisCompanion(
      emoji: Value(emoji),
      custom: Value(custom),
      usedAt: Value(usedAt),
    );
  }

  factory RecentEmojiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentEmojiRow(
      emoji: serializer.fromJson<String>(json['emoji']),
      custom: serializer.fromJson<bool>(json['custom']),
      usedAt: serializer.fromJson<int>(json['usedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'emoji': serializer.toJson<String>(emoji),
      'custom': serializer.toJson<bool>(custom),
      'usedAt': serializer.toJson<int>(usedAt),
    };
  }

  RecentEmojiRow copyWith({String? emoji, bool? custom, int? usedAt}) =>
      RecentEmojiRow(
        emoji: emoji ?? this.emoji,
        custom: custom ?? this.custom,
        usedAt: usedAt ?? this.usedAt,
      );
  RecentEmojiRow copyWithCompanion(RecentEmojisCompanion data) {
    return RecentEmojiRow(
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      custom: data.custom.present ? data.custom.value : this.custom,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentEmojiRow(')
          ..write('emoji: $emoji, ')
          ..write('custom: $custom, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(emoji, custom, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentEmojiRow &&
          other.emoji == this.emoji &&
          other.custom == this.custom &&
          other.usedAt == this.usedAt);
}

class RecentEmojisCompanion extends UpdateCompanion<RecentEmojiRow> {
  final Value<String> emoji;
  final Value<bool> custom;
  final Value<int> usedAt;
  final Value<int> rowid;
  const RecentEmojisCompanion({
    this.emoji = const Value.absent(),
    this.custom = const Value.absent(),
    this.usedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentEmojisCompanion.insert({
    required String emoji,
    this.custom = const Value.absent(),
    required int usedAt,
    this.rowid = const Value.absent(),
  }) : emoji = Value(emoji),
       usedAt = Value(usedAt);
  static Insertable<RecentEmojiRow> createCustom({
    Expression<String>? emoji,
    Expression<bool>? custom,
    Expression<int>? usedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (emoji != null) 'emoji': emoji,
      if (custom != null) 'custom': custom,
      if (usedAt != null) 'used_at': usedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentEmojisCompanion copyWith({
    Value<String>? emoji,
    Value<bool>? custom,
    Value<int>? usedAt,
    Value<int>? rowid,
  }) {
    return RecentEmojisCompanion(
      emoji: emoji ?? this.emoji,
      custom: custom ?? this.custom,
      usedAt: usedAt ?? this.usedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (custom.present) {
      map['custom'] = Variable<bool>(custom.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<int>(usedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentEmojisCompanion(')
          ..write('emoji: $emoji, ')
          ..write('custom: $custom, ')
          ..write('usedAt: $usedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServerMembersTable extends ServerMembers
    with TableInfo<$ServerMembersTable, ServerMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleIdsMeta = const VerificationMeta(
    'roleIds',
  );
  @override
  late final GeneratedColumn<String> roleIds = GeneratedColumn<String>(
    'role_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    userId,
    nickname,
    roleIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('role_ids')) {
      context.handle(
        _roleIdsMeta,
        roleIds.isAcceptableOrUnknown(data['role_ids']!, _roleIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  ServerMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerMemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      roleIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_ids'],
      )!,
    );
  }

  @override
  $ServerMembersTable createAlias(String alias) {
    return $ServerMembersTable(attachedDatabase, alias);
  }
}

class ServerMemberRow extends DataClass implements Insertable<ServerMemberRow> {
  final String id;
  final String serverId;
  final String userId;
  final String? nickname;
  final String roleIds;
  const ServerMemberRow({
    required this.id,
    required this.serverId,
    required this.userId,
    this.nickname,
    required this.roleIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['role_ids'] = Variable<String>(roleIds);
    return map;
  }

  ServerMembersCompanion toCompanion(bool nullToAbsent) {
    return ServerMembersCompanion(
      id: Value(id),
      serverId: Value(serverId),
      userId: Value(userId),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      roleIds: Value(roleIds),
    );
  }

  factory ServerMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerMemberRow(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      userId: serializer.fromJson<String>(json['userId']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      roleIds: serializer.fromJson<String>(json['roleIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'userId': serializer.toJson<String>(userId),
      'nickname': serializer.toJson<String?>(nickname),
      'roleIds': serializer.toJson<String>(roleIds),
    };
  }

  ServerMemberRow copyWith({
    String? id,
    String? serverId,
    String? userId,
    Value<String?> nickname = const Value.absent(),
    String? roleIds,
  }) => ServerMemberRow(
    id: id ?? this.id,
    serverId: serverId ?? this.serverId,
    userId: userId ?? this.userId,
    nickname: nickname.present ? nickname.value : this.nickname,
    roleIds: roleIds ?? this.roleIds,
  );
  ServerMemberRow copyWithCompanion(ServerMembersCompanion data) {
    return ServerMemberRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      userId: data.userId.present ? data.userId.value : this.userId,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      roleIds: data.roleIds.present ? data.roleIds.value : this.roleIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerMemberRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('roleIds: $roleIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, userId, nickname, roleIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerMemberRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.userId == this.userId &&
          other.nickname == this.nickname &&
          other.roleIds == this.roleIds);
}

class ServerMembersCompanion extends UpdateCompanion<ServerMemberRow> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String> userId;
  final Value<String?> nickname;
  final Value<String> roleIds;
  final Value<int> rowid;
  const ServerMembersCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.roleIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerMembersCompanion.insert({
    required String id,
    required String serverId,
    required String userId,
    this.nickname = const Value.absent(),
    required String roleIds,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serverId = Value(serverId),
       userId = Value(userId),
       roleIds = Value(roleIds);
  static Insertable<ServerMemberRow> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? userId,
    Expression<String>? nickname,
    Expression<String>? roleIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (roleIds != null) 'role_ids': roleIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? serverId,
    Value<String>? userId,
    Value<String?>? nickname,
    Value<String>? roleIds,
    Value<int>? rowid,
  }) {
    return ServerMembersCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      roleIds: roleIds ?? this.roleIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (roleIds.present) {
      map['role_ids'] = Variable<String>(roleIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerMembersCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('roleIds: $roleIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServerRolesTable extends ServerRoles
    with TableInfo<$ServerRolesTable, ServerRoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
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
  static const VerificationMeta _hideRoleMeta = const VerificationMeta(
    'hideRole',
  );
  @override
  late final GeneratedColumn<bool> hideRole = GeneratedColumn<bool>(
    'hide_role',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_role" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<int> permissions = GeneratedColumn<int>(
    'permissions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    name,
    hideRole,
    hexColor,
    permissions,
    order,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerRoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hide_role')) {
      context.handle(
        _hideRoleMeta,
        hideRole.isAcceptableOrUnknown(data['hide_role']!, _hideRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_hideRoleMeta);
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    }
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionsMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerRoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerRoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hideRole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_role'],
      )!,
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      ),
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}permissions'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $ServerRolesTable createAlias(String alias) {
    return $ServerRolesTable(attachedDatabase, alias);
  }
}

class ServerRoleRow extends DataClass implements Insertable<ServerRoleRow> {
  final String id;
  final String serverId;
  final String name;
  final bool hideRole;
  final String? hexColor;
  final int permissions;
  final int order;
  final String? icon;
  const ServerRoleRow({
    required this.id,
    required this.serverId,
    required this.name,
    required this.hideRole,
    this.hexColor,
    required this.permissions,
    required this.order,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    map['name'] = Variable<String>(name);
    map['hide_role'] = Variable<bool>(hideRole);
    if (!nullToAbsent || hexColor != null) {
      map['hex_color'] = Variable<String>(hexColor);
    }
    map['permissions'] = Variable<int>(permissions);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  ServerRolesCompanion toCompanion(bool nullToAbsent) {
    return ServerRolesCompanion(
      id: Value(id),
      serverId: Value(serverId),
      name: Value(name),
      hideRole: Value(hideRole),
      hexColor: hexColor == null && nullToAbsent
          ? const Value.absent()
          : Value(hexColor),
      permissions: Value(permissions),
      order: Value(order),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory ServerRoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerRoleRow(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      hideRole: serializer.fromJson<bool>(json['hideRole']),
      hexColor: serializer.fromJson<String?>(json['hexColor']),
      permissions: serializer.fromJson<int>(json['permissions']),
      order: serializer.fromJson<int>(json['order']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'name': serializer.toJson<String>(name),
      'hideRole': serializer.toJson<bool>(hideRole),
      'hexColor': serializer.toJson<String?>(hexColor),
      'permissions': serializer.toJson<int>(permissions),
      'order': serializer.toJson<int>(order),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  ServerRoleRow copyWith({
    String? id,
    String? serverId,
    String? name,
    bool? hideRole,
    Value<String?> hexColor = const Value.absent(),
    int? permissions,
    int? order,
    Value<String?> icon = const Value.absent(),
  }) => ServerRoleRow(
    id: id ?? this.id,
    serverId: serverId ?? this.serverId,
    name: name ?? this.name,
    hideRole: hideRole ?? this.hideRole,
    hexColor: hexColor.present ? hexColor.value : this.hexColor,
    permissions: permissions ?? this.permissions,
    order: order ?? this.order,
    icon: icon.present ? icon.value : this.icon,
  );
  ServerRoleRow copyWithCompanion(ServerRolesCompanion data) {
    return ServerRoleRow(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      hideRole: data.hideRole.present ? data.hideRole.value : this.hideRole,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
      order: data.order.present ? data.order.value : this.order,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerRoleRow(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('hideRole: $hideRole, ')
          ..write('hexColor: $hexColor, ')
          ..write('permissions: $permissions, ')
          ..write('order: $order, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    name,
    hideRole,
    hexColor,
    permissions,
    order,
    icon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerRoleRow &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.hideRole == this.hideRole &&
          other.hexColor == this.hexColor &&
          other.permissions == this.permissions &&
          other.order == this.order &&
          other.icon == this.icon);
}

class ServerRolesCompanion extends UpdateCompanion<ServerRoleRow> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String> name;
  final Value<bool> hideRole;
  final Value<String?> hexColor;
  final Value<int> permissions;
  final Value<int> order;
  final Value<String?> icon;
  final Value<int> rowid;
  const ServerRolesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.hideRole = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.permissions = const Value.absent(),
    this.order = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerRolesCompanion.insert({
    required String id,
    required String serverId,
    required String name,
    required bool hideRole,
    this.hexColor = const Value.absent(),
    required int permissions,
    required int order,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serverId = Value(serverId),
       name = Value(name),
       hideRole = Value(hideRole),
       permissions = Value(permissions),
       order = Value(order);
  static Insertable<ServerRoleRow> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<bool>? hideRole,
    Expression<String>? hexColor,
    Expression<int>? permissions,
    Expression<int>? order,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (hideRole != null) 'hide_role': hideRole,
      if (hexColor != null) 'hex_color': hexColor,
      if (permissions != null) 'permissions': permissions,
      if (order != null) 'order': order,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerRolesCompanion copyWith({
    Value<String>? id,
    Value<String>? serverId,
    Value<String>? name,
    Value<bool>? hideRole,
    Value<String?>? hexColor,
    Value<int>? permissions,
    Value<int>? order,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return ServerRolesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      hideRole: hideRole ?? this.hideRole,
      hexColor: hexColor ?? this.hexColor,
      permissions: permissions ?? this.permissions,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hideRole.present) {
      map['hide_role'] = Variable<bool>(hideRole.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<int>(permissions.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerRolesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('hideRole: $hideRole, ')
          ..write('hexColor: $hexColor, ')
          ..write('permissions: $permissions, ')
          ..write('order: $order, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServersTable extends Servers with TableInfo<$ServersTable, ServerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultChannelIdMeta = const VerificationMeta(
    'defaultChannelId',
  );
  @override
  late final GeneratedColumn<String> defaultChannelId = GeneratedColumn<String>(
    'default_channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultRoleIdMeta = const VerificationMeta(
    'defaultRoleId',
  );
  @override
  late final GeneratedColumn<String> defaultRoleId = GeneratedColumn<String>(
    'default_role_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByIdMeta = const VerificationMeta(
    'createdById',
  );
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
    'created_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatar,
    hexColor,
    defaultChannelId,
    defaultRoleId,
    createdById,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    } else if (isInserting) {
      context.missing(_hexColorMeta);
    }
    if (data.containsKey('default_channel_id')) {
      context.handle(
        _defaultChannelIdMeta,
        defaultChannelId.isAcceptableOrUnknown(
          data['default_channel_id']!,
          _defaultChannelIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultChannelIdMeta);
    }
    if (data.containsKey('default_role_id')) {
      context.handle(
        _defaultRoleIdMeta,
        defaultRoleId.isAcceptableOrUnknown(
          data['default_role_id']!,
          _defaultRoleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultRoleIdMeta);
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
        _createdByIdMeta,
        createdById.isAcceptableOrUnknown(
          data['created_by_id']!,
          _createdByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      )!,
      defaultChannelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_channel_id'],
      )!,
      defaultRoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_role_id'],
      )!,
      createdById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_id'],
      )!,
    );
  }

  @override
  $ServersTable createAlias(String alias) {
    return $ServersTable(attachedDatabase, alias);
  }
}

class ServerRow extends DataClass implements Insertable<ServerRow> {
  final String id;
  final String name;
  final String? avatar;
  final String hexColor;
  final String defaultChannelId;
  final String defaultRoleId;
  final String createdById;
  const ServerRow({
    required this.id,
    required this.name,
    this.avatar,
    required this.hexColor,
    required this.defaultChannelId,
    required this.defaultRoleId,
    required this.createdById,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['hex_color'] = Variable<String>(hexColor);
    map['default_channel_id'] = Variable<String>(defaultChannelId);
    map['default_role_id'] = Variable<String>(defaultRoleId);
    map['created_by_id'] = Variable<String>(createdById);
    return map;
  }

  ServersCompanion toCompanion(bool nullToAbsent) {
    return ServersCompanion(
      id: Value(id),
      name: Value(name),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      hexColor: Value(hexColor),
      defaultChannelId: Value(defaultChannelId),
      defaultRoleId: Value(defaultRoleId),
      createdById: Value(createdById),
    );
  }

  factory ServerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      hexColor: serializer.fromJson<String>(json['hexColor']),
      defaultChannelId: serializer.fromJson<String>(json['defaultChannelId']),
      defaultRoleId: serializer.fromJson<String>(json['defaultRoleId']),
      createdById: serializer.fromJson<String>(json['createdById']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'hexColor': serializer.toJson<String>(hexColor),
      'defaultChannelId': serializer.toJson<String>(defaultChannelId),
      'defaultRoleId': serializer.toJson<String>(defaultRoleId),
      'createdById': serializer.toJson<String>(createdById),
    };
  }

  ServerRow copyWith({
    String? id,
    String? name,
    Value<String?> avatar = const Value.absent(),
    String? hexColor,
    String? defaultChannelId,
    String? defaultRoleId,
    String? createdById,
  }) => ServerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    avatar: avatar.present ? avatar.value : this.avatar,
    hexColor: hexColor ?? this.hexColor,
    defaultChannelId: defaultChannelId ?? this.defaultChannelId,
    defaultRoleId: defaultRoleId ?? this.defaultRoleId,
    createdById: createdById ?? this.createdById,
  );
  ServerRow copyWithCompanion(ServersCompanion data) {
    return ServerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      defaultChannelId: data.defaultChannelId.present
          ? data.defaultChannelId.value
          : this.defaultChannelId,
      defaultRoleId: data.defaultRoleId.present
          ? data.defaultRoleId.value
          : this.defaultRoleId,
      createdById: data.createdById.present
          ? data.createdById.value
          : this.createdById,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('hexColor: $hexColor, ')
          ..write('defaultChannelId: $defaultChannelId, ')
          ..write('defaultRoleId: $defaultRoleId, ')
          ..write('createdById: $createdById')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatar,
    hexColor,
    defaultChannelId,
    defaultRoleId,
    createdById,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.hexColor == this.hexColor &&
          other.defaultChannelId == this.defaultChannelId &&
          other.defaultRoleId == this.defaultRoleId &&
          other.createdById == this.createdById);
}

class ServersCompanion extends UpdateCompanion<ServerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String> hexColor;
  final Value<String> defaultChannelId;
  final Value<String> defaultRoleId;
  final Value<String> createdById;
  final Value<int> rowid;
  const ServersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.defaultChannelId = const Value.absent(),
    this.defaultRoleId = const Value.absent(),
    this.createdById = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServersCompanion.insert({
    required String id,
    required String name,
    this.avatar = const Value.absent(),
    required String hexColor,
    required String defaultChannelId,
    required String defaultRoleId,
    required String createdById,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       hexColor = Value(hexColor),
       defaultChannelId = Value(defaultChannelId),
       defaultRoleId = Value(defaultRoleId),
       createdById = Value(createdById);
  static Insertable<ServerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? hexColor,
    Expression<String>? defaultChannelId,
    Expression<String>? defaultRoleId,
    Expression<String>? createdById,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (hexColor != null) 'hex_color': hexColor,
      if (defaultChannelId != null) 'default_channel_id': defaultChannelId,
      if (defaultRoleId != null) 'default_role_id': defaultRoleId,
      if (createdById != null) 'created_by_id': createdById,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? avatar,
    Value<String>? hexColor,
    Value<String>? defaultChannelId,
    Value<String>? defaultRoleId,
    Value<String>? createdById,
    Value<int>? rowid,
  }) {
    return ServersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      hexColor: hexColor ?? this.hexColor,
      defaultChannelId: defaultChannelId ?? this.defaultChannelId,
      defaultRoleId: defaultRoleId ?? this.defaultRoleId,
      createdById: createdById ?? this.createdById,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (defaultChannelId.present) {
      map['default_channel_id'] = Variable<String>(defaultChannelId.value);
    }
    if (defaultRoleId.present) {
      map['default_role_id'] = Variable<String>(defaultRoleId.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('hexColor: $hexColor, ')
          ..write('defaultChannelId: $defaultChannelId, ')
          ..write('defaultRoleId: $defaultRoleId, ')
          ..write('createdById: $createdById, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, hexColor, avatar];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    } else if (isInserting) {
      context.missing(_hexColorMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String username;
  final String hexColor;
  final String? avatar;
  const UserRow({
    required this.id,
    required this.username,
    required this.hexColor,
    this.avatar,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['hex_color'] = Variable<String>(hexColor);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      hexColor: Value(hexColor),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      hexColor: serializer.fromJson<String>(json['hexColor']),
      avatar: serializer.fromJson<String?>(json['avatar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'hexColor': serializer.toJson<String>(hexColor),
      'avatar': serializer.toJson<String?>(avatar),
    };
  }

  UserRow copyWith({
    String? id,
    String? username,
    String? hexColor,
    Value<String?> avatar = const Value.absent(),
  }) => UserRow(
    id: id ?? this.id,
    username: username ?? this.username,
    hexColor: hexColor ?? this.hexColor,
    avatar: avatar.present ? avatar.value : this.avatar,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('hexColor: $hexColor, ')
          ..write('avatar: $avatar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, hexColor, avatar);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.hexColor == this.hexColor &&
          other.avatar == this.avatar);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> hexColor;
  final Value<String?> avatar;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.avatar = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String hexColor,
    this.avatar = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       hexColor = Value(hexColor);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? hexColor,
    Expression<String>? avatar,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (hexColor != null) 'hex_color': hexColor,
      if (avatar != null) 'avatar': avatar,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? hexColor,
    Value<String?>? avatar,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      hexColor: hexColor ?? this.hexColor,
      avatar: avatar ?? this.avatar,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
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
          ..write('username: $username, ')
          ..write('hexColor: $hexColor, ')
          ..write('avatar: $avatar, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NeriDatabase extends GeneratedDatabase {
  _$NeriDatabase(QueryExecutor e) : super(e);
  $NeriDatabaseManager get managers => $NeriDatabaseManager(this);
  late final $AnnouncementsTable announcements = $AnnouncementsTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $DismissedAnnouncementsTable dismissedAnnouncements =
      $DismissedAnnouncementsTable(this);
  late final $FavoriteGifsTable favoriteGifs = $FavoriteGifsTable(this);
  late final $InboxesTable inboxes = $InboxesTable(this);
  late final $OrderedServerIdsTable orderedServerIds = $OrderedServerIdsTable(
    this,
  );
  late final $RecentEmojisTable recentEmojis = $RecentEmojisTable(this);
  late final $ServerMembersTable serverMembers = $ServerMembersTable(this);
  late final $ServerRolesTable serverRoles = $ServerRolesTable(this);
  late final $ServersTable servers = $ServersTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    announcements,
    channels,
    dismissedAnnouncements,
    favoriteGifs,
    inboxes,
    orderedServerIds,
    recentEmojis,
    serverMembers,
    serverRoles,
    servers,
    users,
  ];
}

typedef $$AnnouncementsTableCreateCompanionBuilder =
    AnnouncementsCompanion Function({
      required String id,
      required String payload,
      required int position,
      Value<int> rowid,
    });
typedef $$AnnouncementsTableUpdateCompanionBuilder =
    AnnouncementsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> position,
      Value<int> rowid,
    });

class $$AnnouncementsTableFilterComposer
    extends Composer<_$NeriDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnnouncementsTableOrderingComposer
    extends Composer<_$NeriDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnnouncementsTableAnnotationComposer
    extends Composer<_$NeriDatabase, $AnnouncementsTable> {
  $$AnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$AnnouncementsTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $AnnouncementsTable,
          AnnouncementRow,
          $$AnnouncementsTableFilterComposer,
          $$AnnouncementsTableOrderingComposer,
          $$AnnouncementsTableAnnotationComposer,
          $$AnnouncementsTableCreateCompanionBuilder,
          $$AnnouncementsTableUpdateCompanionBuilder,
          (
            AnnouncementRow,
            BaseReferences<
              _$NeriDatabase,
              $AnnouncementsTable,
              AnnouncementRow
            >,
          ),
          AnnouncementRow,
          PrefetchHooks Function()
        > {
  $$AnnouncementsTableTableManager(_$NeriDatabase db, $AnnouncementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnouncementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnouncementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnouncementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnnouncementsCompanion(
                id: id,
                payload: payload,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => AnnouncementsCompanion.insert(
                id: id,
                payload: payload,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnnouncementsTable, AnnouncementRow>(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $AnnouncementsTable,
                    AnnouncementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnnouncementsTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $AnnouncementsTable,
      AnnouncementRow,
      $$AnnouncementsTableFilterComposer,
      $$AnnouncementsTableOrderingComposer,
      $$AnnouncementsTableAnnotationComposer,
      $$AnnouncementsTableCreateCompanionBuilder,
      $$AnnouncementsTableUpdateCompanionBuilder,
      (
        AnnouncementRow,
        BaseReferences<_$NeriDatabase, $AnnouncementsTable, AnnouncementRow>,
      ),
      AnnouncementRow,
      PrefetchHooks Function()
    >;
typedef $$ChannelsTableCreateCompanionBuilder =
    ChannelsCompanion Function({
      required String id,
      required int type,
      Value<String?> name,
      Value<int?> order,
      Value<String?> serverId,
      Value<String?> icon,
      Value<String?> categoryId,
      Value<int?> lastMessagedAt,
      Value<String?> permissions,
      Value<int> rowid,
    });
typedef $$ChannelsTableUpdateCompanionBuilder =
    ChannelsCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<String?> name,
      Value<int?> order,
      Value<String?> serverId,
      Value<String?> icon,
      Value<String?> categoryId,
      Value<int?> lastMessagedAt,
      Value<String?> permissions,
      Value<int> rowid,
    });

class $$ChannelsTableFilterComposer
    extends Composer<_$NeriDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
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

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessagedAt => $composableBuilder(
    column: $table.lastMessagedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$NeriDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessagedAt => $composableBuilder(
    column: $table.lastMessagedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$NeriDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessagedAt => $composableBuilder(
    column: $table.lastMessagedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $ChannelsTable,
          ChannelRow,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (
            ChannelRow,
            BaseReferences<_$NeriDatabase, $ChannelsTable, ChannelRow>,
          ),
          ChannelRow,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$NeriDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> order = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> lastMessagedAt = const Value.absent(),
                Value<String?> permissions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion(
                id: id,
                type: type,
                name: name,
                order: order,
                serverId: serverId,
                icon: icon,
                categoryId: categoryId,
                lastMessagedAt: lastMessagedAt,
                permissions: permissions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int type,
                Value<String?> name = const Value.absent(),
                Value<int?> order = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> lastMessagedAt = const Value.absent(),
                Value<String?> permissions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion.insert(
                id: id,
                type: type,
                name: name,
                order: order,
                serverId: serverId,
                icon: icon,
                categoryId: categoryId,
                lastMessagedAt: lastMessagedAt,
                permissions: permissions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTable, ChannelRow>(table),
                  BaseReferences<_$NeriDatabase, $ChannelsTable, ChannelRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $ChannelsTable,
      ChannelRow,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (ChannelRow, BaseReferences<_$NeriDatabase, $ChannelsTable, ChannelRow>),
      ChannelRow,
      PrefetchHooks Function()
    >;
typedef $$DismissedAnnouncementsTableCreateCompanionBuilder =
    DismissedAnnouncementsCompanion Function({
      required String id,
      Value<int> rowid,
    });
typedef $$DismissedAnnouncementsTableUpdateCompanionBuilder =
    DismissedAnnouncementsCompanion Function({
      Value<String> id,
      Value<int> rowid,
    });

class $$DismissedAnnouncementsTableFilterComposer
    extends Composer<_$NeriDatabase, $DismissedAnnouncementsTable> {
  $$DismissedAnnouncementsTableFilterComposer({
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
}

class $$DismissedAnnouncementsTableOrderingComposer
    extends Composer<_$NeriDatabase, $DismissedAnnouncementsTable> {
  $$DismissedAnnouncementsTableOrderingComposer({
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
}

class $$DismissedAnnouncementsTableAnnotationComposer
    extends Composer<_$NeriDatabase, $DismissedAnnouncementsTable> {
  $$DismissedAnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$DismissedAnnouncementsTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $DismissedAnnouncementsTable,
          DismissedAnnouncementRow,
          $$DismissedAnnouncementsTableFilterComposer,
          $$DismissedAnnouncementsTableOrderingComposer,
          $$DismissedAnnouncementsTableAnnotationComposer,
          $$DismissedAnnouncementsTableCreateCompanionBuilder,
          $$DismissedAnnouncementsTableUpdateCompanionBuilder,
          (
            DismissedAnnouncementRow,
            BaseReferences<
              _$NeriDatabase,
              $DismissedAnnouncementsTable,
              DismissedAnnouncementRow
            >,
          ),
          DismissedAnnouncementRow,
          PrefetchHooks Function()
        > {
  $$DismissedAnnouncementsTableTableManager(
    _$NeriDatabase db,
    $DismissedAnnouncementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DismissedAnnouncementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DismissedAnnouncementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DismissedAnnouncementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DismissedAnnouncementsCompanion(id: id, rowid: rowid),
          createCompanionCallback:
              ({required String id, Value<int> rowid = const Value.absent()}) =>
                  DismissedAnnouncementsCompanion.insert(id: id, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DismissedAnnouncementsTable,
                    DismissedAnnouncementRow
                  >(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $DismissedAnnouncementsTable,
                    DismissedAnnouncementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DismissedAnnouncementsTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $DismissedAnnouncementsTable,
      DismissedAnnouncementRow,
      $$DismissedAnnouncementsTableFilterComposer,
      $$DismissedAnnouncementsTableOrderingComposer,
      $$DismissedAnnouncementsTableAnnotationComposer,
      $$DismissedAnnouncementsTableCreateCompanionBuilder,
      $$DismissedAnnouncementsTableUpdateCompanionBuilder,
      (
        DismissedAnnouncementRow,
        BaseReferences<
          _$NeriDatabase,
          $DismissedAnnouncementsTable,
          DismissedAnnouncementRow
        >,
      ),
      DismissedAnnouncementRow,
      PrefetchHooks Function()
    >;
typedef $$FavoriteGifsTableCreateCompanionBuilder =
    FavoriteGifsCompanion Function({
      required String url,
      required String previewUrl,
      Value<int?> previewWidth,
      Value<int?> previewHeight,
      required String source,
      required int savedAt,
      Value<int> rowid,
    });
typedef $$FavoriteGifsTableUpdateCompanionBuilder =
    FavoriteGifsCompanion Function({
      Value<String> url,
      Value<String> previewUrl,
      Value<int?> previewWidth,
      Value<int?> previewHeight,
      Value<String> source,
      Value<int> savedAt,
      Value<int> rowid,
    });

class $$FavoriteGifsTableFilterComposer
    extends Composer<_$NeriDatabase, $FavoriteGifsTable> {
  $$FavoriteGifsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previewWidth => $composableBuilder(
    column: $table.previewWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previewHeight => $composableBuilder(
    column: $table.previewHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteGifsTableOrderingComposer
    extends Composer<_$NeriDatabase, $FavoriteGifsTable> {
  $$FavoriteGifsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previewWidth => $composableBuilder(
    column: $table.previewWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previewHeight => $composableBuilder(
    column: $table.previewHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteGifsTableAnnotationComposer
    extends Composer<_$NeriDatabase, $FavoriteGifsTable> {
  $$FavoriteGifsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get previewUrl => $composableBuilder(
    column: $table.previewUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previewWidth => $composableBuilder(
    column: $table.previewWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previewHeight => $composableBuilder(
    column: $table.previewHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$FavoriteGifsTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $FavoriteGifsTable,
          FavoriteGifRow,
          $$FavoriteGifsTableFilterComposer,
          $$FavoriteGifsTableOrderingComposer,
          $$FavoriteGifsTableAnnotationComposer,
          $$FavoriteGifsTableCreateCompanionBuilder,
          $$FavoriteGifsTableUpdateCompanionBuilder,
          (
            FavoriteGifRow,
            BaseReferences<_$NeriDatabase, $FavoriteGifsTable, FavoriteGifRow>,
          ),
          FavoriteGifRow,
          PrefetchHooks Function()
        > {
  $$FavoriteGifsTableTableManager(_$NeriDatabase db, $FavoriteGifsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteGifsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteGifsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteGifsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> previewUrl = const Value.absent(),
                Value<int?> previewWidth = const Value.absent(),
                Value<int?> previewHeight = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteGifsCompanion(
                url: url,
                previewUrl: previewUrl,
                previewWidth: previewWidth,
                previewHeight: previewHeight,
                source: source,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required String previewUrl,
                Value<int?> previewWidth = const Value.absent(),
                Value<int?> previewHeight = const Value.absent(),
                required String source,
                required int savedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteGifsCompanion.insert(
                url: url,
                previewUrl: previewUrl,
                previewWidth: previewWidth,
                previewHeight: previewHeight,
                source: source,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoriteGifsTable, FavoriteGifRow>(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $FavoriteGifsTable,
                    FavoriteGifRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteGifsTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $FavoriteGifsTable,
      FavoriteGifRow,
      $$FavoriteGifsTableFilterComposer,
      $$FavoriteGifsTableOrderingComposer,
      $$FavoriteGifsTableAnnotationComposer,
      $$FavoriteGifsTableCreateCompanionBuilder,
      $$FavoriteGifsTableUpdateCompanionBuilder,
      (
        FavoriteGifRow,
        BaseReferences<_$NeriDatabase, $FavoriteGifsTable, FavoriteGifRow>,
      ),
      FavoriteGifRow,
      PrefetchHooks Function()
    >;
typedef $$InboxesTableCreateCompanionBuilder =
    InboxesCompanion Function({
      required String id,
      required String channelId,
      required String recipientId,
      Value<int?> lastSeen,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$InboxesTableUpdateCompanionBuilder =
    InboxesCompanion Function({
      Value<String> id,
      Value<String> channelId,
      Value<String> recipientId,
      Value<int?> lastSeen,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$InboxesTableFilterComposer
    extends Composer<_$NeriDatabase, $InboxesTable> {
  $$InboxesTableFilterComposer({
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

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxesTableOrderingComposer
    extends Composer<_$NeriDatabase, $InboxesTable> {
  $$InboxesTableOrderingComposer({
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

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxesTableAnnotationComposer
    extends Composer<_$NeriDatabase, $InboxesTable> {
  $$InboxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InboxesTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $InboxesTable,
          InboxRow,
          $$InboxesTableFilterComposer,
          $$InboxesTableOrderingComposer,
          $$InboxesTableAnnotationComposer,
          $$InboxesTableCreateCompanionBuilder,
          $$InboxesTableUpdateCompanionBuilder,
          (InboxRow, BaseReferences<_$NeriDatabase, $InboxesTable, InboxRow>),
          InboxRow,
          PrefetchHooks Function()
        > {
  $$InboxesTableTableManager(_$NeriDatabase db, $InboxesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> recipientId = const Value.absent(),
                Value<int?> lastSeen = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxesCompanion(
                id: id,
                channelId: channelId,
                recipientId: recipientId,
                lastSeen: lastSeen,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String channelId,
                required String recipientId,
                Value<int?> lastSeen = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InboxesCompanion.insert(
                id: id,
                channelId: channelId,
                recipientId: recipientId,
                lastSeen: lastSeen,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InboxesTable, InboxRow>(table),
                  BaseReferences<_$NeriDatabase, $InboxesTable, InboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxesTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $InboxesTable,
      InboxRow,
      $$InboxesTableFilterComposer,
      $$InboxesTableOrderingComposer,
      $$InboxesTableAnnotationComposer,
      $$InboxesTableCreateCompanionBuilder,
      $$InboxesTableUpdateCompanionBuilder,
      (InboxRow, BaseReferences<_$NeriDatabase, $InboxesTable, InboxRow>),
      InboxRow,
      PrefetchHooks Function()
    >;
typedef $$OrderedServerIdsTableCreateCompanionBuilder =
    OrderedServerIdsCompanion Function({
      required String id,
      required int position,
      Value<int> rowid,
    });
typedef $$OrderedServerIdsTableUpdateCompanionBuilder =
    OrderedServerIdsCompanion Function({
      Value<String> id,
      Value<int> position,
      Value<int> rowid,
    });

class $$OrderedServerIdsTableFilterComposer
    extends Composer<_$NeriDatabase, $OrderedServerIdsTable> {
  $$OrderedServerIdsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderedServerIdsTableOrderingComposer
    extends Composer<_$NeriDatabase, $OrderedServerIdsTable> {
  $$OrderedServerIdsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderedServerIdsTableAnnotationComposer
    extends Composer<_$NeriDatabase, $OrderedServerIdsTable> {
  $$OrderedServerIdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$OrderedServerIdsTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $OrderedServerIdsTable,
          OrderedServerIdRow,
          $$OrderedServerIdsTableFilterComposer,
          $$OrderedServerIdsTableOrderingComposer,
          $$OrderedServerIdsTableAnnotationComposer,
          $$OrderedServerIdsTableCreateCompanionBuilder,
          $$OrderedServerIdsTableUpdateCompanionBuilder,
          (
            OrderedServerIdRow,
            BaseReferences<
              _$NeriDatabase,
              $OrderedServerIdsTable,
              OrderedServerIdRow
            >,
          ),
          OrderedServerIdRow,
          PrefetchHooks Function()
        > {
  $$OrderedServerIdsTableTableManager(
    _$NeriDatabase db,
    $OrderedServerIdsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderedServerIdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderedServerIdsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderedServerIdsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderedServerIdsCompanion(
                id: id,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => OrderedServerIdsCompanion.insert(
                id: id,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrderedServerIdsTable, OrderedServerIdRow>(
                    table,
                  ),
                  BaseReferences<
                    _$NeriDatabase,
                    $OrderedServerIdsTable,
                    OrderedServerIdRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderedServerIdsTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $OrderedServerIdsTable,
      OrderedServerIdRow,
      $$OrderedServerIdsTableFilterComposer,
      $$OrderedServerIdsTableOrderingComposer,
      $$OrderedServerIdsTableAnnotationComposer,
      $$OrderedServerIdsTableCreateCompanionBuilder,
      $$OrderedServerIdsTableUpdateCompanionBuilder,
      (
        OrderedServerIdRow,
        BaseReferences<
          _$NeriDatabase,
          $OrderedServerIdsTable,
          OrderedServerIdRow
        >,
      ),
      OrderedServerIdRow,
      PrefetchHooks Function()
    >;
typedef $$RecentEmojisTableCreateCompanionBuilder =
    RecentEmojisCompanion Function({
      required String emoji,
      Value<bool> custom,
      required int usedAt,
      Value<int> rowid,
    });
typedef $$RecentEmojisTableUpdateCompanionBuilder =
    RecentEmojisCompanion Function({
      Value<String> emoji,
      Value<bool> custom,
      Value<int> usedAt,
      Value<int> rowid,
    });

class $$RecentEmojisTableFilterComposer
    extends Composer<_$NeriDatabase, $RecentEmojisTable> {
  $$RecentEmojisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get custom => $composableBuilder(
    column: $table.custom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentEmojisTableOrderingComposer
    extends Composer<_$NeriDatabase, $RecentEmojisTable> {
  $$RecentEmojisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get custom => $composableBuilder(
    column: $table.custom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentEmojisTableAnnotationComposer
    extends Composer<_$NeriDatabase, $RecentEmojisTable> {
  $$RecentEmojisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get custom =>
      $composableBuilder(column: $table.custom, builder: (column) => column);

  GeneratedColumn<int> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$RecentEmojisTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $RecentEmojisTable,
          RecentEmojiRow,
          $$RecentEmojisTableFilterComposer,
          $$RecentEmojisTableOrderingComposer,
          $$RecentEmojisTableAnnotationComposer,
          $$RecentEmojisTableCreateCompanionBuilder,
          $$RecentEmojisTableUpdateCompanionBuilder,
          (
            RecentEmojiRow,
            BaseReferences<_$NeriDatabase, $RecentEmojisTable, RecentEmojiRow>,
          ),
          RecentEmojiRow,
          PrefetchHooks Function()
        > {
  $$RecentEmojisTableTableManager(_$NeriDatabase db, $RecentEmojisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentEmojisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentEmojisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentEmojisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> emoji = const Value.absent(),
                Value<bool> custom = const Value.absent(),
                Value<int> usedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentEmojisCompanion(
                emoji: emoji,
                custom: custom,
                usedAt: usedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String emoji,
                Value<bool> custom = const Value.absent(),
                required int usedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentEmojisCompanion.insert(
                emoji: emoji,
                custom: custom,
                usedAt: usedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentEmojisTable, RecentEmojiRow>(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $RecentEmojisTable,
                    RecentEmojiRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentEmojisTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $RecentEmojisTable,
      RecentEmojiRow,
      $$RecentEmojisTableFilterComposer,
      $$RecentEmojisTableOrderingComposer,
      $$RecentEmojisTableAnnotationComposer,
      $$RecentEmojisTableCreateCompanionBuilder,
      $$RecentEmojisTableUpdateCompanionBuilder,
      (
        RecentEmojiRow,
        BaseReferences<_$NeriDatabase, $RecentEmojisTable, RecentEmojiRow>,
      ),
      RecentEmojiRow,
      PrefetchHooks Function()
    >;
typedef $$ServerMembersTableCreateCompanionBuilder =
    ServerMembersCompanion Function({
      required String id,
      required String serverId,
      required String userId,
      Value<String?> nickname,
      required String roleIds,
      Value<int> rowid,
    });
typedef $$ServerMembersTableUpdateCompanionBuilder =
    ServerMembersCompanion Function({
      Value<String> id,
      Value<String> serverId,
      Value<String> userId,
      Value<String?> nickname,
      Value<String> roleIds,
      Value<int> rowid,
    });

class $$ServerMembersTableFilterComposer
    extends Composer<_$NeriDatabase, $ServerMembersTable> {
  $$ServerMembersTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleIds => $composableBuilder(
    column: $table.roleIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerMembersTableOrderingComposer
    extends Composer<_$NeriDatabase, $ServerMembersTable> {
  $$ServerMembersTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleIds => $composableBuilder(
    column: $table.roleIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerMembersTableAnnotationComposer
    extends Composer<_$NeriDatabase, $ServerMembersTable> {
  $$ServerMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get roleIds =>
      $composableBuilder(column: $table.roleIds, builder: (column) => column);
}

class $$ServerMembersTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $ServerMembersTable,
          ServerMemberRow,
          $$ServerMembersTableFilterComposer,
          $$ServerMembersTableOrderingComposer,
          $$ServerMembersTableAnnotationComposer,
          $$ServerMembersTableCreateCompanionBuilder,
          $$ServerMembersTableUpdateCompanionBuilder,
          (
            ServerMemberRow,
            BaseReferences<
              _$NeriDatabase,
              $ServerMembersTable,
              ServerMemberRow
            >,
          ),
          ServerMemberRow,
          PrefetchHooks Function()
        > {
  $$ServerMembersTableTableManager(_$NeriDatabase db, $ServerMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> roleIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerMembersCompanion(
                id: id,
                serverId: serverId,
                userId: userId,
                nickname: nickname,
                roleIds: roleIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serverId,
                required String userId,
                Value<String?> nickname = const Value.absent(),
                required String roleIds,
                Value<int> rowid = const Value.absent(),
              }) => ServerMembersCompanion.insert(
                id: id,
                serverId: serverId,
                userId: userId,
                nickname: nickname,
                roleIds: roleIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServerMembersTable, ServerMemberRow>(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $ServerMembersTable,
                    ServerMemberRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $ServerMembersTable,
      ServerMemberRow,
      $$ServerMembersTableFilterComposer,
      $$ServerMembersTableOrderingComposer,
      $$ServerMembersTableAnnotationComposer,
      $$ServerMembersTableCreateCompanionBuilder,
      $$ServerMembersTableUpdateCompanionBuilder,
      (
        ServerMemberRow,
        BaseReferences<_$NeriDatabase, $ServerMembersTable, ServerMemberRow>,
      ),
      ServerMemberRow,
      PrefetchHooks Function()
    >;
typedef $$ServerRolesTableCreateCompanionBuilder =
    ServerRolesCompanion Function({
      required String id,
      required String serverId,
      required String name,
      required bool hideRole,
      Value<String?> hexColor,
      required int permissions,
      required int order,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$ServerRolesTableUpdateCompanionBuilder =
    ServerRolesCompanion Function({
      Value<String> id,
      Value<String> serverId,
      Value<String> name,
      Value<bool> hideRole,
      Value<String?> hexColor,
      Value<int> permissions,
      Value<int> order,
      Value<String?> icon,
      Value<int> rowid,
    });

class $$ServerRolesTableFilterComposer
    extends Composer<_$NeriDatabase, $ServerRolesTable> {
  $$ServerRolesTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideRole => $composableBuilder(
    column: $table.hideRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerRolesTableOrderingComposer
    extends Composer<_$NeriDatabase, $ServerRolesTable> {
  $$ServerRolesTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideRole => $composableBuilder(
    column: $table.hideRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerRolesTableAnnotationComposer
    extends Composer<_$NeriDatabase, $ServerRolesTable> {
  $$ServerRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get hideRole =>
      $composableBuilder(column: $table.hideRole, builder: (column) => column);

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<int> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$ServerRolesTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $ServerRolesTable,
          ServerRoleRow,
          $$ServerRolesTableFilterComposer,
          $$ServerRolesTableOrderingComposer,
          $$ServerRolesTableAnnotationComposer,
          $$ServerRolesTableCreateCompanionBuilder,
          $$ServerRolesTableUpdateCompanionBuilder,
          (
            ServerRoleRow,
            BaseReferences<_$NeriDatabase, $ServerRolesTable, ServerRoleRow>,
          ),
          ServerRoleRow,
          PrefetchHooks Function()
        > {
  $$ServerRolesTableTableManager(_$NeriDatabase db, $ServerRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> hideRole = const Value.absent(),
                Value<String?> hexColor = const Value.absent(),
                Value<int> permissions = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerRolesCompanion(
                id: id,
                serverId: serverId,
                name: name,
                hideRole: hideRole,
                hexColor: hexColor,
                permissions: permissions,
                order: order,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serverId,
                required String name,
                required bool hideRole,
                Value<String?> hexColor = const Value.absent(),
                required int permissions,
                required int order,
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerRolesCompanion.insert(
                id: id,
                serverId: serverId,
                name: name,
                hideRole: hideRole,
                hexColor: hexColor,
                permissions: permissions,
                order: order,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServerRolesTable, ServerRoleRow>(table),
                  BaseReferences<
                    _$NeriDatabase,
                    $ServerRolesTable,
                    ServerRoleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $ServerRolesTable,
      ServerRoleRow,
      $$ServerRolesTableFilterComposer,
      $$ServerRolesTableOrderingComposer,
      $$ServerRolesTableAnnotationComposer,
      $$ServerRolesTableCreateCompanionBuilder,
      $$ServerRolesTableUpdateCompanionBuilder,
      (
        ServerRoleRow,
        BaseReferences<_$NeriDatabase, $ServerRolesTable, ServerRoleRow>,
      ),
      ServerRoleRow,
      PrefetchHooks Function()
    >;
typedef $$ServersTableCreateCompanionBuilder =
    ServersCompanion Function({
      required String id,
      required String name,
      Value<String?> avatar,
      required String hexColor,
      required String defaultChannelId,
      required String defaultRoleId,
      required String createdById,
      Value<int> rowid,
    });
typedef $$ServersTableUpdateCompanionBuilder =
    ServersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> avatar,
      Value<String> hexColor,
      Value<String> defaultChannelId,
      Value<String> defaultRoleId,
      Value<String> createdById,
      Value<int> rowid,
    });

class $$ServersTableFilterComposer
    extends Composer<_$NeriDatabase, $ServersTable> {
  $$ServersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultChannelId => $composableBuilder(
    column: $table.defaultChannelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultRoleId => $composableBuilder(
    column: $table.defaultRoleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServersTableOrderingComposer
    extends Composer<_$NeriDatabase, $ServersTable> {
  $$ServersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultChannelId => $composableBuilder(
    column: $table.defaultChannelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultRoleId => $composableBuilder(
    column: $table.defaultRoleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServersTableAnnotationComposer
    extends Composer<_$NeriDatabase, $ServersTable> {
  $$ServersTableAnnotationComposer({
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

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<String> get defaultChannelId => $composableBuilder(
    column: $table.defaultChannelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultRoleId => $composableBuilder(
    column: $table.defaultRoleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => column,
  );
}

class $$ServersTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $ServersTable,
          ServerRow,
          $$ServersTableFilterComposer,
          $$ServersTableOrderingComposer,
          $$ServersTableAnnotationComposer,
          $$ServersTableCreateCompanionBuilder,
          $$ServersTableUpdateCompanionBuilder,
          (ServerRow, BaseReferences<_$NeriDatabase, $ServersTable, ServerRow>),
          ServerRow,
          PrefetchHooks Function()
        > {
  $$ServersTableTableManager(_$NeriDatabase db, $ServersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String> hexColor = const Value.absent(),
                Value<String> defaultChannelId = const Value.absent(),
                Value<String> defaultRoleId = const Value.absent(),
                Value<String> createdById = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion(
                id: id,
                name: name,
                avatar: avatar,
                hexColor: hexColor,
                defaultChannelId: defaultChannelId,
                defaultRoleId: defaultRoleId,
                createdById: createdById,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> avatar = const Value.absent(),
                required String hexColor,
                required String defaultChannelId,
                required String defaultRoleId,
                required String createdById,
                Value<int> rowid = const Value.absent(),
              }) => ServersCompanion.insert(
                id: id,
                name: name,
                avatar: avatar,
                hexColor: hexColor,
                defaultChannelId: defaultChannelId,
                defaultRoleId: defaultRoleId,
                createdById: createdById,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServersTable, ServerRow>(table),
                  BaseReferences<_$NeriDatabase, $ServersTable, ServerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServersTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $ServersTable,
      ServerRow,
      $$ServersTableFilterComposer,
      $$ServersTableOrderingComposer,
      $$ServersTableAnnotationComposer,
      $$ServersTableCreateCompanionBuilder,
      $$ServersTableUpdateCompanionBuilder,
      (ServerRow, BaseReferences<_$NeriDatabase, $ServersTable, ServerRow>),
      ServerRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String username,
      required String hexColor,
      Value<String?> avatar,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> username,
      Value<String> hexColor,
      Value<String?> avatar,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$NeriDatabase, $UsersTable> {
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$NeriDatabase, $UsersTable> {
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$NeriDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$NeriDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$NeriDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$NeriDatabase db, $UsersTable table)
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
                Value<String> username = const Value.absent(),
                Value<String> hexColor = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                hexColor: hexColor,
                avatar: avatar,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                required String hexColor,
                Value<String?> avatar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                hexColor: hexColor,
                avatar: avatar,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$NeriDatabase, $UsersTable, UserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$NeriDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$NeriDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;

class $NeriDatabaseManager {
  final _$NeriDatabase _db;
  $NeriDatabaseManager(this._db);
  $$AnnouncementsTableTableManager get announcements =>
      $$AnnouncementsTableTableManager(_db, _db.announcements);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$DismissedAnnouncementsTableTableManager get dismissedAnnouncements =>
      $$DismissedAnnouncementsTableTableManager(
        _db,
        _db.dismissedAnnouncements,
      );
  $$FavoriteGifsTableTableManager get favoriteGifs =>
      $$FavoriteGifsTableTableManager(_db, _db.favoriteGifs);
  $$InboxesTableTableManager get inboxes =>
      $$InboxesTableTableManager(_db, _db.inboxes);
  $$OrderedServerIdsTableTableManager get orderedServerIds =>
      $$OrderedServerIdsTableTableManager(_db, _db.orderedServerIds);
  $$RecentEmojisTableTableManager get recentEmojis =>
      $$RecentEmojisTableTableManager(_db, _db.recentEmojis);
  $$ServerMembersTableTableManager get serverMembers =>
      $$ServerMembersTableTableManager(_db, _db.serverMembers);
  $$ServerRolesTableTableManager get serverRoles =>
      $$ServerRolesTableTableManager(_db, _db.serverRoles);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db, _db.servers);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
