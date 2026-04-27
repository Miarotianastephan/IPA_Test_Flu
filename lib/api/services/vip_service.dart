import '../../models/api_response.dart';
import '../../models/vip.dart';
import '../vip_api.dart';
import 'base_service.dart';

class VipService extends BaseService {
  VipService(super.client);

  Future<ApiResponse<List<Vip>>> list() {
    return post<List<Vip>>(
      VipApi.list,
      fromJson: (json) {
        if (json is Map<String, dynamic> && json['vips'] is List) {
          return (json['vips'] as List)
              .map((e) => Vip.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Vip>[];
      },
    );
  }
}
