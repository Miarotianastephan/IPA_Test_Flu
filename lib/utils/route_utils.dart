import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

import 'deferred_route_factories.dart' deferred as route_factories;

typedef DeferredWidgetBuilder = Widget Function(BuildContext context);

class DeferredRoutePage extends StatefulWidget {
  final Future<void> Function() loadLibrary;
  final DeferredWidgetBuilder builder;

  const DeferredRoutePage({
    super.key,
    required this.loadLibrary,
    required this.builder,
  });

  @override
  State<DeferredRoutePage> createState() => _DeferredRoutePageState();
}

class _DeferredRoutePageState extends State<DeferredRoutePage> {
  late final Future<void> _loadFuture = widget.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text(snapshot.error.toString())),
            );
          }
          return widget.builder(context);
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

final Map<String, WidgetBuilder> appRoutes = {
  '/ChatDetailPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args?['user'] == null) {
      return Consumer(
        builder: (context, ref, _) {
          final i18n = ref.read(i18nNotifierProvider.notifier);
          return Scaffold(
            body: Center(child: Text(i18n.translate('userMissing'))),
          );
        },
      );
    }
    return DeferredRoutePage(
      loadLibrary: route_factories.loadLibrary,
      builder: (_) => route_factories.buildChatDetailPage(args),
    );
  },
  '/GroupChatDetailPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final conversationIdValue = args?['conversationId'];

    int? conversationId;
    if (conversationIdValue is int) {
      conversationId = conversationIdValue;
    } else if (conversationIdValue is String) {
      conversationId = int.tryParse(conversationIdValue);
    }

    if (conversationId == null || conversationId == 0) {
      return Consumer(
        builder: (context, ref, _) {
          final i18n = ref.read(i18nNotifierProvider.notifier);
          return Scaffold(
            body: Center(child: Text(i18n.translate('conversationMissing'))),
          );
        },
      );
    }
    return DeferredRoutePage(
      loadLibrary: route_factories.loadLibrary,
      builder: (_) => route_factories.buildGroupChatDetailPage(args),
    );
  },
  '/DownloadsPage': (context) => DeferredRoutePage(
    loadLibrary: route_factories.loadLibrary,
    builder: (_) => route_factories.buildDownloadsPage(null),
  ),
  '/video': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final path = args?['path'] as String?;
    if (path == null) {
      return const Scaffold(body: Center(child: Text("Chemin vidéo manquant")));
    }
    return DeferredRoutePage(
      loadLibrary: route_factories.loadLibrary,
      builder: (_) => route_factories.buildVideoPage(args),
    );
  },
  '/TrackPlayerPage': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    return DeferredRoutePage(
      loadLibrary: route_factories.loadLibrary,
      builder: (_) => route_factories.buildTrackPlayerPage(args),
    );
  },
};
