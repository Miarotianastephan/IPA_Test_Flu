import 'package:json_annotation/json_annotation.dart';

part 'system_notification.g.dart';

/// Modèle pour représenter une notification système
/// Peut être utilisé pour afficher les notifications système dans la liste des conversations
@JsonSerializable(explicitToJson: true)
class SystemNotification {
  final int id;

  /// Titre de la notification
  final String title;

  /// Contenu/message de la notification
  final String content;

  /// Type de notification (info, warning, announcement, etc.)
  final String type;

  /// Indique si la notification a été lue
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// URL ou action associée à la notification (optionnel)
  @JsonKey(name: 'action_url')
  final String? actionUrl;

  /// Données supplémentaires (optionnel)
  final Map<String, dynamic>? metadata;

  SystemNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.updatedAt,
    this.actionUrl,
    this.metadata,
  });

  SystemNotification copyWith({
    int? id,
    String? title,
    String? content,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SystemNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  factory SystemNotification.fromJson(Map<String, dynamic> json) =>
      _$SystemNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$SystemNotificationToJson(this);
}

/// Résumé des notifications système pour l'affichage dans la liste des conversations
class SystemNotificationSummary {
  /// Nombre total de notifications non lues
  final int unreadCount;

  /// Dernière notification reçue
  final SystemNotification? lastNotification;

  /// Date de la dernière notification
  final DateTime? lastUpdated;

  const SystemNotificationSummary({
    required this.unreadCount,
    this.lastNotification,
    this.lastUpdated,
  });

  SystemNotificationSummary copyWith({
    int? unreadCount,
    SystemNotification? lastNotification,
    DateTime? lastUpdated,
  }) {
    return SystemNotificationSummary(
      unreadCount: unreadCount ?? this.unreadCount,
      lastNotification: lastNotification ?? this.lastNotification,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
