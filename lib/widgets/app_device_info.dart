import 'package:device_info_plus/device_info_plus.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:ios_utsname_ext/extension.dart';

class AppDeviceInfo {
  late DeviceInfoPlugin appDeviceInfoPlugin;
  AndroidDeviceInfo? androidDeviceInfo;
  IosDeviceInfo? iosDeviceInfo;
  bool iosDeviceHasNudge = false;

  static final AppDeviceInfo _instance = AppDeviceInfo._internal();
  AppDeviceInfo._internal();
  static AppDeviceInfo get instance {
    return _instance;
  }

  factory AppDeviceInfo(DeviceInfoPlugin deviceInfoPlugin) {
    _instance.appDeviceInfoPlugin = deviceInfoPlugin;
    return _instance;
  }

  Future loadAndroidDeviceInfo() async {
    androidDeviceInfo = await _instance.appDeviceInfoPlugin.androidInfo;
    printOnDebug("Android phone detected, model : ${androidDeviceInfo!.model}");
  }

  Future loadIosDeviceInfo() async {
    iosDeviceInfo = await _instance.appDeviceInfoPlugin.iosInfo;
    String machineId = iosDeviceInfo!.utsname.machine;
    String productName = machineId.iOSProductName;
    printOnDebug("IPhone detected, model : $productName");

    iosDeviceHasNudge = hasIosDeviceNudge(productName);
  }

  bool hasIosDeviceNudge(String model) {
    bool hasNudge = false;
    switch (model) {
      case "iPhone 4":
      case "iPhone 4s":
      case "iPhone 5":
      case "iPhone 5c":
      case "iPhone 5s":
      case "iPhone 6":
      case "iPhone 6 Plus":
      case "iPhone 6s":
      case "iPhone 6s Plus":
      case "iPhone 7":
      case "iPhone 7 Plus":
      case "iPhone 8":
      case "iPhone 8 Plus":
      case "iPhone X":
      case "iPhone XS":
      case "iPhone XS Max":
      case "iPhone SE 2nd Gen":
        hasNudge = false;
        break;
      default:
        hasNudge = true;
        break;
    }

    return hasNudge;
  }
}
