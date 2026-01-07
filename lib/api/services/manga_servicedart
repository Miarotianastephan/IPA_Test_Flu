import '../../models/api_response.dart';
import '../../models/manga_response.dart';
import '../manga_api.dart';
import 'base_service.dart';

class MangaService extends BaseService {
  MangaService(super.client);
  Future<ApiResponse<MangaResponse>> mangas() {
    return post<MangaResponse>(
      MangaApi.mangas, 
      body: {}, 
      fromJson: (json) => MangaResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
