// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentPurchase _$ContentPurchaseFromJson(Map<String, dynamic> json) =>
    ContentPurchase(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      contentType: $enumDecode(_$ContentTypeEnumMap, json['content_type']),
      contentId: (json['content_id'] as num).toInt(),
      purchaseSource: $enumDecode(
        _$PurchaseSourceEnumMap,
        json['purchase_source'],
      ),
      price: parseDouble(json['price']),
      originalPrice: parseDoubleOrNull(json['original_price']),
      discountRate: parseDoubleOrNull(json['discount_rate']),
      isVipDiscount: json['is_vip_discount'] == null
          ? false
          : parseBool(json['is_vip_discount']),
      orderId: (json['order_id'] as num?)?.toInt(),
      walletTransactionId: (json['wallet_transaction_id'] as num?)?.toInt(),
      userVipId: (json['user_vip_id'] as num?)?.toInt(),
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ContentPurchaseToJson(ContentPurchase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'content_type': _$ContentTypeEnumMap[instance.contentType]!,
      'content_id': instance.contentId,
      'purchase_source': _$PurchaseSourceEnumMap[instance.purchaseSource]!,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'discount_rate': instance.discountRate,
      'is_vip_discount': instance.isVipDiscount,
      'order_id': instance.orderId,
      'wallet_transaction_id': instance.walletTransactionId,
      'user_vip_id': instance.userVipId,
      'purchased_at': instance.purchasedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ContentTypeEnumMap = {
  ContentType.longVideo: 'long_video',
  ContentType.shortVideo: 'short_video',
  ContentType.audio: 'audio',
  ContentType.post: 'post',
  ContentType.article: 'article',
  ContentType.timePackage: 'time_package',
};

const _$PurchaseSourceEnumMap = {
  PurchaseSource.walletDebit: 'wallet_debit',
  PurchaseSource.directPayment: 'direct_payment',
  PurchaseSource.vipGrant: 'vip_grant',
  PurchaseSource.adminGrant: 'admin_grant',
};
