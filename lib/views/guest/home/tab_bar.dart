import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/app_device_info.dart';
import 'package:kapstr/controllers/guest_tabs.dart';
import 'package:kapstr/views/guest/home/tab_icon.dart';
import 'package:provider/provider.dart';

class GuestHomePageTabBar extends StatefulWidget {
  final double tabBarSize;

  const GuestHomePageTabBar({super.key, required this.tabBarSize});

  @override
  State<GuestHomePageTabBar> createState() => _GuestHomePageTabBarState();
}

class _GuestHomePageTabBarState extends State<GuestHomePageTabBar> {
  @override
  Widget build(BuildContext context) {
    GuestTabIndex tabIndex = context.watch<GuestTabBarController>().index;

    return Container(
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 20 : 0, top: 10),
      decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 0.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GuestHomePageTabBarButton(index: GuestTabIndex.dashboard, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/dashboard.svg', showNotification: false, tabName: 'Accueil'),
              GuestHomePageTabBarButton(index: GuestTabIndex.pictureWall, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/mur_std.svg', showNotification: false, tabName: 'Feed'),
              GuestHomePageTabBarButton(index: GuestTabIndex.rsvp, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/rsvp.svg', showNotification: !context.watch<RSVPController>().isAllAnswered, tabName: 'RSVP'),
              GuestHomePageTabBarButton(index: GuestTabIndex.profile, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/profile.svg', showNotification: false, tabName: 'Profil'),
            ],
          ),
          if (Platform.isIOS && AppDeviceInfo.instance.iosDeviceHasNudge) Container(height: Sizer(context).getWidgetHeight() * 0.4),
        ],
      ),
    );
  }

  _onChanged(GuestTabIndex index, BuildContext context) {
    context.read<GuestTabBarController>().setIndex(index);
  }
}
