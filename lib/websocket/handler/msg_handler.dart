import '../../../protos/socket_message.pb.dart';

abstract class MessageHandler {
  bool canHandle(SocketEnvelope env);

  void handle(SocketEnvelope env);
}
