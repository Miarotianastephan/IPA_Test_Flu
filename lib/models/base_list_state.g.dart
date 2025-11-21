// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_list_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseListState<T> _$BaseListStateFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseListState<T>(
  list: (json['list'] as List<dynamic>?)?.map(fromJsonT).toList(),
  page: (json['page'] as num?)?.toInt() ?? 1,
  total: (json['total'] as num?)?.toInt() ?? 0,
  loading: json['loading'] == null ? false : parseBool(json['loading']),
  finished: json['finished'] == null ? false : parseBool(json['finished']),
);

Map<String, dynamic> _$BaseListStateToJson<T>(
  BaseListState<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'list': instance.list.map(toJsonT).toList(),
  'page': instance.page,
  'total': instance.total,
  'loading': instance.loading,
  'finished': instance.finished,
};
