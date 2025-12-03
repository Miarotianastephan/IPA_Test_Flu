
import '../../../protos/socket_message.pb.dart';
import 'msg_handler.dart';

class DefaultMessageHandler implements MessageHandler {
  final void Function(SocketEnvelope env) onMessage;

  DefaultMessageHandler(this.onMessage);

  @override
  bool canHandle(SocketEnvelope env) => true;

  @override
  void handle(SocketEnvelope env) => onMessage(env);
}