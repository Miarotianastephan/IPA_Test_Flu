import 'package:live_app/api/support_api.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/chat_log.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';

import 'base_service.dart';

class SupportService extends BaseService {
  SupportService(super.client);

  Future<ApiResponse<ChatLog>> chatLog(String fromUserId, String toUserId) {
    return post<ChatLog>(
      SupportApi.chatLog,
      body: {"fromUserId": fromUserId, "toUserId": toUserId},
      fromJson: (json) => ChatLog.fromJson(json),
    );
  }

    Future<ApiResponse<PageResponse<ChatLog>>> chatLogList(
      PageParams params,
      String fromUserId,
      String toUserId,
      String start,
      String end,
  ) {
    return post<PageResponse<ChatLog>>(
      SupportApi.chatLogList,
      body: {...params.toJson(), "fromUserId": fromUserId, "toUserId": toUserId, "end": end, "start": start, "order": "ASC"},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ChatLog.fromJson(item)),
    );
  }
}
