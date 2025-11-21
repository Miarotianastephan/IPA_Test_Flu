import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'base_list_state.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseListState<T> {
  final List<T> list;
  final int page;
  final int total;
  @JsonKey(fromJson: parseBool)
  final bool loading;
  @JsonKey(fromJson: parseBool)
  final bool finished;

  BaseListState({
    List<T>? list,
    this.page = 1,
    this.total = 0,
    this.loading = false,
    this.finished = false,
  }) : list = list ?? <T>[];

  BaseListState<T> copyWith({
    List<T>? list,
    int? page,
    int? total,
    bool? loading,
    bool? finished,
  }) {
    return BaseListState<T>(
      list: list ?? this.list,
      page: page ?? this.page,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      finished: finished ?? this.finished,
    );
  }

  factory BaseListState.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$BaseListStateFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$BaseListStateToJson(this, toJsonT);
}


// class BaseListState<T> {
//   final List<T> list;
//   final int page;
//   final int total;
//   final bool loading;
//   final bool finished;
//
//   BaseListState({
//     List<T>? list,
//     this.page = 1,
//     this.total = 0,
//     this.loading = false,
//     this.finished = false,
//   }) : list = list ?? <T>[];
//
//
//   BaseListState<T> copyWith({
//     List<T>? list,
//     int? page,
//     int? total,
//     bool? loading,
//     bool? finished,
//   }) {
//     return BaseListState<T>(
//       list: list ?? this.list,
//       page: page ?? this.page,
//       total: total ?? this.total,
//       loading: loading ?? this.loading,
//       finished: finished ?? this.finished,
//     );
//   }
// }