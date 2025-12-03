import 'dart:async';

import '../../protos/socket_message.pb.dart';

class _AckPendingItem {
  final SocketEnvelope env;
  int retryCount = 0;
  Timer? timer;

  _AckPendingItem(this.env);
}

class AckManager {
  final void Function(SocketEnvelope env) sendRaw;
  final bool Function() isReady;

  AckManager({
    required this.sendRaw,
    required this.isReady,
  });

  static const int _maxRetry = 3;
  static const Duration _retryInterval = Duration(seconds: 5);

  final Map<String, _AckPendingItem> _pending = {};
  final Map<String, Completer<bool>> _completers = {};

  void _add(SocketEnvelope env) {
    final id = env.meta.messageId;
    if (id.isEmpty) return;

    final item = _AckPendingItem(env);
    _pending[id] = item;

    sendRaw(env);
    _startRetry(id);
  }

  Future<bool> sendWithAck(SocketEnvelope env) {
    final msgId = env.meta.messageId;
    if (msgId.isEmpty) return Future.value(false);

    final completer = Completer<bool>();
    _completers[msgId] = completer;

    _add(env);

    return completer.future;
  }

  void handleAck(
    String msgId, {
    required bool success,
    String? reason,
  }) {
    final item = _pending.remove(msgId);
    item?.timer?.cancel();

    final completer = _completers.remove(msgId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
  }

  void _startRetry(String msgId) {
    final item = _pending[msgId];
    if (item == null) return;

    item.timer?.cancel();
    item.timer = Timer.periodic(_retryInterval, (t) {
      if (!_pending.containsKey(msgId)) {
        t.cancel();
        return;
      }

      if (!isReady()) return;

      if (item.retryCount >= _maxRetry) {
        _pending.remove(msgId);
        t.cancel();

        final completer = _completers.remove(msgId);
        if (completer != null && !completer.isCompleted) {
          completer.complete(false);
        }
        return;
      }

      item.retryCount++;
      sendRaw(item.env);
    });
  }

  void clear() {
    for (final item in _pending.values) {
      item.timer?.cancel();
    }
    _pending.clear();

    for (final c in _completers.values) {
      if (!c.isCompleted) c.complete(false);
    }
    _completers.clear();
  }
}