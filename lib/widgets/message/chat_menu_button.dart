import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/provider/conversation_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/message/message_popup_menu_route.dart';

class ChatMenuButton extends ConsumerWidget {
  final UserInfo user;

  const ChatMenuButton({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Builder(
      builder: (buttonContext) {
        return IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () async {
            final RenderBox button =
                buttonContext.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(buttonContext).context.findRenderObject()
                    as RenderBox;

            final Offset buttonPosition = button.localToGlobal(
              Offset.zero,
              ancestor: overlay,
            );

            final double rightInset =
                overlay.size.width - (buttonPosition.dx + button.size.width);

            final result = await Navigator.of(buttonContext).push(
              MessagePopupMenuRoute(
                duration: const Duration(milliseconds: 150),
                position: RelativeRect.fromLTRB(
                  buttonPosition.dx,
                  buttonPosition.dy + button.size.height - 10,
                  rightInset,
                  0,
                ),
                child: IntrinsicWidth(
                  child: Material(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    elevation: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            translate("clearHistory"),
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            Navigator.pop(buttonContext);

                            final confirm = await showDialog<bool>(
                              context: buttonContext,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    translate("confirmClearingHistory"),
                                  ),
                                  content: Text(
                                    translate(
                                      "actionCanNotBeUndoneWhenClearingHistory",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(translate("cancel")),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        translate("clearHistory"),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              final notifier = ref.read(
                                chatControllerProvider(user.id).notifier,
                              );
                              notifier.clearHistory();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            if (!buttonContext.mounted) return;

            if (result == "clear_history") {
              final notifier = ref.read(
                chatControllerProvider(user.id).notifier,
              );
              notifier.clearHistory();
            }
          },
        );
      },
    );
  }
}
