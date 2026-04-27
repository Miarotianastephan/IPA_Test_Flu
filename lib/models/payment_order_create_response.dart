import 'package:json_annotation/json_annotation.dart';

part 'payment_order_create_response.g.dart';

@JsonSerializable()
class PaymentOrderCreateResponse {
  final String orderId;
  final String payUrl;
  final String? payType;
  final DateTime expiredAt;

  PaymentOrderCreateResponse({
    required this.orderId,
    required this.payUrl,
    required this.payType,
    required this.expiredAt,
  });

  factory PaymentOrderCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentOrderCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentOrderCreateResponseToJson(this);
  bool get isValid {
    return DateTime.now().isBefore(expiredAt);
  }

  bool get requiresRedirect => payType == 'jump';
  bool get requiresQrCode => payType == 'qrcode';
}
