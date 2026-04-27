import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/my/sponsored_users_page.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/domain_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class InvitationToSharePage extends ConsumerStatefulWidget {
  const InvitationToSharePage({super.key});

  @override
  ConsumerState<InvitationToSharePage> createState() =>
      _InvitationToSharePageState();
}

class _InvitationToSharePageState extends ConsumerState<InvitationToSharePage> {
  final GlobalKey _qrKey = GlobalKey();
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final domainState = ref.watch(domainProvider);
    final landingUrl = domainState.domain?.landing?.replaceAll(
      RegExp(r'/$'),
      '',
    );

    final inviteCode = user?.inviteCode;
    final shareLink = (landingUrl != null && inviteCode != null)
        ? "$landingUrl?invite_code=$inviteCode"
        : "";

    final appConfig = ref.watch(appConfigProvider);
    final faviconUrl = appConfig.data?.faviconUrl ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRewardsSection(theme),
                const SizedBox(height: 24),
                if (shareLink.isNotEmpty)
                  _buildInviteCodeCard(
                    theme,
                    inviteCode!,
                    shareLink,
                    faviconUrl,
                  ),
                const SizedBox(height: 24),

                Column(
                  children: [
                    kIsWeb
                        ? const SizedBox()
                        : _buildButton(theme, null, false),

                    kIsWeb ? const SizedBox() : const SizedBox(height: 20),
                    if (shareLink.isNotEmpty)
                      _buildButton(theme, shareLink, true),
                    if (kIsWeb) ...[
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const ui.Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const ui.Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const ui.Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: ui.Color.fromARGB(255, 255, 255, 255),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  translate("screenshotHint"),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _buildFooterSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SponsoredUsersPage()),
            );
          },
          child: Text(translate("list"), style: TextStyle(color: Colors.white)),
        ),
      ],
      title: Text(
        translate("invitationToShare"),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildRewardsSection(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildRewardItem(
            theme,
            icon: Icons.all_inclusive,
            title: translate("invitationUnlimited"),
            subtitle: translate("invitationFor5Days"),
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRewardItem(
            theme,
            icon: Icons.shopping_bag_outlined,
            title: translate("invitationCashback"),
            subtitle: translate("invitationOnEachInvitee"),
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeCard(
    ThemeData theme,
    String code,
    String link,
    String faviconUrl,
  ) {
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                        AppLangVersionUtils.getBackgroundLogoPath(),
                        height: 44,
                        width: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "${AppLangVersionUtils.getAppName()} ${translate("invitationAppDescription")}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 50),
              color: Colors.white,
              child: PrettyQrView.data(
                data: link,
                errorCorrectLevel: QrErrorCorrectLevel.M,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              translate("invitationScanQrCode"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate("yourReferralCode"),
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ToastUtil.success(translate("codeCopied"));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.copy, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(ThemeData theme, String? link, bool isShare) {
    return ElevatedButton(
      onPressed: () {
        if (isShare) {
          Clipboard.setData(ClipboardData(text: link!));
          ToastUtil.success(translate("linkCopiedToShare"));
        } else {
          ToastUtil.success(translate("invitationManualShareToast"));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onSecondary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        isShare
            ? translate("shareNow")
            : translate("invitationManualShareButton"),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildFooterSection() {
    return SizedBox(
      width: double.infinity,
      height: 700.0,
      child: Image.asset(
        "lib/assets/img_dl.png",
        height: 44,
        width: 44,
        fit: BoxFit.contain,
      ),
    );
  }
}
