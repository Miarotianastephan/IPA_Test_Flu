import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/audio_cache.dart';
import '../models/conversation.dart';
import '../models/conversation_user.dart';
import '../models/emoji_cache.dart';
import '../models/image_cache.dart';
import '../models/message.dart';
import '../models/userinfo.dart';
import '../models/video_cache.dart';

///////////////////////////////////////////////////////////////////////////
//  CONVERSATIONS TABLE
///////////////////////////////////////////////////////////////////////////

@UseRowClass(Conversation)
class Conversations extends Table {
  IntColumn get id => integer()(); // 不 autoIncrement，使用后端 id
  TextColumn get name => text().nullable()();

  TextColumn get type => text()();

  IntColumn get lastMessageId =>
      integer().nullable().named('last_message_id')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  IntColumn get unreadCount =>
      integer().named('unread_count').withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

///////////////////////////////////////////////////////////////////////////
//  CONVERSATION USERS TABLE
///////////////////////////////////////////////////////////////////////////

@UseRowClass(ConversationUser)
class ConversationUsers extends Table {
  IntColumn get id => integer()();

  IntColumn get conversationId => integer().named('conversation_id')();

  IntColumn get userId => integer().named('user_id')();

  TextColumn get role => text().withDefault(const Constant('member'))();

  DateTimeColumn get joinedAt => dateTime().named('joined_at')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

///////////////////////////////////////////////////////////////////////////
//  MESSAGES TABLE
///////////////////////////////////////////////////////////////////////////

class _JsonConverter extends TypeConverter<Map<String, dynamic>?, String> {
  const _JsonConverter();

  @override
  Map<String, dynamic>? fromSql(String fromDb) {
    try {
      return fromDb.isEmpty
          ? null
          : Map<String, dynamic>.from(jsonDecode(fromDb));
    } catch (_) {
      return null;
    }
  }

  @override
  String toSql(Map<String, dynamic>? value) {
    return value == null ? '' : jsonEncode(value);
  }
}

@UseRowClass(Message)
class Messages extends Table {
  IntColumn get id => integer()();

  IntColumn get conversationId => integer().named('conversation_id')();

  IntColumn get senderId => integer().named('sender_id')();

  TextColumn get content => text()();

  TextColumn get messageType => text().named('message_type')();

  BoolColumn get isRevoked => boolean().named('is_revoked')();

  BoolColumn get isRead =>
      boolean().named('is_read').withDefault(const Constant(false))();

  TextColumn get mediaUrl => text().nullable().named('media_url')();

  TextColumn get thumbnail => text().nullable()();

  IntColumn get duration => integer().nullable()();

  // 用 JSON 转换器来保存 extra

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().nullable().named('updated_at')();

  BoolColumn get isSelf =>
      boolean().named('is_self').withDefault(const Constant(false))();

  BoolColumn get sendFailed =>
      boolean().named('send_failed').withDefault(const Constant(false))();

  DateTimeColumn get revokedAt => dateTime().nullable().named('revoked_at')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

///////////////////////////////////////////////////////////////////////////
//  USER INFO TABLE
///////////////////////////////////////////////////////////////////////////

@UseRowClass(UserInfo)
class UserInfos extends Table {
  IntColumn get id => integer()();

  IntColumn get displayId => integer().named('display_id')();

  TextColumn get username => text().nullable()();

  TextColumn get credential => text()();

  BoolColumn get isVisitor => boolean().named('is_visitor')();

  BoolColumn get isBindPass => boolean().named('is_bind_pass')();

  IntColumn get agentId => integer().named('agent_id')();

  TextColumn get inviteCode => text().named('invite_code')();

  IntColumn get level => integer().nullable()();

  IntColumn get nextExp => integer().nullable().named('next_exp')();

  TextColumn get levelName => text().nullable().named('level_name')();

  TextColumn get token => text().nullable()();

  TextColumn get avatar => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get bio => text().nullable()();

  TextColumn get cover => text().nullable()();

  TextColumn get nickname => text().named('nickname')();

  IntColumn get fansCount => integer().nullable().named('fans_count')();

  IntColumn get followCount => integer().nullable().named('follow_count')();

  IntColumn get likeCount => integer().nullable().named('like_count')();

  BoolColumn get isFollowed =>
      boolean().named('is_followed').withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

///////////////////////////////////////////////////////////////////////////
//  EMOJIS TABLE - Local cache for emoji/GIF metadata
///////////////////////////////////////////////////////////////////////////

@UseRowClass(EmojiCache)
class Emojis extends Table {
  IntColumn get id => integer()(); // Backend ID

  TextColumn get code => text()(); // Emoji code (e.g., ^*#*emoji_001*#*^)

  TextColumn get url => text()(); // Original URL from API

  IntColumn get type => integer()(); // 1 = emoji, 2 = gif

  IntColumn get status => integer()();

  IntColumn get groupId => integer().named('group_id')();

  TextColumn get groupName => text().named('group_name')();

  TextColumn get groupPrice => text().named('group_price')();

  BoolColumn get groupIsPremium =>
      boolean().named('group_is_premium').withDefault(const Constant(false))();

  BoolColumn get purchased => boolean().withDefault(const Constant(false))();

  TextColumn get localPath =>
      text().nullable().named('local_path')(); // Local file path

  DateTimeColumn get downloadedAt => dateTime().nullable().named(
    'downloaded_at',
  )(); // When file was downloaded

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at')(); // Last API update

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

///////////////////////////////////////////////////////////////////////////
//  EMOJI SYNC METADATA - Track last sync time per type
///////////////////////////////////////////////////////////////////////////

@UseRowClass(EmojiSyncMeta)
class EmojiSyncMetadata extends Table {
  IntColumn get type => integer()(); // 1 = emoji, 2 = gif

  DateTimeColumn get lastSyncAt => dateTime().named('last_sync_at')();

  IntColumn get totalCount =>
      integer().named('total_count').withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {type};
}

///////////////////////////////////////////////////////////////////////////
//  IMAGES TABLE - Local cache for image metadata
///////////////////////////////////////////////////////////////////////////

@UseRowClass(ImageCache)
class Images extends Table {
  TextColumn get url => text()(); // URL as primary key

  TextColumn get localPath => text().nullable().named(
    'local_path',
  )(); // Local file path (deprecated, kept for compatibility if needed)

  @override
  Set<Column<Object>>? get primaryKey => {url};
}

///////////////////////////////////////////////////////////////////////////
//  AUDIOS TABLE - Local cache for audio metadata
///////////////////////////////////////////////////////////////////////////

@UseRowClass(AudioCache)
class Audios extends Table {
  TextColumn get url => text()(); // URL as primary key

  TextColumn get localPath =>
      text().nullable().named('local_path')(); // Local file path
  @override
  Set<Column<Object>>? get primaryKey => {url};
}
///////////////////////////////////////////////////////////////////////////
//  VIDEOS TABLE - Local cache for video metadata
///////////////////////////////////////////////////////////////////////////

@UseRowClass(VideoCache)
class Videos extends Table {
  TextColumn get url => text()(); // URL as primary key

  TextColumn get localPath => text().nullable().named('local_path')();

  @override
  Set<Column<Object>>? get primaryKey => {url};
}
