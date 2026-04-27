import 'package:live_app/api/game_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/game.dart';
import 'package:live_app/models/page_response.dart';

class GameService extends BaseService {
  GameService(super.client);

  Future<ApiResponse<PageResponse<Game>>> getGameList({
    int page = 1,
    int limit = 20,
  }) {
    return post<PageResponse<Game>>(
      GameApi.list,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => Game.fromJson(item)),
    );
  }

  Future<ApiResponse<String>> gameLogin(int deviceId) {
    return post<String>(
      GameApi.loginGame,
      body: {"device": deviceId},
      fromJson: (json) => json as String,
    );
  }
}
