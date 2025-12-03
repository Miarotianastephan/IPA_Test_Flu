import '../../protos/socket_message.pb.dart';
import 'handler/msg_handler.dart';

class MessageDispatcher {
  final List<MessageHandler> _handlers = [];

  void registerHandler(MessageHandler handler) {
    _handlers.add(handler);
  }

  void dispatch(SocketEnvelope env) {
    for (final h in _handlers) {
      if (h.canHandle(env)) {
        h.handle(env);
        return;
      }
    }
  }
}