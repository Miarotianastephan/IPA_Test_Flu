import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'base_list_state.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseListState<T> {
  static const int maxVideosInMemory = 100;

  final List<T> list;
  final int page;
  final int total;
  @JsonKey(fromJson: parseBool)
  final bool loading;
  @JsonKey(fromJson: parseBool)
  final bool finished;
  final int offset;

  BaseListState({
    List<T>? list,
    this.page = 1,
    this.total = 0,
    this.loading = false,
    this.finished = false,
    this.offset = 0,
  }) : list = list ?? <T>[];

  BaseListState<T> copyWith({
    List<T>? list,
    int? page,
    int? total,
    bool? loading,
    bool? finished,
    int? offset,
  }) {
    return BaseListState<T>(
      list: list ?? this.list,
      page: page ?? this.page,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      finished: finished ?? this.finished,
      offset: offset ?? this.offset,
    );
  }

  factory BaseListState.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$BaseListStateFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$BaseListStateToJson(this, toJsonT);
}
