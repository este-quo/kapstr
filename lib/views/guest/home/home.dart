import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/views/global/feed/feed.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/views/guest/account/account.dart';
import 'package:kapstr/views/guest/rsvp/rsvp.dart';
import 'package:kapstr/views/guest/home/layout.dart';
import 'package:kapstr/controllers/guest_tabs.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

enum InitState { notStarted, inProgress, done }

class GuestHomepageUI extends StatefulWidget {
  final double bottomBarSize;

  const GuestHomepageUI({required this.bottomBarSize, super.key});

  @override
  State<GuestHomepageUI> createState() => _GuestHomepageUIState();
}

class _GuestHomepageUIState extends State<GuestHomepageUI> {
  late Widget _page;
  late GuestTabIndex tab;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedController>().isGuestView = true;
      _init();
    });
  }

  Future<void> _init() async {
    await context.read<FeedController>().fetchPosts();

    if (context.read<UsersController>().user != null) {
      await context.read<InvitationsController>().getInvitationById();
      await context.read<MenuModuleController>().getMenuById();
      await context.read<RSVPController>().fetchRsvps(AppGuest.instance.id, AppGuest.instance.allowedModules);
    }
  }

  @override
  Widget build(BuildContext context) {
    tab = context.watch<GuestTabBarController>().index;

    switch (tab) {
      case GuestTabIndex.dashboard:
        _page = const GuestHomePage();
        break;
      case GuestTabIndex.pictureWall:
        _page = const Feed();
        break;
      case GuestTabIndex.rsvp:
        _page = const RsvpPage();
        break;
      case GuestTabIndex.profile:
        if (context.read<UsersController>().user != null) {
          _page = const GuestAccountPage();
        } else {
          context.read<AuthenticationController>().setPendingConnection(true);
          _page = const LogIn();
        }
        break;
    }
    return BackgroundTheme(child: _page);
  }
}
