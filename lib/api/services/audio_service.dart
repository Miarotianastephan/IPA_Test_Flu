import 'package:live_app/models/audio.dart';
import '../../models/api_response.dart';
import '../audio_api.dart';
import 'base_service.dart';

class AudioService extends BaseService {
  AudioService(super.client);

  Future<ApiResponse<List<Audio>>> audios() {
    return post<List<Audio>>(
      AudioApi.audio,
      body: {},
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => Audio.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }
}
