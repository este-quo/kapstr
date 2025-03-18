import 'package:flutter/material.dart';
import 'package:kapstr/widgets/layout/get_device_type.dart';

SizedBox xSmallSpacerH() {
  return SizedBox(height: getDeviceType() == 'phone' ? 8.0 : 12.0);
}

SizedBox smallSpacerH() {
  return SizedBox(height: getDeviceType() == 'phone' ? 12.0 : 16.0);
}

SizedBox mediumSpacerH() {
  return SizedBox(height: getDeviceType() == 'phone' ? 16.0 : 20.0);
}

SizedBox largeSpacerH() {
  return SizedBox(height: getDeviceType() == 'phone' ? 24.0 : 30.0);
}

SizedBox xLargeSpacerH() {
  return SizedBox(height: getDeviceType() == 'phone' ? 32.0 : 40.0);
}

SizedBox xSmallSpacerW() {
  return SizedBox(width: getDeviceType() == 'phone' ? 8.0 : 12.0);
}

SizedBox smallSpacerW() {
  return SizedBox(width: getDeviceType() == 'phone' ? 12.0 : 16.0);
}

SizedBox mediumSpacerW() {
  return SizedBox(width: getDeviceType() == 'phone' ? 16.0 : 20.0);
}

SizedBox largeSpacerW() {
  return SizedBox(width: getDeviceType() == 'phone' ? 24.0 : 30.0);
}

SizedBox xLargeSpacerW() {
  return SizedBox(width: getDeviceType() == 'phone' ? 32.0 : 40.0);
}

SizedBox kNavBarSpacer(context) {
  return SizedBox(height: MediaQuery.of(context).size.height * 0.15);
}
