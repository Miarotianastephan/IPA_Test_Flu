import 'package:flutter/material.dart';

import 'route_utils.dart' deferred as route_utils;

Route<dynamic>? generateDeferredRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => DeferredNamedRoutePage(settings: settings),
  );
}

class DeferredNamedRoutePage extends StatefulWidget {
  final RouteSettings settings;

  const DeferredNamedRoutePage({super.key, required this.settings});

  @override
  State<DeferredNamedRoutePage> createState() => _DeferredNamedRoutePageState();
}

class _DeferredNamedRoutePageState extends State<DeferredNamedRoutePage> {
  late final Future<void> _loadFuture = route_utils.loadLibrary();

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

          final builder = route_utils.appRoutes[widget.settings.name];
          if (builder != null) {
            return builder(context);
          }

          return Scaffold(
            body: Center(
              child: Text('Route not found: ${widget.settings.name}'),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
