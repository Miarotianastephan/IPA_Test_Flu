import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/i18n_language.dart';
import 'package:live_app/models/i18n_translation.dart';
import 'package:live_app/models/i18n_version_check.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/page_response.dart';

import '../i18n_api.dart';

class I18nService extends BaseService {
  I18nService(super.client);

  Future<ApiResponse<PageResponse<I18nLanguage>>> getLanguages(
    PageParams params,
  ) {
    return post<PageResponse<I18nLanguage>>(
      I18nApi.getLanguages,
      body: {...params.toJson()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => I18nLanguage.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<I18nTranslation>>> getTranslations(
    PageParams params,
    String country,
    String language,
  ) {
    final body = {...params.toJson(), "country": country, "language": language};

    return post<PageResponse<I18nTranslation>>(
      I18nApi.getTranslations,
      body: body,
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => I18nTranslation.fromJson(item)),
    );
  }

  Future<ApiResponse<I18nVersionCheck>> checkVersion(
    String country,
    String language,
    String currentVersion,
  ) {
    final body = {
      "country": country,
      "language": language,
      "currentVersion": currentVersion,
    };

    return post<I18nVersionCheck>(
      I18nApi.checkVersion,
      body: body,
      fromJson: (json) => I18nVersionCheck.fromJson(json),
    );
  }
}
