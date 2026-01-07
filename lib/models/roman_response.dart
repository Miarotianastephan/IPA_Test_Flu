import 'package:live_app/models/roman.dart';

class RomanResponse {
  final bool isForce;
  final List<Roman> roman;

  RomanResponse({required this.isForce, required this.roman});

  factory RomanResponse.fromJson(Map<String, dynamic> json) {
    return RomanResponse(
      isForce: json['isForce'] ?? false,
      roman: (json['roman'] as List<dynamic>)
          .map((e) => Roman.fromJson(e))
          .toList(),
    );
  }
}
