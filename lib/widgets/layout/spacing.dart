import 'package:flutter/material.dart';
import 'package:kapstr/widgets/layout/get_device_type.dart';

SizedBox xSmallSpacerH(BuildContext context) {
  return SizedBox(height: getDeviceType(context) == 'phone' ? 8.0 : 12.0);
}

SizedBox smallSpacerH(BuildContext context) {
  return SizedBox(height: getDeviceType(context) == 'phone' ? 12.0 : 16.0);
}

SizedBox mediumSpacerH(BuildContext context) {
  return SizedBox(height: getDeviceType(context) == 'phone' ? 16.0 : 20.0);
}

SizedBox largeSpacerH(BuildContext context) {
  return SizedBox(height: getDeviceType(context) == 'phone' ? 24.0 : 30.0);
}

SizedBox xLargeSpacerH(BuildContext context) {
  return SizedBox(height: getDeviceType(context) == 'phone' ? 32.0 : 40.0);
}

SizedBox xSmallSpacerW(BuildContext context) {
  return SizedBox(width: getDeviceType(context) == 'phone' ? 8.0 : 12.0);
}

SizedBox smallSpacerW(BuildContext context) {
  return SizedBox(width: getDeviceType(context) == 'phone' ? 12.0 : 16.0);
}

SizedBox mediumSpacerW(BuildContext context) {
  return SizedBox(width: getDeviceType(context) == 'phone' ? 16.0 : 20.0);
}

SizedBox largeSpacerW(BuildContext context) {
  return SizedBox(width: getDeviceType(context) == 'phone' ? 24.0 : 30.0);
}

SizedBox xLargeSpacerW(BuildContext context) {
  return SizedBox(width: getDeviceType(context) == 'phone' ? 32.0 : 40.0);
}

SizedBox kNavBarSpacer(context) {
  return SizedBox(height: MediaQuery.of(context).size.height * 0.15);
}
