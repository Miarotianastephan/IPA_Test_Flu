import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadBanner extends ConsumerStatefulWidget {
  const DownloadBanner({super.key});

  @override
  ConsumerState<DownloadBanner> createState() => _DownloadBannerState();
}

class _DownloadBannerState extends ConsumerState<DownloadBanner> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    ref.watch(i18nNotifierProvider);
    final i18nNotifier = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18nNotifier.translate(key);
    final appConfig = ref.watch(appConfigProvider);
    final faviconUrl = appConfig.data?.faviconUrl ?? "";

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black12.withValues(alpha: 0.5),
              Colors.black12.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_isExpanded) {
                launchUrl(Uri.parse(ref.read(domainProvider).domain!.landing!));
              } else {
                setState(() => _isExpanded = true);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Row(
                  mainAxisSize: _isExpanded
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: EncryptedImage(
                          url: faviconUrl,
                          height: 44,
                          width: 44,
                          fit: BoxFit.cover,
                          errorWidget: Image.asset(
                            AppLangVersionUtils.getLogoPath(),
                            height: 44,
                            width: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    if (_isExpanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLangVersionUtils.getAppFullName(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AppLangVersionUtils.isCn()
                                ? Text(
                                    translate("getFullExperience"),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700),
                                            Color(0xFFFFECB3),
                                            Color(0xFFFFD700),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: const Text(
                                      "xo79.net",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.2,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          translate("download"),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
                        child: Icon(
                          _isExpanded
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
