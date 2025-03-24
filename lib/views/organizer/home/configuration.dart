import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/app_device_info.dart';
import 'package:kapstr/views/organizer/home/home.dart';
import 'package:kapstr/views/organizer/home/tab_bar.dart';
import 'package:provider/provider.dart';

class OrgaHomepageConfiguration extends StatefulWidget {
  const OrgaHomepageConfiguration({super.key});

  @override
  State<OrgaHomepageConfiguration> createState() => _OrgaHomepageConfigurationState();
}

class _OrgaHomepageConfigurationState extends State<OrgaHomepageConfiguration> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    context.read<ThemeController>().initTheme(textColor: Event.instance.textColor, buttonColor: Event.instance.buttonColor, buttonTextColor: Event.instance.buttonTextColor);

    context.read<NotificationController>().fetchOrganizerNotifications();
    context.read<FeedController>().isGuestView = false;
  }

  @override
  Widget build(BuildContext context) {
    double bottomBarSize = Sizer(context).getWidgetHeight();

    if (Platform.isIOS && AppDeviceInfo.instance.iosDeviceHasNudge) {
      bottomBarSize = bottomBarSize * 1.4;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Event.instance.themeType == "dark" ? kBlack : kWhite,
      body: Stack(
        children: [
          Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, color: Colors.transparent, child: OrgaHomepageUI(bottomBarSize: bottomBarSize)),
          !context.watch<ThemeController>().isTransitioning ? Positioned(left: 0, right: 0, bottom: 0, child: Container(width: double.infinity, color: Colors.transparent, child: const OrgaHomePageTabBar(tabBarSize: 48))) : Container(),
        ],
      ),
    );
  }
}
