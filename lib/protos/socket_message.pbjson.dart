// This is a generated file - do not edit.
//
// Generated from socket_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageCategoryDescriptor instead')
const MessageCategory$json = {
  '1': 'MessageCategory',
  '2': [
    {'1': 'CATEGORY_UNKNOWN', '2': 0},
    {'1': 'CATEGORY_CONTROL', '2': 1},
    {'1': 'CATEGORY_BUSINESS', '2': 2},
  ],
};

/// Descriptor for `MessageCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageCategoryDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlQ2F0ZWdvcnkSFAoQQ0FURUdPUllfVU5LTk9XThAAEhQKEENBVEVHT1JZX0NPTl'
    'RST0wQARIVChFDQVRFR09SWV9CVVNJTkVTUxAC');

@$core.Deprecated('Use businessTypeDescriptor instead')
const BusinessType$json = {
  '1': 'BusinessType',
  '2': [
    {'1': 'BUSINESS_UNKNOWN', '2': 0},
    {'1': 'BUSINESS_IM', '2': 1},
    {'1': 'BUSINESS_SYSTEM', '2': 2},
    {'1': 'BUSINESS_LIVE', '2': 3},
  ],
};

/// Descriptor for `BusinessType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List businessTypeDescriptor = $convert.base64Decode(
    'CgxCdXNpbmVzc1R5cGUSFAoQQlVTSU5FU1NfVU5LTk9XThAAEg8KC0JVU0lORVNTX0lNEAESEw'
    'oPQlVTSU5FU1NfU1lTVEVNEAISEQoNQlVTSU5FU1NfTElWRRAD');

@$core.Deprecated('Use controlTypeDescriptor instead')
const ControlType$json = {
  '1': 'ControlType',
  '2': [
    {'1': 'CONTROL_UNKNOWN', '2': 0},
    {'1': 'CONTROL_HANDSHAKE', '2': 1},
    {'1': 'CONTROL_HEARTBEAT', '2': 2},
    {'1': 'CONTROL_ACK', '2': 3},
  ],
};

/// Descriptor for `ControlType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List controlTypeDescriptor = $convert.base64Decode(
    'CgtDb250cm9sVHlwZRITCg9DT05UUk9MX1VOS05PV04QABIVChFDT05UUk9MX0hBTkRTSEFLRR'
    'ABEhUKEUNPTlRST0xfSEVBUlRCRUFUEAISDwoLQ09OVFJPTF9BQ0sQAw==');

@$core.Deprecated('Use targetScopeDescriptor instead')
const TargetScope$json = {
  '1': 'TargetScope',
  '2': [
    {'1': 'SCOPE_UNKNOWN', '2': 0},
    {'1': 'SCOPE_USER', '2': 1},
    {'1': 'SCOPE_GROUP', '2': 2},
    {'1': 'SCOPE_ROOM', '2': 3},
    {'1': 'SCOPE_ALL', '2': 4},
  ],
};

/// Descriptor for `TargetScope`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List targetScopeDescriptor = $convert.base64Decode(
    'CgtUYXJnZXRTY29wZRIRCg1TQ09QRV9VTktOT1dOEAASDgoKU0NPUEVfVVNFUhABEg8KC1NDT1'
    'BFX0dST1VQEAISDgoKU0NPUEVfUk9PTRADEg0KCVNDT1BFX0FMTBAE');

@$core.Deprecated('Use messageMetaDescriptor instead')
const MessageMeta$json = {
  '1': 'MessageMeta',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'from_user', '3': 2, '4': 1, '5': 4, '10': 'fromUser'},
    {'1': 'to_target', '3': 3, '4': 1, '5': 4, '10': 'toTarget'},
    {
      '1': 'scope',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.socket.TargetScope',
      '10': 'scope'
    },
    {'1': 'node_id', '3': 5, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'trace_id', '3': 7, '4': 1, '5': 9, '10': 'traceId'},
    {'1': 'version', '3': 8, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'category',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.socket.MessageCategory',
      '10': 'category'
    },
  ],
};

/// Descriptor for `MessageMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageMetaDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlTWV0YRIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSGwoJZnJvbV91c2'
    'VyGAIgASgEUghmcm9tVXNlchIbCgl0b190YXJnZXQYAyABKARSCHRvVGFyZ2V0EikKBXNjb3Bl'
    'GAQgASgOMhMuc29ja2V0LlRhcmdldFNjb3BlUgVzY29wZRIXCgdub2RlX2lkGAUgASgJUgZub2'
    'RlSWQSHAoJdGltZXN0YW1wGAYgASgDUgl0aW1lc3RhbXASGQoIdHJhY2VfaWQYByABKAlSB3Ry'
    'YWNlSWQSGAoHdmVyc2lvbhgIIAEoBVIHdmVyc2lvbhIzCghjYXRlZ29yeRgJIAEoDjIXLnNvY2'
    'tldC5NZXNzYWdlQ2F0ZWdvcnlSCGNhdGVnb3J5');

@$core.Deprecated('Use handshakeDescriptor instead')
const Handshake$json = {
  '1': 'Handshake',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'client_version', '3': 2, '4': 1, '5': 9, '10': 'clientVersion'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `Handshake`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handshakeDescriptor = $convert.base64Decode(
    'CglIYW5kc2hha2USFAoFdG9rZW4YASABKAlSBXRva2VuEiUKDmNsaWVudF92ZXJzaW9uGAIgAS'
    'gJUg1jbGllbnRWZXJzaW9uEhoKCHBsYXRmb3JtGAMgASgJUghwbGF0Zm9ybRIbCglkZXZpY2Vf'
    'aWQYBCABKAlSCGRldmljZUlk');

@$core.Deprecated('Use heartbeatDescriptor instead')
const Heartbeat$json = {
  '1': 'Heartbeat',
  '2': [
    {'1': 'seq', '3': 1, '4': 1, '5': 3, '10': 'seq'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `Heartbeat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatDescriptor = $convert.base64Decode(
    'CglIZWFydGJlYXQSEAoDc2VxGAEgASgDUgNzZXESHAoJdGltZXN0YW1wGAIgASgDUgl0aW1lc3'
    'RhbXA=');

@$core.Deprecated('Use ackDescriptor instead')
const Ack$json = {
  '1': 'Ack',
  '2': [
    {'1': 'ack_id', '3': 1, '4': 1, '5': 9, '10': 'ackId'},
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `Ack`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackDescriptor = $convert.base64Decode(
    'CgNBY2sSFQoGYWNrX2lkGAEgASgJUgVhY2tJZBIYCgdzdWNjZXNzGAIgASgIUgdzdWNjZXNzEh'
    'YKBnJlYXNvbhgDIAEoCVIGcmVhc29uEhwKCXRpbWVzdGFtcBgEIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'content_type', '3': 2, '4': 1, '5': 9, '10': 'contentType'},
    {'1': 'mentions', '3': 3, '4': 3, '5': 4, '10': 'mentions'},
    {
      '1': 'ext',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.socket.ChatMessage.ExtEntry',
      '10': 'ext'
    },
  ],
  '3': [ChatMessage_ExtEntry$json],
};

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage_ExtEntry$json = {
  '1': 'ExtEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRISCgR0ZXh0GAEgASgJUgR0ZXh0EiEKDGNvbnRlbnRfdHlwZRgCIAEoCV'
    'ILY29udGVudFR5cGUSGgoIbWVudGlvbnMYAyADKARSCG1lbnRpb25zEi4KA2V4dBgEIAMoCzIc'
    'LnNvY2tldC5DaGF0TWVzc2FnZS5FeHRFbnRyeVIDZXh0GjYKCEV4dEVudHJ5EhAKA2tleRgBIA'
    'EoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use eventMessageDescriptor instead')
const EventMessage$json = {
  '1': 'EventMessage',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'actor_id', '3': 2, '4': 1, '5': 4, '10': 'actorId'},
    {'1': 'actor_name', '3': 3, '4': 1, '5': 9, '10': 'actorName'},
    {'1': 'target_id', '3': 4, '4': 1, '5': 4, '10': 'targetId'},
    {'1': 'target_name', '3': 5, '4': 1, '5': 9, '10': 'targetName'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'metadata',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.socket.EventMessage.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [EventMessage_MetadataEntry$json],
};

@$core.Deprecated('Use eventMessageDescriptor instead')
const EventMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `EventMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventMessageDescriptor = $convert.base64Decode(
    'CgxFdmVudE1lc3NhZ2USHQoKZXZlbnRfdHlwZRgBIAEoCVIJZXZlbnRUeXBlEhkKCGFjdG9yX2'
    'lkGAIgASgEUgdhY3RvcklkEh0KCmFjdG9yX25hbWUYAyABKAlSCWFjdG9yTmFtZRIbCgl0YXJn'
    'ZXRfaWQYBCABKARSCHRhcmdldElkEh8KC3RhcmdldF9uYW1lGAUgASgJUgp0YXJnZXROYW1lEi'
    'AKC2Rlc2NyaXB0aW9uGAYgASgJUgtkZXNjcmlwdGlvbhI+CghtZXRhZGF0YRgHIAMoCzIiLnNv'
    'Y2tldC5FdmVudE1lc3NhZ2UuTWV0YWRhdGFFbnRyeVIIbWV0YWRhdGEaOwoNTWV0YWRhdGFFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use botMessageDescriptor instead')
const BotMessage$json = {
  '1': 'BotMessage',
  '2': [
    {'1': 'bot_id', '3': 1, '4': 1, '5': 4, '10': 'botId'},
    {'1': 'bot_name', '3': 2, '4': 1, '5': 9, '10': 'botName'},
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {'1': 'message_type', '3': 4, '4': 1, '5': 9, '10': 'messageType'},
    {
      '1': 'metadata',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.socket.BotMessage.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [BotMessage_MetadataEntry$json],
};

@$core.Deprecated('Use botMessageDescriptor instead')
const BotMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `BotMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botMessageDescriptor = $convert.base64Decode(
    'CgpCb3RNZXNzYWdlEhUKBmJvdF9pZBgBIAEoBFIFYm90SWQSGQoIYm90X25hbWUYAiABKAlSB2'
    'JvdE5hbWUSEgoEdGV4dBgDIAEoCVIEdGV4dBIhCgxtZXNzYWdlX3R5cGUYBCABKAlSC21lc3Nh'
    'Z2VUeXBlEjwKCG1ldGFkYXRhGAUgAygLMiAuc29ja2V0LkJvdE1lc3NhZ2UuTWV0YWRhdGFFbn'
    'RyeVIIbWV0YWRhdGEaOwoNTWV0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use botCommandDescriptor instead')
const BotCommand$json = {
  '1': 'BotCommand',
  '2': [
    {'1': 'bot_id', '3': 1, '4': 1, '5': 4, '10': 'botId'},
    {'1': 'command', '3': 2, '4': 1, '5': 9, '10': 'command'},
    {
      '1': 'args',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.socket.BotCommand.ArgsEntry',
      '10': 'args'
    },
  ],
  '3': [BotCommand_ArgsEntry$json],
};

@$core.Deprecated('Use botCommandDescriptor instead')
const BotCommand_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `BotCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botCommandDescriptor = $convert.base64Decode(
    'CgpCb3RDb21tYW5kEhUKBmJvdF9pZBgBIAEoBFIFYm90SWQSGAoHY29tbWFuZBgCIAEoCVIHY2'
    '9tbWFuZBIwCgRhcmdzGAMgAygLMhwuc29ja2V0LkJvdENvbW1hbmQuQXJnc0VudHJ5UgRhcmdz'
    'GjcKCUFyZ3NFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6Aj'
    'gB');

@$core.Deprecated('Use systemNotificationDescriptor instead')
const SystemNotification$json = {
  '1': 'SystemNotification',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {'1': 'level', '3': 3, '4': 1, '5': 9, '10': 'level'},
    {
      '1': 'metadata',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.socket.SystemNotification.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [SystemNotification_MetadataEntry$json],
};

@$core.Deprecated('Use systemNotificationDescriptor instead')
const SystemNotification_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemNotificationDescriptor = $convert.base64Decode(
    'ChJTeXN0ZW1Ob3RpZmljYXRpb24SFAoFdGl0bGUYASABKAlSBXRpdGxlEhIKBGJvZHkYAiABKA'
    'lSBGJvZHkSFAoFbGV2ZWwYAyABKAlSBWxldmVsEkQKCG1ldGFkYXRhGAQgAygLMiguc29ja2V0'
    'LlN5c3RlbU5vdGlmaWNhdGlvbi5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRo7Cg1NZXRhZGF0YU'
    'VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use liveChatMessageDescriptor instead')
const LiveChatMessage$json = {
  '1': 'LiveChatMessage',
  '2': [
    {'1': 'room_id', '3': 1, '4': 1, '5': 4, '10': 'roomId'},
    {'1': 'sender_id', '3': 2, '4': 1, '5': 4, '10': 'senderId'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {'1': 'is_gift', '3': 5, '4': 1, '5': 8, '10': 'isGift'},
    {
      '1': 'ext',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.socket.LiveChatMessage.ExtEntry',
      '10': 'ext'
    },
  ],
  '3': [LiveChatMessage_ExtEntry$json],
};

@$core.Deprecated('Use liveChatMessageDescriptor instead')
const LiveChatMessage_ExtEntry$json = {
  '1': 'ExtEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `LiveChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List liveChatMessageDescriptor = $convert.base64Decode(
    'Cg9MaXZlQ2hhdE1lc3NhZ2USFwoHcm9vbV9pZBgBIAEoBFIGcm9vbUlkEhsKCXNlbmRlcl9pZB'
    'gCIAEoBFIIc2VuZGVySWQSGgoIbmlja25hbWUYAyABKAlSCG5pY2tuYW1lEhIKBHRleHQYBCAB'
    'KAlSBHRleHQSFwoHaXNfZ2lmdBgFIAEoCFIGaXNHaWZ0EjIKA2V4dBgGIAMoCzIgLnNvY2tldC'
    '5MaXZlQ2hhdE1lc3NhZ2UuRXh0RW50cnlSA2V4dBo2CghFeHRFbnRyeRIQCgNrZXkYASABKAlS'
    'A2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use controlBodyDescriptor instead')
const ControlBody$json = {
  '1': 'ControlBody',
  '2': [
    {
      '1': 'handshake',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.socket.Handshake',
      '9': 0,
      '10': 'handshake'
    },
    {
      '1': 'heartbeat',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.socket.Heartbeat',
      '9': 0,
      '10': 'heartbeat'
    },
    {
      '1': 'ack',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.socket.Ack',
      '9': 0,
      '10': 'ack'
    },
  ],
  '8': [
    {'1': 'control'},
  ],
};

/// Descriptor for `ControlBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List controlBodyDescriptor = $convert.base64Decode(
    'CgtDb250cm9sQm9keRIxCgloYW5kc2hha2UYASABKAsyES5zb2NrZXQuSGFuZHNoYWtlSABSCW'
    'hhbmRzaGFrZRIxCgloZWFydGJlYXQYAiABKAsyES5zb2NrZXQuSGVhcnRiZWF0SABSCWhlYXJ0'
    'YmVhdBIfCgNhY2sYAyABKAsyCy5zb2NrZXQuQWNrSABSA2Fja0IJCgdjb250cm9s');

@$core.Deprecated('Use iMBodyDescriptor instead')
const IMBody$json = {
  '1': 'IMBody',
  '2': [
    {
      '1': 'chat',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.socket.ChatMessage',
      '9': 0,
      '10': 'chat'
    },
    {
      '1': 'event',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.socket.EventMessage',
      '9': 0,
      '10': 'event'
    },
    {
      '1': 'bot_message',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.socket.BotMessage',
      '9': 0,
      '10': 'botMessage'
    },
    {
      '1': 'bot_command',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.socket.BotCommand',
      '9': 0,
      '10': 'botCommand'
    },
  ],
  '8': [
    {'1': 'im'},
  ],
};

/// Descriptor for `IMBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iMBodyDescriptor = $convert.base64Decode(
    'CgZJTUJvZHkSKQoEY2hhdBgBIAEoCzITLnNvY2tldC5DaGF0TWVzc2FnZUgAUgRjaGF0EiwKBW'
    'V2ZW50GAIgASgLMhQuc29ja2V0LkV2ZW50TWVzc2FnZUgAUgVldmVudBI1Cgtib3RfbWVzc2Fn'
    'ZRgDIAEoCzISLnNvY2tldC5Cb3RNZXNzYWdlSABSCmJvdE1lc3NhZ2USNQoLYm90X2NvbW1hbm'
    'QYBCABKAsyEi5zb2NrZXQuQm90Q29tbWFuZEgAUgpib3RDb21tYW5kQgQKAmlt');

@$core.Deprecated('Use businessBodyDescriptor instead')
const BusinessBody$json = {
  '1': 'BusinessBody',
  '2': [
    {
      '1': 'im',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.socket.IMBody',
      '9': 0,
      '10': 'im'
    },
    {
      '1': 'system',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.socket.SystemNotification',
      '9': 0,
      '10': 'system'
    },
    {
      '1': 'live',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.socket.LiveChatMessage',
      '9': 0,
      '10': 'live'
    },
  ],
  '8': [
    {'1': 'business'},
  ],
};

/// Descriptor for `BusinessBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List businessBodyDescriptor = $convert.base64Decode(
    'CgxCdXNpbmVzc0JvZHkSIAoCaW0YASABKAsyDi5zb2NrZXQuSU1Cb2R5SABSAmltEjQKBnN5c3'
    'RlbRgCIAEoCzIaLnNvY2tldC5TeXN0ZW1Ob3RpZmljYXRpb25IAFIGc3lzdGVtEi0KBGxpdmUY'
    'AyABKAsyFy5zb2NrZXQuTGl2ZUNoYXRNZXNzYWdlSABSBGxpdmVCCgoIYnVzaW5lc3M=');

@$core.Deprecated('Use messageBodyDescriptor instead')
const MessageBody$json = {
  '1': 'MessageBody',
  '2': [
    {
      '1': 'control',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.socket.ControlBody',
      '9': 0,
      '10': 'control'
    },
    {
      '1': 'business',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.socket.BusinessBody',
      '9': 0,
      '10': 'business'
    },
  ],
  '8': [
    {'1': 'body'},
  ],
};

/// Descriptor for `MessageBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageBodyDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlQm9keRIvCgdjb250cm9sGAEgASgLMhMuc29ja2V0LkNvbnRyb2xCb2R5SABSB2'
    'NvbnRyb2wSMgoIYnVzaW5lc3MYAiABKAsyFC5zb2NrZXQuQnVzaW5lc3NCb2R5SABSCGJ1c2lu'
    'ZXNzQgYKBGJvZHk=');

@$core.Deprecated('Use socketEnvelopeDescriptor instead')
const SocketEnvelope$json = {
  '1': 'SocketEnvelope',
  '2': [
    {
      '1': 'meta',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.socket.MessageMeta',
      '10': 'meta'
    },
    {
      '1': 'body',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.socket.MessageBody',
      '10': 'body'
    },
  ],
};

/// Descriptor for `SocketEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List socketEnvelopeDescriptor = $convert.base64Decode(
    'Cg5Tb2NrZXRFbnZlbG9wZRInCgRtZXRhGAEgASgLMhMuc29ja2V0Lk1lc3NhZ2VNZXRhUgRtZX'
    'RhEicKBGJvZHkYAiABKAsyEy5zb2NrZXQuTWVzc2FnZUJvZHlSBGJvZHk=');
