import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResponse({required this.code, required this.msg, this.data});

  // 自动生成的辅助构造函数
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  bool get success => code == 200; 
  bool get hasData => data != null;
}


// class ApiResponse<T> {
//   final int code;
//   final String msg;
//   final T? data; // 改成可空
//
//   ApiResponse({required this.code, required this.msg, this.data});
//
//   factory ApiResponse.fromJson(
//       Map<String, dynamic> json,
//       T Function(dynamic)? fromJsonT,
//       ) {
//     return ApiResponse<T>(
//       code: json['code'] as int,
//       msg: json['msg'] as String,
//       data: (json['data'] != null)
//           ? (fromJsonT != null
//           ? fromJsonT(json['data'])
//           : json['data'] as T)
//           : null,
//     );
//   }
// }