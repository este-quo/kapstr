import 'package:flutter/material.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';

class AppRoute {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    // Match route name to return the corresponding page
    switch (settings.name) {
      case '/':
        builder = (_) => const EntryPoint();
        break;
      case '/entry':
        builder = (_) => const EntryPoint();
        break;
      // Add other cases for different routes here
      default:
        // If there is no route that matches the name, show a default unknown route page.
        // This is useful for debugging and user feedback.
        builder = (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}')));
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
