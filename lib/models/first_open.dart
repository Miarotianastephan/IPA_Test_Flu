import 'package:json_annotation/json_annotation.dart';

part 'first_open.g.dart';

@JsonSerializable(explicitToJson: true)
class FirstOpen {
  final bool? attributed;
  @JsonKey(name: 'click_id')
  final String? clickId;
  final String? method;
  final int? confidence;
  @JsonKey(name: 'id_first_open')
  final int? idFirstOpen;
  @JsonKey(name: 'user_id')
  final String? userId;

  FirstOpen({
    this.attributed,
    this.clickId,
    this.method,
    this.confidence,
    this.idFirstOpen,
    this.userId,
  });

  factory FirstOpen.fromJson(Map<String, dynamic> json) =>
      _$FirstOpenFromJson(json);

  Map<String, dynamic> toJson() => _$FirstOpenToJson(this);

  FirstOpen copyWith({
    bool? attributed,
    String? clickId,
    String? method,
    int? confidence,
    int? idFirstOpen,
    String? userId,
  }) {
    return FirstOpen(
      attributed: attributed ?? this.attributed,
      clickId: clickId ?? this.clickId,
      method: method ?? this.method,
      confidence: confidence ?? this.confidence,
      idFirstOpen: idFirstOpen ?? this.idFirstOpen,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'FirstOpen(attributed: $attributed, clickId: $clickId, method: $method, confidence: $confidence, idFirstOpen: $idFirstOpen, userId: $userId)';
  }
}
