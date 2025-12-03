import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/src/int64.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_app/models/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/services/notification_service.dart';
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
    required int userId,
    required String token,
    required String baseUrl,
    Function(String)? onLog,
    Function(SocketEnvelope)? onMessageReceived,
    Function(List<dynamic>)? onLiveBatch,
    Function(Message)? onMessageSent,
  }) {
    final inst = instance;
    inst.userId = userId;
    inst.token = token;
    inst.baseUrl = baseUrl;
    inst.onLog = onLog;
    inst.onMessageReceived = onMessageReceived;
    inst.onLiveBatch = onLiveBatch;
    inst.onMessageSent = onMessageSent;
    return inst;
  }

  int userId = 0;
  String token = "";
  String baseUrl = "";

  IO.Socket? _socket;

  Function(String)? onLog;
  Function(SocketEnvelope)? onMessageReceived;
  Function(List<dynamic>)? onLiveBatch;
  Function(Message)? onMessageSent;

  Function()? onConnectCallback;
  Function()? onDisconnectCallback;
  Function()? onRetryCallback;

  Timer? _heartbeatTimer;

  bool get isConnected => _socket?.connected ?? false;

  void connect({int? userId, String? token, String? baseUrl}) {
    if (userId != null) this.userId = userId;
    if (token != null) this.token = token;
    if (baseUrl != null) this.baseUrl = baseUrl;

    if (this.baseUrl.isEmpty) {
      this.baseUrl = dotenv.env['WS_BASE_URL'] ?? '';
    }

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
        log(":speech_balloon: Nouveau message reçu: ${message.sender}");
        log(":sender: ${message.sender}");
        final userJson = jsonEncode(message.sender?.toJson());
        final encoded = Uri.encodeComponent(userJson);

        NotificationService.showCustomLocalNotification(
          message.sender!.nickname ?? "New message",
          message.content,
          "route:/ChatDetailPage?user=$encoded",
        );


        onMessageSent?.call(message);
      } catch (e) {
        log(":x: Erreur parsing messageSent: $e");
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

        onMessageReceived?.call(envelope);
      } else {
        log(":warning: Unknown message type: $data");
      }
    });

    _socket!.on("live_batch", (data) {
      log(":fire: Live batch: $data");
      onLiveBatch?.call(data);
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
        ..fromUser = Int64(userId)
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