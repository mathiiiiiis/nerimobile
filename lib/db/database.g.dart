// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  const ChannelRow({
    required this.id,
    required this.type,
    this.name,
    this.order,
    this.serverId,
    this.icon,
    this.categoryId,
    this.lastMessagedAt,
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
          ..write('lastMessagedAt: $lastMessagedAt')
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
          other.lastMessagedAt == this.lastMessagedAt);
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
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $InboxesTable inboxes = $InboxesTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    channels,
    inboxes,
    users,
  ];
}

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
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$InboxesTableTableManager get inboxes =>
      $$InboxesTableTableManager(_db, _db.inboxes);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
