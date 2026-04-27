import 'package:live_app/api/game_reduction_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/game_reduction_model.dart';
import 'package:live_app/utils/utils.dart';

class ReductionService extends BaseService {
  ReductionService(super.client);

  Future<ApiResponse<List<GameReductionResponse>>> getGameReduce() async {
    return post<List<GameReductionResponse>>(
      GameReductionApi.getGameReduce,
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => GameReductionResponse.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse<String?>> createUserGameReduce(
    int reductionId,
    bool claimed,
  ) async {
    return post<String?>(
      GameReductionApi.createUserGameReduce,
      body: {
        'reductionId': reductionId,
        'device': getDeviceId(),
        'claimed': claimed,
      },
      fromJson: (json) => json as String?,
    );
  }
}
