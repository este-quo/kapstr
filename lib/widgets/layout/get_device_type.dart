import 'package:flutter/material.dart';

/// Returns 'tablet' or 'phone' based on screen size.
String getDeviceType(BuildContext context) {
  final data = MediaQuery.of(context);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}
