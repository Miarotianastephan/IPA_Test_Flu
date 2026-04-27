// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<int> lastMessageId = GeneratedColumn<int>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    lastMessageId,
    createdAt,
    updatedAt,
    unreadCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String> type;
  final Value<int?> lastMessageId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> unreadCount;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String type,
    this.lastMessageId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.unreadCount = const Value.absent(),
  }) : type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? lastMessageId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? unreadCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (unreadCount != null) 'unread_count': unreadCount,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<String>? type,
    Value<int?>? lastMessageId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? unreadCount,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }
}

class $ConversationUsersTable extends ConversationUsers
    with TableInfo<$ConversationUsersTable, ConversationUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agentSupportIdMeta = const VerificationMeta(
    'agentSupportId',
  );
  @override
  late final GeneratedColumn<String> agentSupportId = GeneratedColumn<String>(
    'agent_support_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    userId,
    agentSupportId,
    role,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('agent_support_id')) {
      context.handle(
        _agentSupportIdMeta,
        agentSupportId.isAcceptableOrUnknown(
          data['agent_support_id']!,
          _agentSupportIdMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      agentSupportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_support_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $ConversationUsersTable createAlias(String alias) {
    return $ConversationUsersTable(attachedDatabase, alias);
  }
}

class ConversationUsersCompanion extends UpdateCompanion<ConversationUser> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String?> userId;
  final Value<String?> agentSupportId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  const ConversationUsersCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.agentSupportId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  ConversationUsersCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    this.userId = const Value.absent(),
    this.agentSupportId = const Value.absent(),
    this.role = const Value.absent(),
    required DateTime joinedAt,
  }) : conversationId = Value(conversationId),
       joinedAt = Value(joinedAt);
  static Insertable<ConversationUser> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? userId,
    Expression<String>? agentSupportId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (userId != null) 'user_id': userId,
      if (agentSupportId != null) 'agent_support_id': agentSupportId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
    });
  }

  ConversationUsersCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<String?>? userId,
    Value<String?>? agentSupportId,
    Value<String>? role,
    Value<DateTime>? joinedAt,
  }) {
    return ConversationUsersCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      agentSupportId: agentSupportId ?? this.agentSupportId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (agentSupportId.present) {
      map['agent_support_id'] = Variable<String>(agentSupportId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationUsersCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('agentSupportId: $agentSupportId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderSupportIdMeta = const VerificationMeta(
    'senderSupportId',
  );
  @override
  late final GeneratedColumn<String> senderSupportId = GeneratedColumn<String>(
    'sender_support_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRevokedMeta = const VerificationMeta(
    'isRevoked',
  );
  @override
  late final GeneratedColumn<bool> isRevoked = GeneratedColumn<bool>(
    'is_revoked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_revoked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
    'is_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sendFailedMeta = const VerificationMeta(
    'sendFailed',
  );
  @override
  late final GeneratedColumn<bool> sendFailed = GeneratedColumn<bool>(
    'send_failed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("send_failed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    id,
    conversationId,
    senderId,
    senderSupportId,
    content,
    messageType,
    isRevoked,
    isRead,
    mediaUrl,
    thumbnail,
    duration,
    createdAt,
    updatedAt,
    isSelf,
    sendFailed,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('sender_support_id')) {
      context.handle(
        _senderSupportIdMeta,
        senderSupportId.isAcceptableOrUnknown(
          data['sender_support_id']!,
          _senderSupportIdMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('is_revoked')) {
      context.handle(
        _isRevokedMeta,
        isRevoked.isAcceptableOrUnknown(data['is_revoked']!, _isRevokedMeta),
      );
    } else if (isInserting) {
      context.missing(_isRevokedMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_self')) {
      context.handle(
        _isSelfMeta,
        isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta),
      );
    }
    if (data.containsKey('send_failed')) {
      context.handle(
        _sendFailedMeta,
        sendFailed.isAcceptableOrUnknown(data['send_failed']!, _sendFailedMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      ),
      senderSupportId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_support_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      isRevoked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_revoked'],
      )!,
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self'],
      )!,
      sendFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}send_failed'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String?> senderId;
  final Value<String?> senderSupportId;
  final Value<String> content;
  final Value<String> messageType;
  final Value<bool> isRevoked;
  final Value<bool> isRead;
  final Value<String?> mediaUrl;
  final Value<String?> thumbnail;
  final Value<int?> duration;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isSelf;
  final Value<bool> sendFailed;
  final Value<DateTime?> revokedAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderSupportId = const Value.absent(),
    this.content = const Value.absent(),
    this.messageType = const Value.absent(),
    this.isRevoked = const Value.absent(),
    this.isRead = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.duration = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.revokedAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    this.senderId = const Value.absent(),
    this.senderSupportId = const Value.absent(),
    required String content,
    required String messageType,
    required bool isRevoked,
    this.isRead = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.duration = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.revokedAt = const Value.absent(),
  }) : conversationId = Value(conversationId),
       content = Value(content),
       messageType = Value(messageType),
       isRevoked = Value(isRevoked),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? senderId,
    Expression<String>? senderSupportId,
    Expression<String>? content,
    Expression<String>? messageType,
    Expression<bool>? isRevoked,
    Expression<bool>? isRead,
    Expression<String>? mediaUrl,
    Expression<String>? thumbnail,
    Expression<int>? duration,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSelf,
    Expression<bool>? sendFailed,
    Expression<DateTime>? revokedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (senderSupportId != null) 'sender_support_id': senderSupportId,
      if (content != null) 'content': content,
      if (messageType != null) 'message_type': messageType,
      if (isRevoked != null) 'is_revoked': isRevoked,
      if (isRead != null) 'is_read': isRead,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (duration != null) 'duration': duration,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSelf != null) 'is_self': isSelf,
      if (sendFailed != null) 'send_failed': sendFailed,
      if (revokedAt != null) 'revoked_at': revokedAt,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<String?>? senderId,
    Value<String?>? senderSupportId,
    Value<String>? content,
    Value<String>? messageType,
    Value<bool>? isRevoked,
    Value<bool>? isRead,
    Value<String?>? mediaUrl,
    Value<String?>? thumbnail,
    Value<int?>? duration,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isSelf,
    Value<bool>? sendFailed,
    Value<DateTime?>? revokedAt,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderSupportId: senderSupportId ?? this.senderSupportId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isRevoked: isRevoked ?? this.isRevoked,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSelf: isSelf ?? this.isSelf,
      sendFailed: sendFailed ?? this.sendFailed,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderSupportId.present) {
      map['sender_support_id'] = Variable<String>(senderSupportId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (isRevoked.present) {
      map['is_revoked'] = Variable<bool>(isRevoked.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    if (sendFailed.present) {
      map['send_failed'] = Variable<bool>(sendFailed.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('senderSupportId: $senderSupportId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('isRevoked: $isRevoked, ')
          ..write('isRead: $isRead, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('duration: $duration, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSelf: $isSelf, ')
          ..write('sendFailed: $sendFailed, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }
}

class $UserInfosTable extends UserInfos
    with TableInfo<$UserInfosTable, UserInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayIdMeta = const VerificationMeta(
    'displayId',
  );
  @override
  late final GeneratedColumn<String> displayId = GeneratedColumn<String>(
    'display_id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _credentialMeta = const VerificationMeta(
    'credential',
  );
  @override
  late final GeneratedColumn<String> credential = GeneratedColumn<String>(
    'credential',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVisitorMeta = const VerificationMeta(
    'isVisitor',
  );
  @override
  late final GeneratedColumn<bool> isVisitor = GeneratedColumn<bool>(
    'is_visitor',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visitor" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isBindPassMeta = const VerificationMeta(
    'isBindPass',
  );
  @override
  late final GeneratedColumn<bool> isBindPass = GeneratedColumn<bool>(
    'is_bind_pass',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bind_pass" IN (0, 1))',
    ),
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<int> agentId = GeneratedColumn<int>(
    'agent_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inviteCodeMeta = const VerificationMeta(
    'inviteCode',
  );
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
    'invite_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextExpMeta = const VerificationMeta(
    'nextExp',
  );
  @override
  late final GeneratedColumn<int> nextExp = GeneratedColumn<int>(
    'next_exp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelNameMeta = const VerificationMeta(
    'levelName',
  );
  @override
  late final GeneratedColumn<String> levelName = GeneratedColumn<String>(
    'level_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fansCountMeta = const VerificationMeta(
    'fansCount',
  );
  @override
  late final GeneratedColumn<int> fansCount = GeneratedColumn<int>(
    'fans_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followCountMeta = const VerificationMeta(
    'followCount',
  );
  @override
  late final GeneratedColumn<int> followCount = GeneratedColumn<int>(
    'follow_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFollowedMeta = const VerificationMeta(
    'isFollowed',
  );
  @override
  late final GeneratedColumn<bool> isFollowed = GeneratedColumn<bool>(
    'is_followed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_followed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayId,
    username,
    credential,
    isVisitor,
    isBindPass,
    agentId,
    inviteCode,
    level,
    nextExp,
    levelName,
    token,
    avatar,
    phone,
    bio,
    cover,
    nickname,
    fansCount,
    followCount,
    likeCount,
    isFollowed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_infos';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserInfo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_id')) {
      context.handle(
        _displayIdMeta,
        displayId.isAcceptableOrUnknown(data['display_id']!, _displayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_displayIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('credential')) {
      context.handle(
        _credentialMeta,
        credential.isAcceptableOrUnknown(data['credential']!, _credentialMeta),
      );
    } else if (isInserting) {
      context.missing(_credentialMeta);
    }
    if (data.containsKey('is_visitor')) {
      context.handle(
        _isVisitorMeta,
        isVisitor.isAcceptableOrUnknown(data['is_visitor']!, _isVisitorMeta),
      );
    } else if (isInserting) {
      context.missing(_isVisitorMeta);
    }
    if (data.containsKey('is_bind_pass')) {
      context.handle(
        _isBindPassMeta,
        isBindPass.isAcceptableOrUnknown(
          data['is_bind_pass']!,
          _isBindPassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isBindPassMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('invite_code')) {
      context.handle(
        _inviteCodeMeta,
        inviteCode.isAcceptableOrUnknown(data['invite_code']!, _inviteCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_inviteCodeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('next_exp')) {
      context.handle(
        _nextExpMeta,
        nextExp.isAcceptableOrUnknown(data['next_exp']!, _nextExpMeta),
      );
    }
    if (data.containsKey('level_name')) {
      context.handle(
        _levelNameMeta,
        levelName.isAcceptableOrUnknown(data['level_name']!, _levelNameMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('fans_count')) {
      context.handle(
        _fansCountMeta,
        fansCount.isAcceptableOrUnknown(data['fans_count']!, _fansCountMeta),
      );
    }
    if (data.containsKey('follow_count')) {
      context.handle(
        _followCountMeta,
        followCount.isAcceptableOrUnknown(
          data['follow_count']!,
          _followCountMeta,
        ),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('is_followed')) {
      context.handle(
        _isFollowedMeta,
        isFollowed.isAcceptableOrUnknown(data['is_followed']!, _isFollowedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserInfo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      credential: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential'],
      )!,
      isVisitor: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visitor'],
      )!,
      isBindPass: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bind_pass'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agent_id'],
      )!,
      inviteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_code'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      nextExp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_exp'],
      ),
      levelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_name'],
      ),
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      fansCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fans_count'],
      ),
      followCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}follow_count'],
      ),
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      ),
      isFollowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_followed'],
      )!,
    );
  }

  @override
  $UserInfosTable createAlias(String alias) {
    return $UserInfosTable(attachedDatabase, alias);
  }
}

class UserInfosCompanion extends UpdateCompanion<UserInfo> {
  final Value<String> id;
  final Value<String> displayId;
  final Value<String?> username;
  final Value<String> credential;
  final Value<bool> isVisitor;
  final Value<bool> isBindPass;
  final Value<int> agentId;
  final Value<String> inviteCode;
  final Value<int?> level;
  final Value<int?> nextExp;
  final Value<String?> levelName;
  final Value<String?> token;
  final Value<String?> avatar;
  final Value<String?> phone;
  final Value<String?> bio;
  final Value<String?> cover;
  final Value<String> nickname;
  final Value<int?> fansCount;
  final Value<int?> followCount;
  final Value<int?> likeCount;
  final Value<bool> isFollowed;
  final Value<int> rowid;
  const UserInfosCompanion({
    this.id = const Value.absent(),
    this.displayId = const Value.absent(),
    this.username = const Value.absent(),
    this.credential = const Value.absent(),
    this.isVisitor = const Value.absent(),
    this.isBindPass = const Value.absent(),
    this.agentId = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.level = const Value.absent(),
    this.nextExp = const Value.absent(),
    this.levelName = const Value.absent(),
    this.token = const Value.absent(),
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.bio = const Value.absent(),
    this.cover = const Value.absent(),
    this.nickname = const Value.absent(),
    this.fansCount = const Value.absent(),
    this.followCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserInfosCompanion.insert({
    required String id,
    required String displayId,
    this.username = const Value.absent(),
    required String credential,
    required bool isVisitor,
    required bool isBindPass,
    required int agentId,
    required String inviteCode,
    this.level = const Value.absent(),
    this.nextExp = const Value.absent(),
    this.levelName = const Value.absent(),
    this.token = const Value.absent(),
    this.avatar = const Value.absent(),
    this.phone = const Value.absent(),
    this.bio = const Value.absent(),
    this.cover = const Value.absent(),
    required String nickname,
    this.fansCount = const Value.absent(),
    this.followCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayId = Value(displayId),
       credential = Value(credential),
       isVisitor = Value(isVisitor),
       isBindPass = Value(isBindPass),
       agentId = Value(agentId),
       inviteCode = Value(inviteCode),
       nickname = Value(nickname);
  static Insertable<UserInfo> custom({
    Expression<String>? id,
    Expression<String>? displayId,
    Expression<String>? username,
    Expression<String>? credential,
    Expression<bool>? isVisitor,
    Expression<bool>? isBindPass,
    Expression<int>? agentId,
    Expression<String>? inviteCode,
    Expression<int>? level,
    Expression<int>? nextExp,
    Expression<String>? levelName,
    Expression<String>? token,
    Expression<String>? avatar,
    Expression<String>? phone,
    Expression<String>? bio,
    Expression<String>? cover,
    Expression<String>? nickname,
    Expression<int>? fansCount,
    Expression<int>? followCount,
    Expression<int>? likeCount,
    Expression<bool>? isFollowed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayId != null) 'display_id': displayId,
      if (username != null) 'username': username,
      if (credential != null) 'credential': credential,
      if (isVisitor != null) 'is_visitor': isVisitor,
      if (isBindPass != null) 'is_bind_pass': isBindPass,
      if (agentId != null) 'agent_id': agentId,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (level != null) 'level': level,
      if (nextExp != null) 'next_exp': nextExp,
      if (levelName != null) 'level_name': levelName,
      if (token != null) 'token': token,
      if (avatar != null) 'avatar': avatar,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
      if (cover != null) 'cover': cover,
      if (nickname != null) 'nickname': nickname,
      if (fansCount != null) 'fans_count': fansCount,
      if (followCount != null) 'follow_count': followCount,
      if (likeCount != null) 'like_count': likeCount,
      if (isFollowed != null) 'is_followed': isFollowed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserInfosCompanion copyWith({
    Value<String>? id,
    Value<String>? displayId,
    Value<String?>? username,
    Value<String>? credential,
    Value<bool>? isVisitor,
    Value<bool>? isBindPass,
    Value<int>? agentId,
    Value<String>? inviteCode,
    Value<int?>? level,
    Value<int?>? nextExp,
    Value<String?>? levelName,
    Value<String?>? token,
    Value<String?>? avatar,
    Value<String?>? phone,
    Value<String?>? bio,
    Value<String?>? cover,
    Value<String>? nickname,
    Value<int?>? fansCount,
    Value<int?>? followCount,
    Value<int?>? likeCount,
    Value<bool>? isFollowed,
    Value<int>? rowid,
  }) {
    return UserInfosCompanion(
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      username: username ?? this.username,
      credential: credential ?? this.credential,
      isVisitor: isVisitor ?? this.isVisitor,
      isBindPass: isBindPass ?? this.isBindPass,
      agentId: agentId ?? this.agentId,
      inviteCode: inviteCode ?? this.inviteCode,
      level: level ?? this.level,
      nextExp: nextExp ?? this.nextExp,
      levelName: levelName ?? this.levelName,
      token: token ?? this.token,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      cover: cover ?? this.cover,
      nickname: nickname ?? this.nickname,
      fansCount: fansCount ?? this.fansCount,
      followCount: followCount ?? this.followCount,
      likeCount: likeCount ?? this.likeCount,
      isFollowed: isFollowed ?? this.isFollowed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayId.present) {
      map['display_id'] = Variable<String>(displayId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (credential.present) {
      map['credential'] = Variable<String>(credential.value);
    }
    if (isVisitor.present) {
      map['is_visitor'] = Variable<bool>(isVisitor.value);
    }
    if (isBindPass.present) {
      map['is_bind_pass'] = Variable<bool>(isBindPass.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<int>(agentId.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (nextExp.present) {
      map['next_exp'] = Variable<int>(nextExp.value);
    }
    if (levelName.present) {
      map['level_name'] = Variable<String>(levelName.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (fansCount.present) {
      map['fans_count'] = Variable<int>(fansCount.value);
    }
    if (followCount.present) {
      map['follow_count'] = Variable<int>(followCount.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (isFollowed.present) {
      map['is_followed'] = Variable<bool>(isFollowed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserInfosCompanion(')
          ..write('id: $id, ')
          ..write('displayId: $displayId, ')
          ..write('username: $username, ')
          ..write('credential: $credential, ')
          ..write('isVisitor: $isVisitor, ')
          ..write('isBindPass: $isBindPass, ')
          ..write('agentId: $agentId, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('level: $level, ')
          ..write('nextExp: $nextExp, ')
          ..write('levelName: $levelName, ')
          ..write('token: $token, ')
          ..write('avatar: $avatar, ')
          ..write('phone: $phone, ')
          ..write('bio: $bio, ')
          ..write('cover: $cover, ')
          ..write('nickname: $nickname, ')
          ..write('fansCount: $fansCount, ')
          ..write('followCount: $followCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('isFollowed: $isFollowed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmojisTable extends Emojis with TableInfo<$EmojisTable, EmojiCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmojisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupPriceMeta = const VerificationMeta(
    'groupPrice',
  );
  @override
  late final GeneratedColumn<String> groupPrice = GeneratedColumn<String>(
    'group_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIsPremiumMeta = const VerificationMeta(
    'groupIsPremium',
  );
  @override
  late final GeneratedColumn<bool> groupIsPremium = GeneratedColumn<bool>(
    'group_is_premium',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("group_is_premium" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _purchasedMeta = const VerificationMeta(
    'purchased',
  );
  @override
  late final GeneratedColumn<bool> purchased = GeneratedColumn<bool>(
    'purchased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("purchased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    url,
    type,
    status,
    groupId,
    groupName,
    groupPrice,
    groupIsPremium,
    purchased,
    localPath,
    downloadedAt,
    updatedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emojis';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmojiCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('group_price')) {
      context.handle(
        _groupPriceMeta,
        groupPrice.isAcceptableOrUnknown(data['group_price']!, _groupPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_groupPriceMeta);
    }
    if (data.containsKey('group_is_premium')) {
      context.handle(
        _groupIsPremiumMeta,
        groupIsPremium.isAcceptableOrUnknown(
          data['group_is_premium']!,
          _groupIsPremiumMeta,
        ),
      );
    }
    if (data.containsKey('purchased')) {
      context.handle(
        _purchasedMeta,
        purchased.isAcceptableOrUnknown(data['purchased']!, _purchasedMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmojiCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmojiCache(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      groupPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_price'],
      )!,
      groupIsPremium: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}group_is_premium'],
      )!,
      purchased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}purchased'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EmojisTable createAlias(String alias) {
    return $EmojisTable(attachedDatabase, alias);
  }
}

class EmojisCompanion extends UpdateCompanion<EmojiCache> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> url;
  final Value<int> type;
  final Value<int> status;
  final Value<int> groupId;
  final Value<String> groupName;
  final Value<String> groupPrice;
  final Value<bool> groupIsPremium;
  final Value<bool> purchased;
  final Value<String?> localPath;
  final Value<DateTime?> downloadedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  const EmojisCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.groupPrice = const Value.absent(),
    this.groupIsPremium = const Value.absent(),
    this.purchased = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EmojisCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String url,
    required int type,
    required int status,
    required int groupId,
    required String groupName,
    required String groupPrice,
    this.groupIsPremium = const Value.absent(),
    this.purchased = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    required DateTime updatedAt,
    required DateTime createdAt,
  }) : code = Value(code),
       url = Value(url),
       type = Value(type),
       status = Value(status),
       groupId = Value(groupId),
       groupName = Value(groupName),
       groupPrice = Value(groupPrice),
       updatedAt = Value(updatedAt),
       createdAt = Value(createdAt);
  static Insertable<EmojiCache> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? url,
    Expression<int>? type,
    Expression<int>? status,
    Expression<int>? groupId,
    Expression<String>? groupName,
    Expression<String>? groupPrice,
    Expression<bool>? groupIsPremium,
    Expression<bool>? purchased,
    Expression<String>? localPath,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (groupPrice != null) 'group_price': groupPrice,
      if (groupIsPremium != null) 'group_is_premium': groupIsPremium,
      if (purchased != null) 'purchased': purchased,
      if (localPath != null) 'local_path': localPath,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EmojisCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? url,
    Value<int>? type,
    Value<int>? status,
    Value<int>? groupId,
    Value<String>? groupName,
    Value<String>? groupPrice,
    Value<bool>? groupIsPremium,
    Value<bool>? purchased,
    Value<String?>? localPath,
    Value<DateTime?>? downloadedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? createdAt,
  }) {
    return EmojisCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      url: url ?? this.url,
      type: type ?? this.type,
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupPrice: groupPrice ?? this.groupPrice,
      groupIsPremium: groupIsPremium ?? this.groupIsPremium,
      purchased: purchased ?? this.purchased,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (groupPrice.present) {
      map['group_price'] = Variable<String>(groupPrice.value);
    }
    if (groupIsPremium.present) {
      map['group_is_premium'] = Variable<bool>(groupIsPremium.value);
    }
    if (purchased.present) {
      map['purchased'] = Variable<bool>(purchased.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmojisCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('url: $url, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('groupPrice: $groupPrice, ')
          ..write('groupIsPremium: $groupIsPremium, ')
          ..write('purchased: $purchased, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EmojiSyncMetadataTable extends EmojiSyncMetadata
    with TableInfo<$EmojiSyncMetadataTable, EmojiSyncMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmojiSyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [type, lastSyncAt, totalCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emoji_sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmojiSyncMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncAtMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  EmojiSyncMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmojiSyncMeta(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
    );
  }

  @override
  $EmojiSyncMetadataTable createAlias(String alias) {
    return $EmojiSyncMetadataTable(attachedDatabase, alias);
  }
}

class EmojiSyncMetadataCompanion extends UpdateCompanion<EmojiSyncMeta> {
  final Value<int> type;
  final Value<DateTime> lastSyncAt;
  final Value<int> totalCount;
  const EmojiSyncMetadataCompanion({
    this.type = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.totalCount = const Value.absent(),
  });
  EmojiSyncMetadataCompanion.insert({
    this.type = const Value.absent(),
    required DateTime lastSyncAt,
    this.totalCount = const Value.absent(),
  }) : lastSyncAt = Value(lastSyncAt);
  static Insertable<EmojiSyncMeta> custom({
    Expression<int>? type,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? totalCount,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (totalCount != null) 'total_count': totalCount,
    });
  }

  EmojiSyncMetadataCompanion copyWith({
    Value<int>? type,
    Value<DateTime>? lastSyncAt,
    Value<int>? totalCount,
  }) {
    return EmojiSyncMetadataCompanion(
      type: type ?? this.type,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmojiSyncMetadataCompanion(')
          ..write('type: $type, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('totalCount: $totalCount')
          ..write(')'))
        .toString();
  }
}

class $ImagesTable extends Images with TableInfo<$ImagesTable, ImageCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [url, localPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCache> instance, {
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
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  ImageCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCache(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }
}

class ImagesCompanion extends UpdateCompanion<ImageCache> {
  final Value<String> url;
  final Value<String?> localPath;
  final Value<int> rowid;
  const ImagesCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagesCompanion.insert({
    required String url,
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url);
  static Insertable<ImageCache> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagesCompanion copyWith({
    Value<String>? url,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return ImagesCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiosTable extends Audios with TableInfo<$AudiosTable, AudioCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [url, localPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audios';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioCache> instance, {
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
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  AudioCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioCache(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $AudiosTable createAlias(String alias) {
    return $AudiosTable(attachedDatabase, alias);
  }
}

class AudiosCompanion extends UpdateCompanion<AudioCache> {
  final Value<String> url;
  final Value<String?> localPath;
  final Value<int> rowid;
  const AudiosCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiosCompanion.insert({
    required String url,
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url);
  static Insertable<AudioCache> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiosCompanion copyWith({
    Value<String>? url,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return AudiosCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiosCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VideosTable extends Videos with TableInfo<$VideosTable, VideoCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [url, localPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoCache> instance, {
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
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  VideoCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoCache(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class VideosCompanion extends UpdateCompanion<VideoCache> {
  final Value<String> url;
  final Value<String?> localPath;
  final Value<int> rowid;
  const VideosCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosCompanion.insert({
    required String url,
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url);
  static Insertable<VideoCache> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosCompanion copyWith({
    Value<String>? url,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return VideosCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentSupportsTable extends AgentSupports
    with TableInfo<$AgentSupportsTable, AgentSupport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentSupportsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginIdMeta = const VerificationMeta(
    'loginId',
  );
  @override
  late final GeneratedColumn<String> loginId = GeneratedColumn<String>(
    'login_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    username,
    loginId,
    password,
    role,
    createdAt,
    updatedAt,
    avatar,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_supports';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentSupport> instance, {
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
    }
    if (data.containsKey('login_id')) {
      context.handle(
        _loginIdMeta,
        loginId.isAcceptableOrUnknown(data['login_id']!, _loginIdMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
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
  AgentSupport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentSupport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      loginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_id'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
    );
  }

  @override
  $AgentSupportsTable createAlias(String alias) {
    return $AgentSupportsTable(attachedDatabase, alias);
  }
}

class AgentSupportsCompanion extends UpdateCompanion<AgentSupport> {
  final Value<String> id;
  final Value<String?> username;
  final Value<String?> loginId;
  final Value<String?> password;
  final Value<String?> role;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> avatar;
  final Value<int> rowid;
  const AgentSupportsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.loginId = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.avatar = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentSupportsCompanion.insert({
    required String id,
    this.username = const Value.absent(),
    this.loginId = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.avatar = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AgentSupport> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? loginId,
    Expression<String>? password,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? avatar,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (loginId != null) 'login_id': loginId,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (avatar != null) 'avatar': avatar,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentSupportsCompanion copyWith({
    Value<String>? id,
    Value<String?>? username,
    Value<String?>? loginId,
    Value<String?>? password,
    Value<String?>? role,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? avatar,
    Value<int>? rowid,
  }) {
    return AgentSupportsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      loginId: loginId ?? this.loginId,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (loginId.present) {
      map['login_id'] = Variable<String>(loginId.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    return (StringBuffer('AgentSupportsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('loginId: $loginId, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('avatar: $avatar, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $ConversationUsersTable conversationUsers =
      $ConversationUsersTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $UserInfosTable userInfos = $UserInfosTable(this);
  late final $EmojisTable emojis = $EmojisTable(this);
  late final $EmojiSyncMetadataTable emojiSyncMetadata =
      $EmojiSyncMetadataTable(this);
  late final $ImagesTable images = $ImagesTable(this);
  late final $AudiosTable audios = $AudiosTable(this);
  late final $VideosTable videos = $VideosTable(this);
  late final $AgentSupportsTable agentSupports = $AgentSupportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversations,
    conversationUsers,
    messages,
    userInfos,
    emojis,
    emojiSyncMetadata,
    images,
    audios,
    videos,
    agentSupports,
  ];
}

typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<String?> name,
      required String type,
      Value<int?> lastMessageId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> unreadCount,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<String> type,
      Value<int?> lastMessageId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> unreadCount,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
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

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
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

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            Conversation,
            BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
          ),
          Conversation,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> lastMessageId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                name: name,
                type: type,
                lastMessageId: lastMessageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                unreadCount: unreadCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String type,
                Value<int?> lastMessageId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> unreadCount = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                name: name,
                type: type,
                lastMessageId: lastMessageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                unreadCount: unreadCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        Conversation,
        BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
      ),
      Conversation,
      PrefetchHooks Function()
    >;
typedef $$ConversationUsersTableCreateCompanionBuilder =
    ConversationUsersCompanion Function({
      Value<int> id,
      required int conversationId,
      Value<String?> userId,
      Value<String?> agentSupportId,
      Value<String> role,
      required DateTime joinedAt,
    });
typedef $$ConversationUsersTableUpdateCompanionBuilder =
    ConversationUsersCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<String?> userId,
      Value<String?> agentSupportId,
      Value<String> role,
      Value<DateTime> joinedAt,
    });

class $$ConversationUsersTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationUsersTable> {
  $$ConversationUsersTableFilterComposer({
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

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentSupportId => $composableBuilder(
    column: $table.agentSupportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationUsersTable> {
  $$ConversationUsersTableOrderingComposer({
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

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentSupportId => $composableBuilder(
    column: $table.agentSupportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationUsersTable> {
  $$ConversationUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get agentSupportId => $composableBuilder(
    column: $table.agentSupportId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$ConversationUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationUsersTable,
          ConversationUser,
          $$ConversationUsersTableFilterComposer,
          $$ConversationUsersTableOrderingComposer,
          $$ConversationUsersTableAnnotationComposer,
          $$ConversationUsersTableCreateCompanionBuilder,
          $$ConversationUsersTableUpdateCompanionBuilder,
          (
            ConversationUser,
            BaseReferences<
              _$AppDatabase,
              $ConversationUsersTable,
              ConversationUser
            >,
          ),
          ConversationUser,
          PrefetchHooks Function()
        > {
  $$ConversationUsersTableTableManager(
    _$AppDatabase db,
    $ConversationUsersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationUsersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> agentSupportId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
              }) => ConversationUsersCompanion(
                id: id,
                conversationId: conversationId,
                userId: userId,
                agentSupportId: agentSupportId,
                role: role,
                joinedAt: joinedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                Value<String?> userId = const Value.absent(),
                Value<String?> agentSupportId = const Value.absent(),
                Value<String> role = const Value.absent(),
                required DateTime joinedAt,
              }) => ConversationUsersCompanion.insert(
                id: id,
                conversationId: conversationId,
                userId: userId,
                agentSupportId: agentSupportId,
                role: role,
                joinedAt: joinedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationUsersTable,
      ConversationUser,
      $$ConversationUsersTableFilterComposer,
      $$ConversationUsersTableOrderingComposer,
      $$ConversationUsersTableAnnotationComposer,
      $$ConversationUsersTableCreateCompanionBuilder,
      $$ConversationUsersTableUpdateCompanionBuilder,
      (
        ConversationUser,
        BaseReferences<
          _$AppDatabase,
          $ConversationUsersTable,
          ConversationUser
        >,
      ),
      ConversationUser,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int conversationId,
      Value<String?> senderId,
      Value<String?> senderSupportId,
      required String content,
      required String messageType,
      required bool isRevoked,
      Value<bool> isRead,
      Value<String?> mediaUrl,
      Value<String?> thumbnail,
      Value<int?> duration,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isSelf,
      Value<bool> sendFailed,
      Value<DateTime?> revokedAt,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<String?> senderId,
      Value<String?> senderSupportId,
      Value<String> content,
      Value<String> messageType,
      Value<bool> isRevoked,
      Value<bool> isRead,
      Value<String?> mediaUrl,
      Value<String?> thumbnail,
      Value<int?> duration,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isSelf,
      Value<bool> sendFailed,
      Value<DateTime?> revokedAt,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderSupportId => $composableBuilder(
    column: $table.senderSupportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRevoked => $composableBuilder(
    column: $table.isRevoked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
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

  ColumnFilters<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderSupportId => $composableBuilder(
    column: $table.senderSupportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRevoked => $composableBuilder(
    column: $table.isRevoked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
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

  ColumnOrderings<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderSupportId => $composableBuilder(
    column: $table.senderSupportId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRevoked =>
      $composableBuilder(column: $table.isRevoked, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  GeneratedColumn<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String?> senderId = const Value.absent(),
                Value<String?> senderSupportId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<bool> isRevoked = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> mediaUrl = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<bool> sendFailed = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                senderSupportId: senderSupportId,
                content: content,
                messageType: messageType,
                isRevoked: isRevoked,
                isRead: isRead,
                mediaUrl: mediaUrl,
                thumbnail: thumbnail,
                duration: duration,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSelf: isSelf,
                sendFailed: sendFailed,
                revokedAt: revokedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                Value<String?> senderId = const Value.absent(),
                Value<String?> senderSupportId = const Value.absent(),
                required String content,
                required String messageType,
                required bool isRevoked,
                Value<bool> isRead = const Value.absent(),
                Value<String?> mediaUrl = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<bool> sendFailed = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                senderId: senderId,
                senderSupportId: senderSupportId,
                content: content,
                messageType: messageType,
                isRevoked: isRevoked,
                isRead: isRead,
                mediaUrl: mediaUrl,
                thumbnail: thumbnail,
                duration: duration,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSelf: isSelf,
                sendFailed: sendFailed,
                revokedAt: revokedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$UserInfosTableCreateCompanionBuilder =
    UserInfosCompanion Function({
      required String id,
      required String displayId,
      Value<String?> username,
      required String credential,
      required bool isVisitor,
      required bool isBindPass,
      required int agentId,
      required String inviteCode,
      Value<int?> level,
      Value<int?> nextExp,
      Value<String?> levelName,
      Value<String?> token,
      Value<String?> avatar,
      Value<String?> phone,
      Value<String?> bio,
      Value<String?> cover,
      required String nickname,
      Value<int?> fansCount,
      Value<int?> followCount,
      Value<int?> likeCount,
      Value<bool> isFollowed,
      Value<int> rowid,
    });
typedef $$UserInfosTableUpdateCompanionBuilder =
    UserInfosCompanion Function({
      Value<String> id,
      Value<String> displayId,
      Value<String?> username,
      Value<String> credential,
      Value<bool> isVisitor,
      Value<bool> isBindPass,
      Value<int> agentId,
      Value<String> inviteCode,
      Value<int?> level,
      Value<int?> nextExp,
      Value<String?> levelName,
      Value<String?> token,
      Value<String?> avatar,
      Value<String?> phone,
      Value<String?> bio,
      Value<String?> cover,
      Value<String> nickname,
      Value<int?> fansCount,
      Value<int?> followCount,
      Value<int?> likeCount,
      Value<bool> isFollowed,
      Value<int> rowid,
    });

class $$UserInfosTableFilterComposer
    extends Composer<_$AppDatabase, $UserInfosTable> {
  $$UserInfosTableFilterComposer({
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

  ColumnFilters<String> get displayId => $composableBuilder(
    column: $table.displayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credential => $composableBuilder(
    column: $table.credential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisitor => $composableBuilder(
    column: $table.isVisitor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBindPass => $composableBuilder(
    column: $table.isBindPass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextExp => $composableBuilder(
    column: $table.nextExp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelName => $composableBuilder(
    column: $table.levelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fansCount => $composableBuilder(
    column: $table.fansCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get followCount => $composableBuilder(
    column: $table.followCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $UserInfosTable> {
  $$UserInfosTableOrderingComposer({
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

  ColumnOrderings<String> get displayId => $composableBuilder(
    column: $table.displayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credential => $composableBuilder(
    column: $table.credential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisitor => $composableBuilder(
    column: $table.isVisitor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBindPass => $composableBuilder(
    column: $table.isBindPass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextExp => $composableBuilder(
    column: $table.nextExp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelName => $composableBuilder(
    column: $table.levelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fansCount => $composableBuilder(
    column: $table.fansCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get followCount => $composableBuilder(
    column: $table.followCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserInfosTable> {
  $$UserInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayId =>
      $composableBuilder(column: $table.displayId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get credential => $composableBuilder(
    column: $table.credential,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisitor =>
      $composableBuilder(column: $table.isVisitor, builder: (column) => column);

  GeneratedColumn<bool> get isBindPass => $composableBuilder(
    column: $table.isBindPass,
    builder: (column) => column,
  );

  GeneratedColumn<int> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get nextExp =>
      $composableBuilder(column: $table.nextExp, builder: (column) => column);

  GeneratedColumn<String> get levelName =>
      $composableBuilder(column: $table.levelName, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get fansCount =>
      $composableBuilder(column: $table.fansCount, builder: (column) => column);

  GeneratedColumn<int> get followCount => $composableBuilder(
    column: $table.followCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<bool> get isFollowed => $composableBuilder(
    column: $table.isFollowed,
    builder: (column) => column,
  );
}

class $$UserInfosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserInfosTable,
          UserInfo,
          $$UserInfosTableFilterComposer,
          $$UserInfosTableOrderingComposer,
          $$UserInfosTableAnnotationComposer,
          $$UserInfosTableCreateCompanionBuilder,
          $$UserInfosTableUpdateCompanionBuilder,
          (UserInfo, BaseReferences<_$AppDatabase, $UserInfosTable, UserInfo>),
          UserInfo,
          PrefetchHooks Function()
        > {
  $$UserInfosTableTableManager(_$AppDatabase db, $UserInfosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String> credential = const Value.absent(),
                Value<bool> isVisitor = const Value.absent(),
                Value<bool> isBindPass = const Value.absent(),
                Value<int> agentId = const Value.absent(),
                Value<String> inviteCode = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> nextExp = const Value.absent(),
                Value<String?> levelName = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int?> fansCount = const Value.absent(),
                Value<int?> followCount = const Value.absent(),
                Value<int?> likeCount = const Value.absent(),
                Value<bool> isFollowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInfosCompanion(
                id: id,
                displayId: displayId,
                username: username,
                credential: credential,
                isVisitor: isVisitor,
                isBindPass: isBindPass,
                agentId: agentId,
                inviteCode: inviteCode,
                level: level,
                nextExp: nextExp,
                levelName: levelName,
                token: token,
                avatar: avatar,
                phone: phone,
                bio: bio,
                cover: cover,
                nickname: nickname,
                fansCount: fansCount,
                followCount: followCount,
                likeCount: likeCount,
                isFollowed: isFollowed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayId,
                Value<String?> username = const Value.absent(),
                required String credential,
                required bool isVisitor,
                required bool isBindPass,
                required int agentId,
                required String inviteCode,
                Value<int?> level = const Value.absent(),
                Value<int?> nextExp = const Value.absent(),
                Value<String?> levelName = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                required String nickname,
                Value<int?> fansCount = const Value.absent(),
                Value<int?> followCount = const Value.absent(),
                Value<int?> likeCount = const Value.absent(),
                Value<bool> isFollowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInfosCompanion.insert(
                id: id,
                displayId: displayId,
                username: username,
                credential: credential,
                isVisitor: isVisitor,
                isBindPass: isBindPass,
                agentId: agentId,
                inviteCode: inviteCode,
                level: level,
                nextExp: nextExp,
                levelName: levelName,
                token: token,
                avatar: avatar,
                phone: phone,
                bio: bio,
                cover: cover,
                nickname: nickname,
                fansCount: fansCount,
                followCount: followCount,
                likeCount: likeCount,
                isFollowed: isFollowed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserInfosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserInfosTable,
      UserInfo,
      $$UserInfosTableFilterComposer,
      $$UserInfosTableOrderingComposer,
      $$UserInfosTableAnnotationComposer,
      $$UserInfosTableCreateCompanionBuilder,
      $$UserInfosTableUpdateCompanionBuilder,
      (UserInfo, BaseReferences<_$AppDatabase, $UserInfosTable, UserInfo>),
      UserInfo,
      PrefetchHooks Function()
    >;
typedef $$EmojisTableCreateCompanionBuilder =
    EmojisCompanion Function({
      Value<int> id,
      required String code,
      required String url,
      required int type,
      required int status,
      required int groupId,
      required String groupName,
      required String groupPrice,
      Value<bool> groupIsPremium,
      Value<bool> purchased,
      Value<String?> localPath,
      Value<DateTime?> downloadedAt,
      required DateTime updatedAt,
      required DateTime createdAt,
    });
typedef $$EmojisTableUpdateCompanionBuilder =
    EmojisCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> url,
      Value<int> type,
      Value<int> status,
      Value<int> groupId,
      Value<String> groupName,
      Value<String> groupPrice,
      Value<bool> groupIsPremium,
      Value<bool> purchased,
      Value<String?> localPath,
      Value<DateTime?> downloadedAt,
      Value<DateTime> updatedAt,
      Value<DateTime> createdAt,
    });

class $$EmojisTableFilterComposer
    extends Composer<_$AppDatabase, $EmojisTable> {
  $$EmojisTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupPrice => $composableBuilder(
    column: $table.groupPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get groupIsPremium => $composableBuilder(
    column: $table.groupIsPremium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get purchased => $composableBuilder(
    column: $table.purchased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmojisTableOrderingComposer
    extends Composer<_$AppDatabase, $EmojisTable> {
  $$EmojisTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupPrice => $composableBuilder(
    column: $table.groupPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get groupIsPremium => $composableBuilder(
    column: $table.groupIsPremium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get purchased => $composableBuilder(
    column: $table.purchased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmojisTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmojisTable> {
  $$EmojisTableAnnotationComposer({
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

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get groupPrice => $composableBuilder(
    column: $table.groupPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get groupIsPremium => $composableBuilder(
    column: $table.groupIsPremium,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get purchased =>
      $composableBuilder(column: $table.purchased, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EmojisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmojisTable,
          EmojiCache,
          $$EmojisTableFilterComposer,
          $$EmojisTableOrderingComposer,
          $$EmojisTableAnnotationComposer,
          $$EmojisTableCreateCompanionBuilder,
          $$EmojisTableUpdateCompanionBuilder,
          (EmojiCache, BaseReferences<_$AppDatabase, $EmojisTable, EmojiCache>),
          EmojiCache,
          PrefetchHooks Function()
        > {
  $$EmojisTableTableManager(_$AppDatabase db, $EmojisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmojisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmojisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmojisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String> groupPrice = const Value.absent(),
                Value<bool> groupIsPremium = const Value.absent(),
                Value<bool> purchased = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EmojisCompanion(
                id: id,
                code: code,
                url: url,
                type: type,
                status: status,
                groupId: groupId,
                groupName: groupName,
                groupPrice: groupPrice,
                groupIsPremium: groupIsPremium,
                purchased: purchased,
                localPath: localPath,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String url,
                required int type,
                required int status,
                required int groupId,
                required String groupName,
                required String groupPrice,
                Value<bool> groupIsPremium = const Value.absent(),
                Value<bool> purchased = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                required DateTime updatedAt,
                required DateTime createdAt,
              }) => EmojisCompanion.insert(
                id: id,
                code: code,
                url: url,
                type: type,
                status: status,
                groupId: groupId,
                groupName: groupName,
                groupPrice: groupPrice,
                groupIsPremium: groupIsPremium,
                purchased: purchased,
                localPath: localPath,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmojisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmojisTable,
      EmojiCache,
      $$EmojisTableFilterComposer,
      $$EmojisTableOrderingComposer,
      $$EmojisTableAnnotationComposer,
      $$EmojisTableCreateCompanionBuilder,
      $$EmojisTableUpdateCompanionBuilder,
      (EmojiCache, BaseReferences<_$AppDatabase, $EmojisTable, EmojiCache>),
      EmojiCache,
      PrefetchHooks Function()
    >;
typedef $$EmojiSyncMetadataTableCreateCompanionBuilder =
    EmojiSyncMetadataCompanion Function({
      Value<int> type,
      required DateTime lastSyncAt,
      Value<int> totalCount,
    });
typedef $$EmojiSyncMetadataTableUpdateCompanionBuilder =
    EmojiSyncMetadataCompanion Function({
      Value<int> type,
      Value<DateTime> lastSyncAt,
      Value<int> totalCount,
    });

class $$EmojiSyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $EmojiSyncMetadataTable> {
  $$EmojiSyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmojiSyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $EmojiSyncMetadataTable> {
  $$EmojiSyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmojiSyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmojiSyncMetadataTable> {
  $$EmojiSyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );
}

class $$EmojiSyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmojiSyncMetadataTable,
          EmojiSyncMeta,
          $$EmojiSyncMetadataTableFilterComposer,
          $$EmojiSyncMetadataTableOrderingComposer,
          $$EmojiSyncMetadataTableAnnotationComposer,
          $$EmojiSyncMetadataTableCreateCompanionBuilder,
          $$EmojiSyncMetadataTableUpdateCompanionBuilder,
          (
            EmojiSyncMeta,
            BaseReferences<
              _$AppDatabase,
              $EmojiSyncMetadataTable,
              EmojiSyncMeta
            >,
          ),
          EmojiSyncMeta,
          PrefetchHooks Function()
        > {
  $$EmojiSyncMetadataTableTableManager(
    _$AppDatabase db,
    $EmojiSyncMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmojiSyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmojiSyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmojiSyncMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> type = const Value.absent(),
                Value<DateTime> lastSyncAt = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
              }) => EmojiSyncMetadataCompanion(
                type: type,
                lastSyncAt: lastSyncAt,
                totalCount: totalCount,
              ),
          createCompanionCallback:
              ({
                Value<int> type = const Value.absent(),
                required DateTime lastSyncAt,
                Value<int> totalCount = const Value.absent(),
              }) => EmojiSyncMetadataCompanion.insert(
                type: type,
                lastSyncAt: lastSyncAt,
                totalCount: totalCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmojiSyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmojiSyncMetadataTable,
      EmojiSyncMeta,
      $$EmojiSyncMetadataTableFilterComposer,
      $$EmojiSyncMetadataTableOrderingComposer,
      $$EmojiSyncMetadataTableAnnotationComposer,
      $$EmojiSyncMetadataTableCreateCompanionBuilder,
      $$EmojiSyncMetadataTableUpdateCompanionBuilder,
      (
        EmojiSyncMeta,
        BaseReferences<_$AppDatabase, $EmojiSyncMetadataTable, EmojiSyncMeta>,
      ),
      EmojiSyncMeta,
      PrefetchHooks Function()
    >;
typedef $$ImagesTableCreateCompanionBuilder =
    ImagesCompanion Function({
      required String url,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$ImagesTableUpdateCompanionBuilder =
    ImagesCompanion Function({
      Value<String> url,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$ImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagesTable,
          ImageCache,
          $$ImagesTableFilterComposer,
          $$ImagesTableOrderingComposer,
          $$ImagesTableAnnotationComposer,
          $$ImagesTableCreateCompanionBuilder,
          $$ImagesTableUpdateCompanionBuilder,
          (ImageCache, BaseReferences<_$AppDatabase, $ImagesTable, ImageCache>),
          ImageCache,
          PrefetchHooks Function()
        > {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  ImagesCompanion(url: url, localPath: localPath, rowid: rowid),
          createCompanionCallback:
              ({
                required String url,
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion.insert(
                url: url,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagesTable,
      ImageCache,
      $$ImagesTableFilterComposer,
      $$ImagesTableOrderingComposer,
      $$ImagesTableAnnotationComposer,
      $$ImagesTableCreateCompanionBuilder,
      $$ImagesTableUpdateCompanionBuilder,
      (ImageCache, BaseReferences<_$AppDatabase, $ImagesTable, ImageCache>),
      ImageCache,
      PrefetchHooks Function()
    >;
typedef $$AudiosTableCreateCompanionBuilder =
    AudiosCompanion Function({
      required String url,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$AudiosTableUpdateCompanionBuilder =
    AudiosCompanion Function({
      Value<String> url,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$AudiosTableFilterComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudiosTableOrderingComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudiosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$AudiosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudiosTable,
          AudioCache,
          $$AudiosTableFilterComposer,
          $$AudiosTableOrderingComposer,
          $$AudiosTableAnnotationComposer,
          $$AudiosTableCreateCompanionBuilder,
          $$AudiosTableUpdateCompanionBuilder,
          (AudioCache, BaseReferences<_$AppDatabase, $AudiosTable, AudioCache>),
          AudioCache,
          PrefetchHooks Function()
        > {
  $$AudiosTableTableManager(_$AppDatabase db, $AudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AudiosCompanion(url: url, localPath: localPath, rowid: rowid),
          createCompanionCallback:
              ({
                required String url,
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiosCompanion.insert(
                url: url,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudiosTable,
      AudioCache,
      $$AudiosTableFilterComposer,
      $$AudiosTableOrderingComposer,
      $$AudiosTableAnnotationComposer,
      $$AudiosTableCreateCompanionBuilder,
      $$AudiosTableUpdateCompanionBuilder,
      (AudioCache, BaseReferences<_$AppDatabase, $AudiosTable, AudioCache>),
      AudioCache,
      PrefetchHooks Function()
    >;
typedef $$VideosTableCreateCompanionBuilder =
    VideosCompanion Function({
      required String url,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$VideosTableUpdateCompanionBuilder =
    VideosCompanion Function({
      Value<String> url,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$VideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTable,
          VideoCache,
          $$VideosTableFilterComposer,
          $$VideosTableOrderingComposer,
          $$VideosTableAnnotationComposer,
          $$VideosTableCreateCompanionBuilder,
          $$VideosTableUpdateCompanionBuilder,
          (VideoCache, BaseReferences<_$AppDatabase, $VideosTable, VideoCache>),
          VideoCache,
          PrefetchHooks Function()
        > {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  VideosCompanion(url: url, localPath: localPath, rowid: rowid),
          createCompanionCallback:
              ({
                required String url,
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion.insert(
                url: url,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTable,
      VideoCache,
      $$VideosTableFilterComposer,
      $$VideosTableOrderingComposer,
      $$VideosTableAnnotationComposer,
      $$VideosTableCreateCompanionBuilder,
      $$VideosTableUpdateCompanionBuilder,
      (VideoCache, BaseReferences<_$AppDatabase, $VideosTable, VideoCache>),
      VideoCache,
      PrefetchHooks Function()
    >;
typedef $$AgentSupportsTableCreateCompanionBuilder =
    AgentSupportsCompanion Function({
      required String id,
      Value<String?> username,
      Value<String?> loginId,
      Value<String?> password,
      Value<String?> role,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> avatar,
      Value<int> rowid,
    });
typedef $$AgentSupportsTableUpdateCompanionBuilder =
    AgentSupportsCompanion Function({
      Value<String> id,
      Value<String?> username,
      Value<String?> loginId,
      Value<String?> password,
      Value<String?> role,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> avatar,
      Value<int> rowid,
    });

class $$AgentSupportsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentSupportsTable> {
  $$AgentSupportsTableFilterComposer({
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

  ColumnFilters<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
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

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentSupportsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentSupportsTable> {
  $$AgentSupportsTableOrderingComposer({
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

  ColumnOrderings<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
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

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentSupportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentSupportsTable> {
  $$AgentSupportsTableAnnotationComposer({
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

  GeneratedColumn<String> get loginId =>
      $composableBuilder(column: $table.loginId, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);
}

class $$AgentSupportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentSupportsTable,
          AgentSupport,
          $$AgentSupportsTableFilterComposer,
          $$AgentSupportsTableOrderingComposer,
          $$AgentSupportsTableAnnotationComposer,
          $$AgentSupportsTableCreateCompanionBuilder,
          $$AgentSupportsTableUpdateCompanionBuilder,
          (
            AgentSupport,
            BaseReferences<_$AppDatabase, $AgentSupportsTable, AgentSupport>,
          ),
          AgentSupport,
          PrefetchHooks Function()
        > {
  $$AgentSupportsTableTableManager(_$AppDatabase db, $AgentSupportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentSupportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentSupportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentSupportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> loginId = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentSupportsCompanion(
                id: id,
                username: username,
                loginId: loginId,
                password: password,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                avatar: avatar,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> username = const Value.absent(),
                Value<String?> loginId = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentSupportsCompanion.insert(
                id: id,
                username: username,
                loginId: loginId,
                password: password,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                avatar: avatar,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentSupportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentSupportsTable,
      AgentSupport,
      $$AgentSupportsTableFilterComposer,
      $$AgentSupportsTableOrderingComposer,
      $$AgentSupportsTableAnnotationComposer,
      $$AgentSupportsTableCreateCompanionBuilder,
      $$AgentSupportsTableUpdateCompanionBuilder,
      (
        AgentSupport,
        BaseReferences<_$AppDatabase, $AgentSupportsTable, AgentSupport>,
      ),
      AgentSupport,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$ConversationUsersTableTableManager get conversationUsers =>
      $$ConversationUsersTableTableManager(_db, _db.conversationUsers);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$UserInfosTableTableManager get userInfos =>
      $$UserInfosTableTableManager(_db, _db.userInfos);
  $$EmojisTableTableManager get emojis =>
      $$EmojisTableTableManager(_db, _db.emojis);
  $$EmojiSyncMetadataTableTableManager get emojiSyncMetadata =>
      $$EmojiSyncMetadataTableTableManager(_db, _db.emojiSyncMetadata);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db, _db.audios);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
  $$AgentSupportsTableTableManager get agentSupports =>
      $$AgentSupportsTableTableManager(_db, _db.agentSupports);
}
