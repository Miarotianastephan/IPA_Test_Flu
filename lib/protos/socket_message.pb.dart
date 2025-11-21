// This is a generated file - do not edit.
//
// Generated from socket_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'socket_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'socket_message.pbenum.dart';

/// =========================================
/// 元信息
/// =========================================
class MessageMeta extends $pb.GeneratedMessage {
  factory MessageMeta({
    $core.String? messageId,
    $fixnum.Int64? fromUser,
    $fixnum.Int64? toTarget,
    TargetScope? scope,
    $core.String? nodeId,
    $fixnum.Int64? timestamp,
    $core.String? traceId,
    $core.int? version,
    MessageCategory? category,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (fromUser != null) result.fromUser = fromUser;
    if (toTarget != null) result.toTarget = toTarget;
    if (scope != null) result.scope = scope;
    if (nodeId != null) result.nodeId = nodeId;
    if (timestamp != null) result.timestamp = timestamp;
    if (traceId != null) result.traceId = traceId;
    if (version != null) result.version = version;
    if (category != null) result.category = category;
    return result;
  }

  MessageMeta._();

  factory MessageMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'fromUser', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'toTarget', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aE<TargetScope>(4, _omitFieldNames ? '' : 'scope',
        enumValues: TargetScope.values)
    ..aOS(5, _omitFieldNames ? '' : 'nodeId')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..aOS(7, _omitFieldNames ? '' : 'traceId')
    ..aI(8, _omitFieldNames ? '' : 'version')
    ..aE<MessageCategory>(9, _omitFieldNames ? '' : 'category',
        enumValues: MessageCategory.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageMeta copyWith(void Function(MessageMeta) updates) =>
      super.copyWith((message) => updates(message as MessageMeta))
          as MessageMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageMeta create() => MessageMeta._();
  @$core.override
  MessageMeta createEmptyInstance() => create();
  static $pb.PbList<MessageMeta> createRepeated() => $pb.PbList<MessageMeta>();
  @$core.pragma('dart2js:noInline')
  static MessageMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageMeta>(create);
  static MessageMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get fromUser => $_getI64(1);
  @$pb.TagNumber(2)
  set fromUser($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUser() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUser() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get toTarget => $_getI64(2);
  @$pb.TagNumber(3)
  set toTarget($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToTarget() => $_has(2);
  @$pb.TagNumber(3)
  void clearToTarget() => $_clearField(3);

  @$pb.TagNumber(4)
  TargetScope get scope => $_getN(3);
  @$pb.TagNumber(4)
  set scope(TargetScope value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasScope() => $_has(3);
  @$pb.TagNumber(4)
  void clearScope() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get nodeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set nodeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNodeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearNodeId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get traceId => $_getSZ(6);
  @$pb.TagNumber(7)
  set traceId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTraceId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTraceId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(7);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  MessageCategory get category => $_getN(8);
  @$pb.TagNumber(9)
  set category(MessageCategory value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCategory() => $_has(8);
  @$pb.TagNumber(9)
  void clearCategory() => $_clearField(9);
}

/// =========================================
/// 控制类消息
/// =========================================
class Handshake extends $pb.GeneratedMessage {
  factory Handshake({
    $core.String? token,
    $core.String? clientVersion,
    $core.String? platform,
    $core.String? deviceId,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (clientVersion != null) result.clientVersion = clientVersion;
    if (platform != null) result.platform = platform;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  Handshake._();

  factory Handshake.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Handshake.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Handshake',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOS(2, _omitFieldNames ? '' : 'clientVersion')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Handshake clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Handshake copyWith(void Function(Handshake) updates) =>
      super.copyWith((message) => updates(message as Handshake)) as Handshake;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Handshake create() => Handshake._();
  @$core.override
  Handshake createEmptyInstance() => create();
  static $pb.PbList<Handshake> createRepeated() => $pb.PbList<Handshake>();
  @$core.pragma('dart2js:noInline')
  static Handshake getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Handshake>(create);
  static Handshake? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => $_clearField(4);
}

class Heartbeat extends $pb.GeneratedMessage {
  factory Heartbeat({
    $fixnum.Int64? seq,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (seq != null) result.seq = seq;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  Heartbeat._();

  factory Heartbeat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Heartbeat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Heartbeat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seq')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat copyWith(void Function(Heartbeat) updates) =>
      super.copyWith((message) => updates(message as Heartbeat)) as Heartbeat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Heartbeat create() => Heartbeat._();
  @$core.override
  Heartbeat createEmptyInstance() => create();
  static $pb.PbList<Heartbeat> createRepeated() => $pb.PbList<Heartbeat>();
  @$core.pragma('dart2js:noInline')
  static Heartbeat getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Heartbeat>(create);
  static Heartbeat? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seq => $_getI64(0);
  @$pb.TagNumber(1)
  set seq($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeq() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeq() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

class Ack extends $pb.GeneratedMessage {
  factory Ack({
    $core.String? ackId,
    $core.bool? success,
    $core.String? reason,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (ackId != null) result.ackId = ackId;
    if (success != null) result.success = success;
    if (reason != null) result.reason = reason;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  Ack._();

  factory Ack.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ack.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ack',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ackId')
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ack copyWith(void Function(Ack) updates) =>
      super.copyWith((message) => updates(message as Ack)) as Ack;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ack create() => Ack._();
  @$core.override
  Ack createEmptyInstance() => create();
  static $pb.PbList<Ack> createRepeated() => $pb.PbList<Ack>();
  @$core.pragma('dart2js:noInline')
  static Ack getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ack>(create);
  static Ack? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ackId => $_getSZ(0);
  @$pb.TagNumber(1)
  set ackId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAckId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAckId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// =========================================
/// 业务类消息
/// =========================================
class ChatMessage extends $pb.GeneratedMessage {
  factory ChatMessage({
    $core.String? text,
    $core.String? contentType,
    $core.Iterable<$fixnum.Int64>? mentions,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? ext,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (contentType != null) result.contentType = contentType;
    if (mentions != null) result.mentions.addAll(mentions);
    if (ext != null) result.ext.addEntries(ext);
    return result;
  }

  ChatMessage._();

  factory ChatMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'contentType')
    ..p<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'mentions', $pb.PbFieldType.KU6)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'ext',
        entryClassName: 'ChatMessage.ExtEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage copyWith(void Function(ChatMessage) updates) =>
      super.copyWith((message) => updates(message as ChatMessage))
          as ChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage create() => ChatMessage._();
  @$core.override
  ChatMessage createEmptyInstance() => create();
  static $pb.PbList<ChatMessage> createRepeated() => $pb.PbList<ChatMessage>();
  @$core.pragma('dart2js:noInline')
  static ChatMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage>(create);
  static ChatMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get contentType => $_getSZ(1);
  @$pb.TagNumber(2)
  set contentType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContentType() => $_has(1);
  @$pb.TagNumber(2)
  void clearContentType() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$fixnum.Int64> get mentions => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get ext => $_getMap(3);
}

class EventMessage extends $pb.GeneratedMessage {
  factory EventMessage({
    $core.String? eventType,
    $fixnum.Int64? actorId,
    $core.String? actorName,
    $fixnum.Int64? targetId,
    $core.String? targetName,
    $core.String? description,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (eventType != null) result.eventType = eventType;
    if (actorId != null) result.actorId = actorId;
    if (actorName != null) result.actorName = actorName;
    if (targetId != null) result.targetId = targetId;
    if (targetName != null) result.targetName = targetName;
    if (description != null) result.description = description;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  EventMessage._();

  factory EventMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EventMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventType')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'actorId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'actorName')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'targetId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'targetName')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'EventMessage.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventMessage copyWith(void Function(EventMessage) updates) =>
      super.copyWith((message) => updates(message as EventMessage))
          as EventMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EventMessage create() => EventMessage._();
  @$core.override
  EventMessage createEmptyInstance() => create();
  static $pb.PbList<EventMessage> createRepeated() =>
      $pb.PbList<EventMessage>();
  @$core.pragma('dart2js:noInline')
  static EventMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EventMessage>(create);
  static EventMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventType => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get actorId => $_getI64(1);
  @$pb.TagNumber(2)
  set actorId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get actorName => $_getSZ(2);
  @$pb.TagNumber(3)
  set actorName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActorName() => $_has(2);
  @$pb.TagNumber(3)
  void clearActorName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get targetId => $_getI64(3);
  @$pb.TagNumber(4)
  set targetId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetName => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetName() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(6);
}

class BotMessage extends $pb.GeneratedMessage {
  factory BotMessage({
    $fixnum.Int64? botId,
    $core.String? botName,
    $core.String? text,
    $core.String? messageType,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (botId != null) result.botId = botId;
    if (botName != null) result.botName = botName;
    if (text != null) result.text = text;
    if (messageType != null) result.messageType = messageType;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  BotMessage._();

  factory BotMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'botId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'botName')
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aOS(4, _omitFieldNames ? '' : 'messageType')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'BotMessage.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotMessage copyWith(void Function(BotMessage) updates) =>
      super.copyWith((message) => updates(message as BotMessage)) as BotMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotMessage create() => BotMessage._();
  @$core.override
  BotMessage createEmptyInstance() => create();
  static $pb.PbList<BotMessage> createRepeated() => $pb.PbList<BotMessage>();
  @$core.pragma('dart2js:noInline')
  static BotMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BotMessage>(create);
  static BotMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get botId => $_getI64(0);
  @$pb.TagNumber(1)
  set botId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBotId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBotId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get botName => $_getSZ(1);
  @$pb.TagNumber(2)
  set botName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBotName() => $_has(1);
  @$pb.TagNumber(2)
  void clearBotName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get messageType => $_getSZ(3);
  @$pb.TagNumber(4)
  set messageType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessageType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessageType() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(4);
}

class BotCommand extends $pb.GeneratedMessage {
  factory BotCommand({
    $fixnum.Int64? botId,
    $core.String? command,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? args,
  }) {
    final result = create();
    if (botId != null) result.botId = botId;
    if (command != null) result.command = command;
    if (args != null) result.args.addEntries(args);
    return result;
  }

  BotCommand._();

  factory BotCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'botId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'command')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'args',
        entryClassName: 'BotCommand.ArgsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotCommand copyWith(void Function(BotCommand) updates) =>
      super.copyWith((message) => updates(message as BotCommand)) as BotCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotCommand create() => BotCommand._();
  @$core.override
  BotCommand createEmptyInstance() => create();
  static $pb.PbList<BotCommand> createRepeated() => $pb.PbList<BotCommand>();
  @$core.pragma('dart2js:noInline')
  static BotCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BotCommand>(create);
  static BotCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get botId => $_getI64(0);
  @$pb.TagNumber(1)
  set botId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBotId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBotId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get command => $_getSZ(1);
  @$pb.TagNumber(2)
  set command($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommand() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommand() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get args => $_getMap(2);
}

class SystemNotification extends $pb.GeneratedMessage {
  factory SystemNotification({
    $core.String? title,
    $core.String? body,
    $core.String? level,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (level != null) result.level = level;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  SystemNotification._();

  factory SystemNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SystemNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOS(3, _omitFieldNames ? '' : 'level')
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'SystemNotification.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemNotification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemNotification copyWith(void Function(SystemNotification) updates) =>
      super.copyWith((message) => updates(message as SystemNotification))
          as SystemNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemNotification create() => SystemNotification._();
  @$core.override
  SystemNotification createEmptyInstance() => create();
  static $pb.PbList<SystemNotification> createRepeated() =>
      $pb.PbList<SystemNotification>();
  @$core.pragma('dart2js:noInline')
  static SystemNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemNotification>(create);
  static SystemNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get level => $_getSZ(2);
  @$pb.TagNumber(3)
  set level($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(3);
}

class LiveChatMessage extends $pb.GeneratedMessage {
  factory LiveChatMessage({
    $fixnum.Int64? roomId,
    $fixnum.Int64? senderId,
    $core.String? nickname,
    $core.String? text,
    $core.bool? isGift,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? ext,
  }) {
    final result = create();
    if (roomId != null) result.roomId = roomId;
    if (senderId != null) result.senderId = senderId;
    if (nickname != null) result.nickname = nickname;
    if (text != null) result.text = text;
    if (isGift != null) result.isGift = isGift;
    if (ext != null) result.ext.addEntries(ext);
    return result;
  }

  LiveChatMessage._();

  factory LiveChatMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LiveChatMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LiveChatMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'roomId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'senderId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'nickname')
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..aOB(5, _omitFieldNames ? '' : 'isGift')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'ext',
        entryClassName: 'LiveChatMessage.ExtEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('socket'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveChatMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveChatMessage copyWith(void Function(LiveChatMessage) updates) =>
      super.copyWith((message) => updates(message as LiveChatMessage))
          as LiveChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LiveChatMessage create() => LiveChatMessage._();
  @$core.override
  LiveChatMessage createEmptyInstance() => create();
  static $pb.PbList<LiveChatMessage> createRepeated() =>
      $pb.PbList<LiveChatMessage>();
  @$core.pragma('dart2js:noInline')
  static LiveChatMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LiveChatMessage>(create);
  static LiveChatMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get roomId => $_getI64(0);
  @$pb.TagNumber(1)
  set roomId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoomId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoomId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get senderId => $_getI64(1);
  @$pb.TagNumber(2)
  set senderId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set nickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearNickname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isGift => $_getBF(4);
  @$pb.TagNumber(5)
  set isGift($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsGift() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsGift() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get ext => $_getMap(5);
}

enum ControlBody_Control { handshake, heartbeat, ack, notSet }

/// =========================================
/// 封装层
/// =========================================
class ControlBody extends $pb.GeneratedMessage {
  factory ControlBody({
    Handshake? handshake,
    Heartbeat? heartbeat,
    Ack? ack,
  }) {
    final result = create();
    if (handshake != null) result.handshake = handshake;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (ack != null) result.ack = ack;
    return result;
  }

  ControlBody._();

  factory ControlBody.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ControlBody.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ControlBody_Control>
      _ControlBody_ControlByTag = {
    1: ControlBody_Control.handshake,
    2: ControlBody_Control.heartbeat,
    3: ControlBody_Control.ack,
    0: ControlBody_Control.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ControlBody',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<Handshake>(1, _omitFieldNames ? '' : 'handshake',
        subBuilder: Handshake.create)
    ..aOM<Heartbeat>(2, _omitFieldNames ? '' : 'heartbeat',
        subBuilder: Heartbeat.create)
    ..aOM<Ack>(3, _omitFieldNames ? '' : 'ack', subBuilder: Ack.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlBody clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ControlBody copyWith(void Function(ControlBody) updates) =>
      super.copyWith((message) => updates(message as ControlBody))
          as ControlBody;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ControlBody create() => ControlBody._();
  @$core.override
  ControlBody createEmptyInstance() => create();
  static $pb.PbList<ControlBody> createRepeated() => $pb.PbList<ControlBody>();
  @$core.pragma('dart2js:noInline')
  static ControlBody getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ControlBody>(create);
  static ControlBody? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  ControlBody_Control whichControl() =>
      _ControlBody_ControlByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearControl() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Handshake get handshake => $_getN(0);
  @$pb.TagNumber(1)
  set handshake(Handshake value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHandshake() => $_has(0);
  @$pb.TagNumber(1)
  void clearHandshake() => $_clearField(1);
  @$pb.TagNumber(1)
  Handshake ensureHandshake() => $_ensure(0);

  @$pb.TagNumber(2)
  Heartbeat get heartbeat => $_getN(1);
  @$pb.TagNumber(2)
  set heartbeat(Heartbeat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasHeartbeat() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeartbeat() => $_clearField(2);
  @$pb.TagNumber(2)
  Heartbeat ensureHeartbeat() => $_ensure(1);

  @$pb.TagNumber(3)
  Ack get ack => $_getN(2);
  @$pb.TagNumber(3)
  set ack(Ack value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAck() => $_has(2);
  @$pb.TagNumber(3)
  void clearAck() => $_clearField(3);
  @$pb.TagNumber(3)
  Ack ensureAck() => $_ensure(2);
}

enum IMBody_Im { chat, event, botMessage, botCommand, notSet }

/// 统一 IMBody，包含 Chat / Event / Bot 消息
class IMBody extends $pb.GeneratedMessage {
  factory IMBody({
    ChatMessage? chat,
    EventMessage? event,
    BotMessage? botMessage,
    BotCommand? botCommand,
  }) {
    final result = create();
    if (chat != null) result.chat = chat;
    if (event != null) result.event = event;
    if (botMessage != null) result.botMessage = botMessage;
    if (botCommand != null) result.botCommand = botCommand;
    return result;
  }

  IMBody._();

  factory IMBody.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IMBody.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, IMBody_Im> _IMBody_ImByTag = {
    1: IMBody_Im.chat,
    2: IMBody_Im.event,
    3: IMBody_Im.botMessage,
    4: IMBody_Im.botCommand,
    0: IMBody_Im.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IMBody',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<ChatMessage>(1, _omitFieldNames ? '' : 'chat',
        subBuilder: ChatMessage.create)
    ..aOM<EventMessage>(2, _omitFieldNames ? '' : 'event',
        subBuilder: EventMessage.create)
    ..aOM<BotMessage>(3, _omitFieldNames ? '' : 'botMessage',
        subBuilder: BotMessage.create)
    ..aOM<BotCommand>(4, _omitFieldNames ? '' : 'botCommand',
        subBuilder: BotCommand.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IMBody clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IMBody copyWith(void Function(IMBody) updates) =>
      super.copyWith((message) => updates(message as IMBody)) as IMBody;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IMBody create() => IMBody._();
  @$core.override
  IMBody createEmptyInstance() => create();
  static $pb.PbList<IMBody> createRepeated() => $pb.PbList<IMBody>();
  @$core.pragma('dart2js:noInline')
  static IMBody getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IMBody>(create);
  static IMBody? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  IMBody_Im whichIm() => _IMBody_ImByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearIm() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ChatMessage get chat => $_getN(0);
  @$pb.TagNumber(1)
  set chat(ChatMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChat() => $_has(0);
  @$pb.TagNumber(1)
  void clearChat() => $_clearField(1);
  @$pb.TagNumber(1)
  ChatMessage ensureChat() => $_ensure(0);

  @$pb.TagNumber(2)
  EventMessage get event => $_getN(1);
  @$pb.TagNumber(2)
  set event(EventMessage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);
  @$pb.TagNumber(2)
  EventMessage ensureEvent() => $_ensure(1);

  @$pb.TagNumber(3)
  BotMessage get botMessage => $_getN(2);
  @$pb.TagNumber(3)
  set botMessage(BotMessage value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBotMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearBotMessage() => $_clearField(3);
  @$pb.TagNumber(3)
  BotMessage ensureBotMessage() => $_ensure(2);

  @$pb.TagNumber(4)
  BotCommand get botCommand => $_getN(3);
  @$pb.TagNumber(4)
  set botCommand(BotCommand value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBotCommand() => $_has(3);
  @$pb.TagNumber(4)
  void clearBotCommand() => $_clearField(4);
  @$pb.TagNumber(4)
  BotCommand ensureBotCommand() => $_ensure(3);
}

enum BusinessBody_Business { im, system, live, notSet }

class BusinessBody extends $pb.GeneratedMessage {
  factory BusinessBody({
    IMBody? im,
    SystemNotification? system,
    LiveChatMessage? live,
  }) {
    final result = create();
    if (im != null) result.im = im;
    if (system != null) result.system = system;
    if (live != null) result.live = live;
    return result;
  }

  BusinessBody._();

  factory BusinessBody.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BusinessBody.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, BusinessBody_Business>
      _BusinessBody_BusinessByTag = {
    1: BusinessBody_Business.im,
    2: BusinessBody_Business.system,
    3: BusinessBody_Business.live,
    0: BusinessBody_Business.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BusinessBody',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<IMBody>(1, _omitFieldNames ? '' : 'im', subBuilder: IMBody.create)
    ..aOM<SystemNotification>(2, _omitFieldNames ? '' : 'system',
        subBuilder: SystemNotification.create)
    ..aOM<LiveChatMessage>(3, _omitFieldNames ? '' : 'live',
        subBuilder: LiveChatMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BusinessBody clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BusinessBody copyWith(void Function(BusinessBody) updates) =>
      super.copyWith((message) => updates(message as BusinessBody))
          as BusinessBody;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BusinessBody create() => BusinessBody._();
  @$core.override
  BusinessBody createEmptyInstance() => create();
  static $pb.PbList<BusinessBody> createRepeated() =>
      $pb.PbList<BusinessBody>();
  @$core.pragma('dart2js:noInline')
  static BusinessBody getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BusinessBody>(create);
  static BusinessBody? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  BusinessBody_Business whichBusiness() =>
      _BusinessBody_BusinessByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearBusiness() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  IMBody get im => $_getN(0);
  @$pb.TagNumber(1)
  set im(IMBody value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIm() => $_has(0);
  @$pb.TagNumber(1)
  void clearIm() => $_clearField(1);
  @$pb.TagNumber(1)
  IMBody ensureIm() => $_ensure(0);

  @$pb.TagNumber(2)
  SystemNotification get system => $_getN(1);
  @$pb.TagNumber(2)
  set system(SystemNotification value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSystem() => $_has(1);
  @$pb.TagNumber(2)
  void clearSystem() => $_clearField(2);
  @$pb.TagNumber(2)
  SystemNotification ensureSystem() => $_ensure(1);

  @$pb.TagNumber(3)
  LiveChatMessage get live => $_getN(2);
  @$pb.TagNumber(3)
  set live(LiveChatMessage value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLive() => $_has(2);
  @$pb.TagNumber(3)
  void clearLive() => $_clearField(3);
  @$pb.TagNumber(3)
  LiveChatMessage ensureLive() => $_ensure(2);
}

enum MessageBody_Body { control, business, notSet }

class MessageBody extends $pb.GeneratedMessage {
  factory MessageBody({
    ControlBody? control,
    BusinessBody? business,
  }) {
    final result = create();
    if (control != null) result.control = control;
    if (business != null) result.business = business;
    return result;
  }

  MessageBody._();

  factory MessageBody.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageBody.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MessageBody_Body> _MessageBody_BodyByTag = {
    1: MessageBody_Body.control,
    2: MessageBody_Body.business,
    0: MessageBody_Body.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageBody',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ControlBody>(1, _omitFieldNames ? '' : 'control',
        subBuilder: ControlBody.create)
    ..aOM<BusinessBody>(2, _omitFieldNames ? '' : 'business',
        subBuilder: BusinessBody.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageBody clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageBody copyWith(void Function(MessageBody) updates) =>
      super.copyWith((message) => updates(message as MessageBody))
          as MessageBody;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageBody create() => MessageBody._();
  @$core.override
  MessageBody createEmptyInstance() => create();
  static $pb.PbList<MessageBody> createRepeated() => $pb.PbList<MessageBody>();
  @$core.pragma('dart2js:noInline')
  static MessageBody getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageBody>(create);
  static MessageBody? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  MessageBody_Body whichBody() => _MessageBody_BodyByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearBody() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ControlBody get control => $_getN(0);
  @$pb.TagNumber(1)
  set control(ControlBody value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasControl() => $_has(0);
  @$pb.TagNumber(1)
  void clearControl() => $_clearField(1);
  @$pb.TagNumber(1)
  ControlBody ensureControl() => $_ensure(0);

  @$pb.TagNumber(2)
  BusinessBody get business => $_getN(1);
  @$pb.TagNumber(2)
  set business(BusinessBody value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBusiness() => $_has(1);
  @$pb.TagNumber(2)
  void clearBusiness() => $_clearField(2);
  @$pb.TagNumber(2)
  BusinessBody ensureBusiness() => $_ensure(1);
}

class SocketEnvelope extends $pb.GeneratedMessage {
  factory SocketEnvelope({
    MessageMeta? meta,
    MessageBody? body,
  }) {
    final result = create();
    if (meta != null) result.meta = meta;
    if (body != null) result.body = body;
    return result;
  }

  SocketEnvelope._();

  factory SocketEnvelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SocketEnvelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SocketEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'socket'),
      createEmptyInstance: create)
    ..aOM<MessageMeta>(1, _omitFieldNames ? '' : 'meta',
        subBuilder: MessageMeta.create)
    ..aOM<MessageBody>(2, _omitFieldNames ? '' : 'body',
        subBuilder: MessageBody.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SocketEnvelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SocketEnvelope copyWith(void Function(SocketEnvelope) updates) =>
      super.copyWith((message) => updates(message as SocketEnvelope))
          as SocketEnvelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SocketEnvelope create() => SocketEnvelope._();
  @$core.override
  SocketEnvelope createEmptyInstance() => create();
  static $pb.PbList<SocketEnvelope> createRepeated() =>
      $pb.PbList<SocketEnvelope>();
  @$core.pragma('dart2js:noInline')
  static SocketEnvelope getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SocketEnvelope>(create);
  static SocketEnvelope? _defaultInstance;

  @$pb.TagNumber(1)
  MessageMeta get meta => $_getN(0);
  @$pb.TagNumber(1)
  set meta(MessageMeta value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMeta() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeta() => $_clearField(1);
  @$pb.TagNumber(1)
  MessageMeta ensureMeta() => $_ensure(0);

  @$pb.TagNumber(2)
  MessageBody get body => $_getN(1);
  @$pb.TagNumber(2)
  set body(MessageBody value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);
  @$pb.TagNumber(2)
  MessageBody ensureBody() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
