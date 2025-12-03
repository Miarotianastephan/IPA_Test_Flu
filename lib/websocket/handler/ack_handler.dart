import '../../../protos/socket_message.pb.dart';
import '../ack_manager.dart';
import 'msg_handler.dart';

class AckHandler implements MessageHandler {
  final AckManager ackManager;

  AckHandler(this.ackManager);

  @override
  bool canHandle(SocketEnvelope env) {
    return env.body.hasControl() && env.body.control.hasAck();
  }

  @override
  void handle(SocketEnvelope env) {
    final ack = env.body.control.ack;
    ackManager.handleAck(ack.ackId, success: ack.success, reason: ack.reason);
  }
}