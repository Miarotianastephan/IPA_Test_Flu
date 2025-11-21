import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../config/storage_config.dart';
import '../../models/userinfo.dart';
import '../../protos/socket_message.pb.dart';

enum SocketStatus { connecting, connected, closed, error }

class MessageTabPageTest extends ConsumerStatefulWidget {
  const MessageTabPageTest({super.key});

  @override
  ConsumerState<MessageTabPageTest> createState() => _MessageTabPageTestState();
}

class _MessageTabPageTestState extends ConsumerState<MessageTabPageTest> {
  final _controller = TextEditingController();
  final _targetUserController = TextEditingController();
  late Stream _broadcastStream;
  WebSocketChannel? channel;
  UserInfo? _userInfo;
  Timer? _heartbeatTimer;
  SocketStatus _socketStatus = SocketStatus.closed;
  String _statusMessage = "未连接";

  @override
  void dispose() {
    _disconnectSocket();
    _controller.dispose();
    _targetUserController.dispose();
    super.dispose();
  }


  void _sendPrivateMessage() {
    final toText = _targetUserController.text.trim();
    if (toText.isEmpty) {
      debugPrint("❗ 目标用户ID不能为空");
      return;
    }
    final toId = int.tryParse(toText);
    if (toId == null) {
      debugPrint("❗ 目标用户ID必须为数字");
      return;
    }
    if (channel == null || _userInfo == null) {
      debugPrint("❗ 未连接，无法发送私信");
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // 🔹 构造 ChatMessage
    final chat = ChatMessage()
      ..text = _controller.text.trim().isEmpty ? "👋" : _controller.text.trim()
      ..contentType = "text"
      ..ext.addAll({
        "message_type": "chat", // ✅ 增加业务类型字段
      });

    // 🔹 组装 IMBody
    final imBody = IMBody()..chat = chat;

    // 🔹 BusinessBody
    final bizBody = BusinessBody()..im = imBody;

    // 🔹 SocketEnvelope
    final envelope = SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "pm-$nowMs"
        ..fromUser = Int64(_userInfo!.id)
        ..toTarget = Int64(toId)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(nowMs)
        ..traceId = "trace-$nowMs"
        ..version = 1
        ..category = MessageCategory.CATEGORY_BUSINESS)
      ..body = (MessageBody()..business = bizBody);

    channel!.sink.add(Uint8List.fromList(envelope.writeToBuffer()));
    debugPrint("📤 已发送私信给 userId $toId（type=chat）");
  }
  // -------------------------------
  // WebSocket 连接与断开
  // -------------------------------
  Future<void> _connectSocket() async {
    if (_socketStatus == SocketStatus.connecting ||
        _socketStatus == SocketStatus.connected) {
      debugPrint("⚠️ 已连接或正在连接中，跳过");
      return;
    }

    setState(() {
      _socketStatus = SocketStatus.connecting;
      _statusMessage = "正在连接中...";
    });

    final data = await StorageService.instance.getValue("user_info");
    if (data == null) {
      setState(() {
        _socketStatus = SocketStatus.error;
        _statusMessage = "❌ 无用户信息，无法建立连接";
      });
      return;
    }

    final map = data is String ? jsonDecode(data) : data;
    _userInfo = UserInfo.fromJson(map);
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.31.117:1999/api/user/ws?user_id=${_userInfo!.id}'),
      );

      _broadcastStream = channel!.stream.asBroadcastStream();

      _sendHandshake();
      _startHeartbeat();

      _broadcastStream.listen(
            (message) {
          try {
            if (message is List<int>) {
              final env = SocketEnvelope.fromBuffer(message);
              debugPrint("📩 收到 Envelope: category=${env.meta.category} scope=${env.meta.scope} from=${env.meta.fromUser} to=${env.meta.toTarget}");
              // 仅示例：根据业务体打印内容
              if (env.body.hasBusiness() && env.body.business.hasIm() && env.body.business.im.hasChat()) {
                debugPrint("💬 Chat: ${env.body.business.im.chat.text}");
              } else if (env.body.hasControl() && env.body.control.hasAck()) {
                debugPrint("✅ Ack: ${env.body.control.ack.ackId} success=${env.body.control.ack.success}");
              }
              // 新增：收到业务消息时发送ACK，跳过ACK消息本身
              if (env.meta.category == MessageCategory.CATEGORY_BUSINESS) {
                // 发送ACK确认收到
                // _sendAck(env.meta.messageId, true);
              }
            } else if (message is Uint8List) {
              final env = SocketEnvelope.fromBuffer(message);
              debugPrint("📩 收到 Envelope(typed): category=${env.meta.category} scope=${env.meta.scope}");
              if (env.meta.category == MessageCategory.CATEGORY_BUSINESS) {
                _sendAck(env.meta.messageId, true);
              }
            } else if (message is String) {
              // 服务端可能偶尔发文本（如健康检查）
              debugPrint("📩 收到文本消息: $message");
            } else {
              debugPrint("📩 未知消息类型: ${message.runtimeType}");
            }

            if (mounted) {
              setState(() {
                _socketStatus = SocketStatus.connected;
                _statusMessage = "✅ 已连接";
              });
            }
          } catch (e) {
            debugPrint("❌ 解包失败: $e");
          }
        },
        onError: (error) {
          debugPrint("❌ WebSocket 错误: $error");
          if (mounted) {
            setState(() {
              _socketStatus = SocketStatus.error;
              _statusMessage = "⚠️ 连接错误: $error";
            });
          }
          _disconnectSocket();
        },
        onDone: () {
          debugPrint("🔴 WebSocket 连接关闭");
          if (mounted) {
            setState(() {
              _socketStatus = SocketStatus.closed;
              _statusMessage = "🔴 已关闭";
            });
          }
          _disconnectSocket();
        },
      );

      if (mounted) {
        setState(() {
          _socketStatus = SocketStatus.connected;
          _statusMessage = "✅ 已连接";
        });
      }
    } catch (e) {
      debugPrint("❌ WebSocket 连接失败: $e");
      if (mounted) {
        setState(() {
          _socketStatus = SocketStatus.error;
          _statusMessage = "❌ 连接失败: $e";
        });
      }
    }
  }

  void _sendAck(String ackId, bool success) {
    if (channel == null || _userInfo == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final envelope = SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "ack-$ackId"
        ..fromUser = Int64(_userInfo!.id)
        ..toTarget = Int64(0)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(nowMs)
        ..traceId = "trace-$nowMs"
        ..version = 1
        ..category = MessageCategory.CATEGORY_CONTROL
      )
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..ack = (Ack()
            ..ackId = ackId
            ..success = success)));

    channel!.sink.add(Uint8List.fromList(envelope.writeToBuffer()));
    debugPrint("✅ 已发送ACK确认 ackId=$ackId");
  }

  void _disconnectSocket() {
    _heartbeatTimer?.cancel();

    try {
      channel?.sink.close(status.normalClosure);
    } catch (_) {}

    channel = null;

    if (mounted) {
      setState(() {
        _socketStatus = SocketStatus.closed;
        _statusMessage = "🔴 已关闭";
      });
    }

    debugPrint("🔌 WebSocket 已断开");
  }

  // -------------------------------
  // 握手与心跳逻辑
  // -------------------------------
  void _sendHandshake() {
    if (channel == null || _userInfo == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final envelope = SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "handshake-$nowMs"
        ..fromUser = Int64(_userInfo!.id)
        ..toTarget = Int64(0)
        ..scope = TargetScope.SCOPE_USER
        ..nodeId = ""               // 如有需要可填
        ..timestamp = Int64(nowMs)  // 若后端按“秒”，改为 Int64(nowMs ~/ 1000)
        ..traceId = "trace-$nowMs"
        ..version = 1               // 建议维护一个协议版本号
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..handshake = (Handshake()
            ..token = _userInfo!.token ?? ""
            ..clientVersion = "1.0.0"
            ..platform = "flutter"
            ..deviceId = "flutter-${_userInfo!.id}")));

    // 用二进制帧发送
    channel!.sink.add(Uint8List.fromList(envelope.writeToBuffer()));
    debugPrint("🤝 已发送握手包");
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _sendHeartbeat();
    });
  }

  void _sendHeartbeat() {
    if (channel == null || _userInfo == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final envelope = SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "hb-$nowMs"
        ..fromUser = Int64(_userInfo!.id)
        ..toTarget = Int64(0)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(nowMs) // 若后端按“秒”，改为 Int64(nowMs ~/ 1000)
        ..traceId = "trace-$nowMs"
        ..version = 1
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..heartbeat = (Heartbeat()
            ..seq = Int64(nowMs)
            ..timestamp = Int64(nowMs)))); // 若按秒，同上 ~/ 1000

    channel!.sink.add(Uint8List.fromList(envelope.writeToBuffer()));
    debugPrint("💓 已发送心跳包");
  }

  // void _sendMessage() {
  //   _sendPrivateMessage();
  // }

  // -------------------------------
  // UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket 控制面板")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "连接状态：$_statusMessage",
              style: TextStyle(
                color: _socketStatus == SocketStatus.connected
                    ? Colors.green
                    : _socketStatus == SocketStatus.error
                    ? Colors.red
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _connectSocket,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text("连接服务器"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _disconnectSocket,
                  icon: const Icon(Icons.cancel),
                  label: const Text("断开连接"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),

            const Divider(height: 30),

            // 新增：私信输入区域
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetUserController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "目标用户ID",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendPrivateMessage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("发送私信"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (channel != null)
              Expanded(
                child: StreamBuilder(
                  stream: _broadcastStream,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData
                          ? '📨 收到消息：${snapshot.data}'
                          : '等待消息...',
                    );
                  },
                ),
              )
            else
              const Text("尚未建立 WebSocket 连接。"),
          ],
        ),
      ),
    );
  }
}