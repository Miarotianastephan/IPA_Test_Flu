import 'package:live_app/models/emoji.dart';
import 'package:live_app/models/emoji_group.dart';

/// Model for cached emoji data in local database
class EmojiCache {
  final int id;
  final String code;
  final String url;
  final int type;
  final int status;
  final int groupId;
  final String groupName;
  final String groupPrice;
  final bool groupIsPremium;
  final bool purchased;
  final String? localPath;
  final DateTime? downloadedAt;
  final DateTime updatedAt;
  final DateTime createdAt;

  EmojiCache({
    required this.id,
    required this.code,
    required this.url,
    required this.type,
    required this.status,
    required this.groupId,
    required this.groupName,
    required this.groupPrice,
    required this.groupIsPremium,
    required this.purchased,
    this.localPath,
    this.downloadedAt,
    required this.updatedAt,
    required this.createdAt,
  });

  /// Convert from API Emoji model to DB cache model
  factory EmojiCache.fromEmoji(Emoji emoji) {
    return EmojiCache(
      id: emoji.id,
      code: emoji.code,
      url: emoji.url,
      type: emoji.type,
      status: emoji.status,
      groupId: emoji.group.id,
      groupName: emoji.group.name,
      groupPrice: emoji.group.price,
      groupIsPremium: emoji.group.isPremium,
      purchased: emoji.purchased,
      localPath: null, // Will be set when file is downloaded
      downloadedAt: null,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Convert from DB cache model to API Emoji model
  Emoji toEmoji() {
    return Emoji(
      id: id,
      code: code,
      url: localPath ?? url, // Use local path if available, otherwise API URL
      type: type,
      status: status,
      group: EmojiGroup(
        id: groupId,
        name: groupName,
        price: groupPrice,
        isPremium: groupIsPremium,
      ),
      purchased: purchased,
    );
  }

  /// Check if the emoji file is downloaded locally
  bool get isDownloaded => localPath != null && downloadedAt != null;

  EmojiCache copyWith({
    int? id,
    String? code,
    String? url,
    int? type,
    int? status,
    int? groupId,
    String? groupName,
    String? groupPrice,
    bool? groupIsPremium,
    bool? purchased,
    String? localPath,
    DateTime? downloadedAt,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return EmojiCache(
      id: id ?? this.id,
      code: code ?? this.code,
      url: url ?? this.url,
      type: type ?? this.type,
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupPrice: groupPrice ?? this.groupPrice,
      groupIsPremium: groupIsPremium ?? this.groupIsPremium,
      purchased: purchased ?? this.purchased,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Sync metadata model
class EmojiSyncMeta {
  final int type;
  final DateTime lastSyncAt;
  final int totalCount;

  EmojiSyncMeta({
    required this.type,
    required this.lastSyncAt,
    required this.totalCount,
  });
}
