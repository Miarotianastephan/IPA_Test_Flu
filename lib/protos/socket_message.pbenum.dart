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

import 'package:protobuf/protobuf.dart' as $pb;

/// =========================================
/// 通用基础类型
/// =========================================
class MessageCategory extends $pb.ProtobufEnum {
  static const MessageCategory CATEGORY_UNKNOWN =
      MessageCategory._(0, _omitEnumNames ? '' : 'CATEGORY_UNKNOWN');
  static const MessageCategory CATEGORY_CONTROL =
      MessageCategory._(1, _omitEnumNames ? '' : 'CATEGORY_CONTROL');
  static const MessageCategory CATEGORY_BUSINESS =
      MessageCategory._(2, _omitEnumNames ? '' : 'CATEGORY_BUSINESS');

  static const $core.List<MessageCategory> values = <MessageCategory>[
    CATEGORY_UNKNOWN,
    CATEGORY_CONTROL,
    CATEGORY_BUSINESS,
  ];

  static final $core.List<MessageCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MessageCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageCategory._(super.value, super.name);
}

class BusinessType extends $pb.ProtobufEnum {
  static const BusinessType BUSINESS_UNKNOWN =
      BusinessType._(0, _omitEnumNames ? '' : 'BUSINESS_UNKNOWN');
  static const BusinessType BUSINESS_IM =
      BusinessType._(1, _omitEnumNames ? '' : 'BUSINESS_IM');
  static const BusinessType BUSINESS_SYSTEM =
      BusinessType._(2, _omitEnumNames ? '' : 'BUSINESS_SYSTEM');
  static const BusinessType BUSINESS_LIVE =
      BusinessType._(3, _omitEnumNames ? '' : 'BUSINESS_LIVE');

  static const $core.List<BusinessType> values = <BusinessType>[
    BUSINESS_UNKNOWN,
    BUSINESS_IM,
    BUSINESS_SYSTEM,
    BUSINESS_LIVE,
  ];

  static final $core.List<BusinessType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static BusinessType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BusinessType._(super.value, super.name);
}

class ControlType extends $pb.ProtobufEnum {
  static const ControlType CONTROL_UNKNOWN =
      ControlType._(0, _omitEnumNames ? '' : 'CONTROL_UNKNOWN');
  static const ControlType CONTROL_HANDSHAKE =
      ControlType._(1, _omitEnumNames ? '' : 'CONTROL_HANDSHAKE');
  static const ControlType CONTROL_HEARTBEAT =
      ControlType._(2, _omitEnumNames ? '' : 'CONTROL_HEARTBEAT');
  static const ControlType CONTROL_ACK =
      ControlType._(3, _omitEnumNames ? '' : 'CONTROL_ACK');

  static const $core.List<ControlType> values = <ControlType>[
    CONTROL_UNKNOWN,
    CONTROL_HANDSHAKE,
    CONTROL_HEARTBEAT,
    CONTROL_ACK,
  ];

  static final $core.List<ControlType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ControlType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ControlType._(super.value, super.name);
}

class TargetScope extends $pb.ProtobufEnum {
  static const TargetScope SCOPE_UNKNOWN =
      TargetScope._(0, _omitEnumNames ? '' : 'SCOPE_UNKNOWN');
  static const TargetScope SCOPE_USER =
      TargetScope._(1, _omitEnumNames ? '' : 'SCOPE_USER');
  static const TargetScope SCOPE_GROUP =
      TargetScope._(2, _omitEnumNames ? '' : 'SCOPE_GROUP');
  static const TargetScope SCOPE_ROOM =
      TargetScope._(3, _omitEnumNames ? '' : 'SCOPE_ROOM');
  static const TargetScope SCOPE_ALL =
      TargetScope._(4, _omitEnumNames ? '' : 'SCOPE_ALL');

  static const $core.List<TargetScope> values = <TargetScope>[
    SCOPE_UNKNOWN,
    SCOPE_USER,
    SCOPE_GROUP,
    SCOPE_ROOM,
    SCOPE_ALL,
  ];

  static final $core.List<TargetScope?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TargetScope? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TargetScope._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
