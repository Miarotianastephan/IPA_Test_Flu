import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

@JsonSerializable()
class File {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime createdAt;
  final bool wasTranscoded;

  File({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.createdAt,
    required this.wasTranscoded,
  });

  factory File.fromJson(Map<String, dynamic> json) => _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);
}
