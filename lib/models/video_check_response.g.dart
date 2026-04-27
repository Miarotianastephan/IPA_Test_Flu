// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoCheckResponse _$VideoCheckResponseFromJson(Map<String, dynamic> json) =>
    VideoCheckResponse(
      status: $enumDecode(_$VideoCheckStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$VideoCheckResponseToJson(VideoCheckResponse instance) =>
    <String, dynamic>{'status': _$VideoCheckStatusEnumMap[instance.status]!};

const _$VideoCheckStatusEnumMap = {
  VideoCheckStatus.pending: 'pending',
  VideoCheckStatus.success: 'success',
  VideoCheckStatus.paid: 'paid',
  VideoCheckStatus.failed: 'failed',
  VideoCheckStatus.expired: 'expired',
};
