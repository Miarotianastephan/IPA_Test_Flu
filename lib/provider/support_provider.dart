import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_log.dart';
import 'api_provider.dart';

final supportChatLogProvider = FutureProvider.family<
    ChatLog?,
    ({String fromUserId, String toUserId})>((ref, input) async {
  final service = ref.watch(supportServiceProvider);
  final resp = await service.chatLog(input.fromUserId, input.toUserId);
  return resp.data;
});
