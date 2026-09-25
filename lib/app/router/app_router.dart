import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Route not implemented yet.'),
          ),
        );
      },
    );
  }
}
