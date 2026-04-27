import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/src/int64.dart';
import 'package:live_app/models/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/services/notification_service.dart';
import '../models/conversation.dart';
import '../protos/socket_message.pb.dart';
import 'ack_manager.dart';

class WebSocketManager {
  static final WebSocketManager instance = WebSocketManager._internal();
  WebSocketManager._internal();

  late final AckManager ackManager = AckManager(
    sendRaw: sendEnvelope,
    isReady: () => isConnected,
  );

  factory WebSocketManager({
    required String userId,
    required String token,
    required String baseUrl,
    Function(String)? onLog,
    Function(SocketEnvelope)? onMessageReceived,
    Function(List<dynamic>)? onLiveBatch,
    Function(Message, Conversation?)? onMessageSent,
    Function(Map<String, dynamic>)? onSystemNotificationReceived,
  }) {
    final inst = instance;
    inst.userId = userId;
    inst.token = token;
    inst.baseUrl = baseUrl;
    inst.onLog = onLog;
    inst.onMessageReceived = onMessageReceived;
    inst.onLiveBatch = onLiveBatch;
    inst.onMessageSent = onMessageSent;
    inst.onSystemNotificationReceived = onSystemNotificationReceived;
    return inst;
  }

  String userId = "";
  String token = "";
  String baseUrl = "";

  IO.Socket? _socket;

  Function(String)? onLog;
  Function(SocketEnvelope)? onMessageReceived;
  Function(List<dynamic>)? onLiveBatch;
  Function(Message, Conversation?)? onMessageSent;
  Function(Map<String, dynamic>)? onSystemNotificationReceived;

  Function()? onConnectCallback;
  Function()? onDisconnectCallback;
  Function()? onRetryCallback;

  Timer? _heartbeatTimer;

  bool get isConnected => _socket?.connected ?? false;

  void connect({String? userId, String? token, String? baseUrl}) {
    if (userId != null) this.userId = userId;
    if (token != null) this.token = token;
    if (baseUrl != null) this.baseUrl = baseUrl;

    if (this.baseUrl.isEmpty) {
      return;
    }

    if (_socket != null) {
      _socket!.connect();
      return;
    }

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/ws')
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      log(":fire: Connected to Socket.IO");
      onConnectCallback?.call();
      sendHandshake();
      _startHeartbeat();
    });

    _socket!.onDisconnect((_) {
      log(":x: Disconnected");
      onDisconnectCallback?.call();
      _stopHeartbeat();
    });

    _socket!.onReconnect((_) {
      log(":arrows_counterclockwise: Reconnected");
      onRetryCallback?.call();
      sendHandshake();
    });

    _socket!.on("messageSent", (data) {
      try {
        final message = Message.fromJson(data);

        final userJson = jsonEncode(message.sender?.toJson());
        final encoded = Uri.encodeComponent(userJson);

        final pattern = RegExp(r'\^\*#\*[\w]+\*#\*\^');
        final Map<String, dynamic> msgToJson = jsonDecode(message.content);

        final String msgType = msgToJson['type'];
        final String content = msgToJson['content'];
        final bool isGroup = msgToJson['isGroup'];
        final String notifRoute = isGroup
            ? "route:/GroupChatDetailPage?conversationId=${message.conversationId}"
            : "route:/ChatDetailPage?conversationId=${message.conversationId}&user=$encoded";

        final bool containsEmojiPattern = pattern.hasMatch(content);

        String displayMessage;

        if (msgType == "text") {
          final cleanedMessage = content.replaceAll(pattern, ' ');

          displayMessage = containsEmojiPattern
              ? "$cleanedMessage\nThis message contains an emoji"
              : cleanedMessage;
        } else {
          displayMessage = msgType;
        }

        NotificationService.instance.showOrUpdateChatNotification(
          conversationId: message.conversationId,
          title: message.sender?.nickname ?? "Message",
          message: displayMessage,
          payload: notifRoute,
          imageUrl: message.sender?.avatar,
        );

        Conversation? conversation;
        if (data['conversation'] != null) {
          try {
            conversation = Conversation.fromJson(data['conversation']);
          } catch (e) {
            log(":envelope: [messageSent] Failed to parse conversation: $e");
          }
        }

        onMessageSent?.call(message, conversation);
      } catch (e) {
        log("Erreur parsing messageSent: $e");
      }
    });

    _socket!.on("message", (data) {
      if (data is Uint8List) {
        final envelope = SocketEnvelope.fromBuffer(data);
        log(":inbox_tray: Received message: ${envelope.toProto3Json()}");

        final control = envelope.body.control;
        final ack = control.ack;
        ackManager.handleAck(
          ack.ackId,
          success: ack.success,
          reason: ack.reason,
        );
        log(":white_check_mark: ACK reçu pour ${ack.ackId} - ${ack.reason}");
        return;

        // onMessageReceived?.call(envelope);
      } else {
        log(":warning: Unknown message type: $data");
      }
    });

    _socket!.on("userWhoLiked", (data) {
      if (data) {
        log("user who liked");
        return;
      } else {
        log(":warning: Unknown message type: $data");
      }
    });

    _socket!.on("newComment", (data) {
      if (data) {
        log("new comment");
        return;
      } else {
        log(":warning: Unknown message type: $data");
      }
    });

    _socket!.on("live_batch", (data) {
      log(":fire: Live batch: $data");
      onLiveBatch?.call(data);
    });

    _socket!.on("systemNotification", (data) {
      try {
        log(":bell: System notification received: $data");

        if (onSystemNotificationReceived != null) {
          onSystemNotificationReceived!(data);
        }
      } catch (e) {
        log("Error parsing systemNotification: $e");
      }
    });

    _socket!.on("reconnect_attempt", (_) {
      log(":warning: Reconnect attempt...");
      _triggerRetry();
    });

    _socket!.connect();
  }

  void disconnect() {
    _stopHeartbeat();
    ackManager.clear();
    _socket?.disconnect();
  }

  void _triggerRetry() {
    log(":warning: Retrying...");
    onRetryCallback?.call();
  }

  void sendEnvelope(SocketEnvelope env) {
    final bin = env.writeToBuffer();
    _socket?.emit('message', Uint8List.fromList(bin));
  }

  void sendHandshake() {
    final meta = MessageMeta()
      ..messageId = "hs_${DateTime.now().millisecondsSinceEpoch}"
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..category = MessageCategory.CATEGORY_CONTROL;

    final handshake = Handshake(
      token: token,
      clientVersion: "1.0.0",
      platform: "flutter",
      deviceId: "device-$userId",
    );

    final body = MessageBody()
      ..control = (ControlBody()..handshake = handshake);

    final env = SocketEnvelope()
      ..meta = meta
      ..body = body;

    log(":outbox_tray: Sending handshake...");
    sendEnvelope(env);

    ackManager.sendWithAck(env);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendHeartbeat();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  void sendHeartbeat() {
    final hb = Heartbeat()..seq = Int64(DateTime.now().millisecondsSinceEpoch);

    final env = SocketEnvelope()
      ..meta = (MessageMeta()
        ..fromUser = Int64(int.parse(userId))
        ..messageId = "hb_${DateTime.now().millisecondsSinceEpoch}"
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()..control = (ControlBody()..heartbeat = hb));

    log(":heart: Sending heartbeat");
    sendEnvelope(env);

    ackManager.sendWithAck(env);
  }

  Future<bool> sendPrivateMessage(String text, int targetUserId, int convId) {
    final chat = ChatMessage()
      ..text = text
      ..ext["convId"] = convId.toString()
      ..ext["token"] = token;

    final im = IMBody()..chat = chat;

    final msgId = "im_${DateTime.now().millisecondsSinceEpoch}";
    final env = SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = msgId
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
        ..category = MessageCategory.CATEGORY_BUSINESS
        ..fromUser = Int64(int.parse(userId))
        ..toTarget = Int64(targetUserId))
      ..body = (MessageBody()..business = (BusinessBody()..im = im));

    log(":speech_balloon: Sending private message with ACK → $targetUserId");

    return ackManager.sendWithAck(env);
  }

  void log(String msg) {
    print(msg);
    onLog?.call(msg);
  }
}
