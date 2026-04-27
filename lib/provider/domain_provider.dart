import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/domain_config.dart';
import 'package:live_app/models/env.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/decrypt_utils.dart';

class DomainState {
  final Env? domain;
  final bool isLoading;
  final String? error;

  const DomainState({this.domain, this.isLoading = false, this.error});

  DomainState copyWith({Env? domain, bool? isLoading, String? error}) {
    return DomainState(
      domain: domain ?? this.domain,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

bool _isValidUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

Domain? getDomainByTag(DomainConfig config, String tag) {
  try {
    return config.domains.firstWhere((domain) => domain.tag == tag);
  } catch (e) {
    throw Exception('Domain with tag $tag not found');
  }
}

class DomainNotifier extends StateNotifier<DomainState> {
  DomainNotifier(Env? initialDomain)
    : super(DomainState(domain: initialDomain));

  static Future<Env> fetchInitialDomain() async {
    try {
      final dio = Dio();
      final responseCn = await dio.get<String>(
        dotenv.env['URLS_JSON'] ??
            'https://ceshi001-1394593989.cos.accelerate.myqcloud.com/api012fjinfaf2/xocn001/urlCN.json',
        options: Options(responseType: ResponseType.plain),
      );

      final responseYd = await dio.get<String>(
        dotenv.env['URLS_JSON_YD'] ??
            'https://ceshi001-1394593989.cos.accelerate.myqcloud.com/api012fjinfaf2/xocn001/urlYD.json',
        options: Options(responseType: ResponseType.plain),
      );

      final responseTk = await dio.get<String>(
        dotenv.env['URLS_JSON_TK'] ??
            'https://ceshi001-1394593989.cos.accelerate.myqcloud.com/api012fjinfaf2/xocn001/urlTk.json',
        options: Options(responseType: ResponseType.plain),
      );

      final decryptedJsonCn = await DecryptUtils(
        dotenv.env['ENCRYPTION_KEY'] ?? "",
      ).decryptStringAsync(responseCn.data!);
      final configCn = DomainConfig.fromJson(jsonDecode(decryptedJsonCn));
      final backCn = getDomainByTag(configCn, "back");
      final storageCn = getDomainByTag(configCn, "storage");
      final landingCn = getDomainByTag(configCn, "landing");

      final decryptedJsonYd = await DecryptUtils(
        dotenv.env['ENCRYPTION_KEY'] ?? "",
      ).decryptStringAsync(responseYd.data!);
      final configYd = DomainConfig.fromJson(jsonDecode(decryptedJsonYd));
      final backYd = getDomainByTag(configYd, "back");
      final storageYd = getDomainByTag(configYd, "storage");
      final landingYd = getDomainByTag(configYd, "landing");

      final decryptedJsonTk = await DecryptUtils(
        dotenv.env['ENCRYPTION_KEY'] ?? "",
      ).decryptStringAsync(responseTk.data!);
      final configTk = DomainConfig.fromJson(jsonDecode(decryptedJsonTk));
      final backTk = getDomainByTag(configTk, "back");
      final storageTk = getDomainByTag(configTk, "storage");
      final landingTk = getDomainByTag(configTk, "landing");

      final backUrlCn =
          backCn?.domain ??
          (_isValidUrl(dotenv.env['API_BASE_URL_CN'])
              ? dotenv.env['API_BASE_URL_CN']
              : "https://back.99sq20.fun");
      final storageUrlCn =
          storageCn?.domain ??
          (_isValidUrl(dotenv.env['R2_URL'])
              ? dotenv.env['R2_URL']
              : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/");
      final landingUrlCn =
          landingCn?.domain ??
          (_isValidUrl(dotenv.env['LANDING_URL_CN'])
              ? dotenv.env['LANDING_URL_CN']
              : "https://landing.99sq20.fun");

      final backUrlYd =
          backYd?.domain ??
          (_isValidUrl(dotenv.env['API_BASE_URL_YD'])
              ? dotenv.env['API_BASE_URL_YD']
              : "https://back-yd.99sq20.fun");
      final storageUrlYd =
          storageYd?.domain ??
          (_isValidUrl(dotenv.env['R2_URL'])
              ? dotenv.env['R2_URL']
              : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/");
      final landingUrlYd =
          landingYd?.domain ??
          (_isValidUrl(dotenv.env['LANDING_URL_YD'])
              ? dotenv.env['LANDING_URL_YD']
              : "https://landing-yd.99sq20.fun");

      final backUrlTk =
          backTk?.domain ??
          (_isValidUrl(dotenv.env['API_BASE_URL_TK'])
              ? dotenv.env['API_BASE_URL_TK']
              : "http://43.199.43.149:3000");
      final storageUrlTk =
          storageTk?.domain ??
          (_isValidUrl(dotenv.env['R2_URL'])
              ? dotenv.env['R2_URL']
              : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/");
      final landingUrlTk =
          landingTk?.domain ??
          (_isValidUrl(dotenv.env['LANDING_URL_TK'])
              ? dotenv.env['LANDING_URL_TK']
              : "https://landing.tk.99sq20.fun");

      // return Env(
      //   back: "http://192.168.1.110:3000",
      //   storage: storageUrlCn,
      //   landing: landingUrlCn,
      // );

      final resolvedEnv = AppLangVersionUtils.isCn()
          ? Env(back: backUrlCn, storage: storageUrlCn, landing: landingUrlCn)
          : AppLangVersionUtils.isYd()
          ? Env(back: backUrlYd, storage: storageUrlYd, landing: landingUrlYd)
          : Env(back: backUrlTk, storage: storageUrlTk, landing: landingUrlTk);

      return resolvedEnv;
    } catch (e) {
      final backUrlCn = _isValidUrl(dotenv.env['API_BASE_URL_CN'])
          ? dotenv.env['API_BASE_URL_CN']!
          : "https://back.99sq20.fun";
      final storageUrlCn = _isValidUrl(dotenv.env['R2_URL'])
          ? dotenv.env['R2_URL']!
          : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/";
      final landingUrlCn = _isValidUrl(dotenv.env['LANDING_URL_CN'])
          ? dotenv.env['LANDING_URL_CN']!
          : "https://landing.99sq20.fun";

      final backUrlYd = _isValidUrl(dotenv.env['API_BASE_URL_YD'])
          ? dotenv.env['API_BASE_URL_YD']!
          : "https://back-yd.99sq20.fun";
      final storageUrlYd = _isValidUrl(dotenv.env['R2_URL'])
          ? dotenv.env['R2_URL']!
          : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/";
      final landingUrlYd = _isValidUrl(dotenv.env['LANDING_URL_YD'])
          ? dotenv.env['LANDING_URL_YD']!
          : "https://landing-yd.99sq20.fun";

      final backUrlTk = _isValidUrl(dotenv.env['API_BASE_URL_TK'])
          ? dotenv.env['API_BASE_URL_TK']!
          : "http://43.199.43.149:3000";
      final storageUrlTk = _isValidUrl(dotenv.env['R2_URL'])
          ? dotenv.env['R2_URL']!
          : "https://pub-f66c37bc3f7b40e481f347a782ebb781.r2.dev/";
      final landingUrlTk = _isValidUrl(dotenv.env['LANDING_URL_TK'])
          ? dotenv.env['LANDING_URL_TK']!
          : "https://landing-tk.99sq20.fun";

      // return Env(
      //   back: "http://192.168.1.110:3000",
      //   storage: storageUrlCn,
      //   landing: landingUrlCn,
      // );

      final resolvedEnv = AppLangVersionUtils.isCn()
          ? Env(back: backUrlCn, storage: storageUrlCn, landing: landingUrlCn)
          : AppLangVersionUtils.isYd()
          ? Env(back: backUrlYd, storage: storageUrlYd, landing: landingUrlYd)
          : Env(back: backUrlTk, storage: storageUrlTk, landing: landingUrlTk);

      return resolvedEnv;
    }
  }
}

Env? _initialDomain;

void setInitialDomain(Env? domain) {
  _initialDomain = domain;
}

final domainProvider = StateNotifierProvider<DomainNotifier, DomainState>(
  (ref) => DomainNotifier(_initialDomain),
);
