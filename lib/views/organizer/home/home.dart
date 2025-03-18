import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/views/global/feed/feed.dart';
import 'package:kapstr/views/guest/rsvp/rsvp.dart';
import 'package:kapstr/views/organizer/guest_manager/guests_manager.dart';
import 'package:kapstr/views/organizer/home/layout.dart';
import 'package:kapstr/controllers/organizer_tabs.dart';
import 'package:kapstr/views/organizer/account/account.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class OrgaHomepageUI extends StatefulWidget {
  final double bottomBarSize;

  const OrgaHomepageUI({required this.bottomBarSize, super.key});

  @override
  State<OrgaHomepageUI> createState() => _OrgaHomepageUIState();
}

class _OrgaHomepageUIState extends State<OrgaHomepageUI> {
  late Widget _page;
  late OrganizerTabIndex tab;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    await context.read<FeedController>().fetchPosts();
    await context.read<InvitationsController>().getInvitationById();
    await context.read<MenuModuleController>().getMenuById();
  }

  @override
  Widget build(BuildContext context) {
    tab = context.watch<OrgaTabBarController>().index;

    switch (tab) {
      case OrganizerTabIndex.dashboard:
        _page = const OrgaHomePage();
        break;
      case OrganizerTabIndex.pictureWall:
        _page = const Feed();
        break;
      case OrganizerTabIndex.guests:
        _page = context.read<EventsController>().isGuestPreview ? const RsvpPage() : const GuestDashboard();
        break;
      case OrganizerTabIndex.profile:
        _page = const UserAccountPage();
        break;
    }
    return BackgroundTheme(child: _page);
  }
}
