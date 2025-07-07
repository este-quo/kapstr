import 'package:flutter/material.dart';

///return tablet or phone according to screen size
String getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? 'phone' : 'tablet';
}
