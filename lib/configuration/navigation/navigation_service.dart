import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();
  static final _instance = NavigationService._();
  static BuildContext? _context;
  String currentRoute = "/";

  static NavigationService get instance => _instance;

  factory NavigationService([BuildContext? ctx]) {
    if (ctx != null) {
      _context = ctx;
    }
    return _instance;
  }

  final navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get context => _context;

  updateRoute(String path) {
    currentRoute = path;
  }

  Future navigate(String name, [dynamic arguments]) async {
    return await navigatorKey.currentState?.pushReplacementNamed(name, arguments: arguments);
  }
}
