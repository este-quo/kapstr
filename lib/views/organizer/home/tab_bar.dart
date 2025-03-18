import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/home/tab_icon.dart';
import 'package:kapstr/widgets/app_device_info.dart';
import 'package:kapstr/controllers/organizer_tabs.dart';
import 'package:provider/provider.dart';

class OrgaHomePageTabBar extends StatefulWidget {
  final double tabBarSize;

  const OrgaHomePageTabBar({super.key, required this.tabBarSize});

  @override
  State<OrgaHomePageTabBar> createState() => _OrgaHomePageTabBarState();
}

class _OrgaHomePageTabBarState extends State<OrgaHomePageTabBar> {
  @override
  Widget build(BuildContext context) {
    OrganizerTabIndex tabIndex = context.watch<OrgaTabBarController>().index;

    return Container(
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 20 : 0, top: 10),
      decoration: const BoxDecoration(color: kWhite, border: Border(top: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 0.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OrgaHomePageTabBarButton(index: OrganizerTabIndex.dashboard, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/dashboard.svg', tabName: 'Accueil'),
              OrgaHomePageTabBarButton(index: OrganizerTabIndex.pictureWall, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/mur_std.svg', tabName: 'Feed'),
              OrgaHomePageTabBarButton(
                index: OrganizerTabIndex.guests,
                currentIndex: tabIndex,
                onChanged: (index) => _onChanged(index, context),
                assetPath: !context.watch<EventsController>().isGuestPreview ? 'assets/icons/tabbar/invites.svg' : 'assets/icons/tabbar/rsvp.svg',
                tabName: !context.watch<EventsController>().isGuestPreview ? 'Invités' : 'RSVP',
              ),
              OrgaHomePageTabBarButton(index: OrganizerTabIndex.profile, currentIndex: tabIndex, onChanged: (index) => _onChanged(index, context), assetPath: 'assets/icons/tabbar/profile.svg', tabName: 'Profil'),
            ],
          ),
          if (Platform.isIOS && AppDeviceInfo.instance.iosDeviceHasNudge) Container(height: Sizer(context).getWidgetHeight() * 0.4),
        ],
      ),
    );
  }

  _onChanged(OrganizerTabIndex index, BuildContext context) {
    context.read<OrgaTabBarController>().setIndex(index);
  }
}
