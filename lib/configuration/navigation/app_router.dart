import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/controllers/version.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:kapstr/services/firebase/authentication/auth_firebase.dart' as auth_firebase;
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/global/phone_verification/request.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> with WidgetsBindingObserver {
  late Stream userStream;
  StreamSubscription? userStreamSubscription;
  bool isUserInitialized = false;
  bool hasNavigated = false;
  bool isSignedIn = false; // To track if the user is signed in

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final versionProvider = context.read<VersionProvider>();
      versionProvider.initVersion().then((_) {
        versionProvider.showUpdateDialogIfNeeded(context);
      });
      _initApp();
    });
  }

  @override
  void dispose() {
    userStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initApp() async {
    await _initUser();
    await _initThemes();
    //1
    String? userId = auth_firebase.getAuthId();
    if (userId != null) {
      print("nope");
      userStream = cloud_firestore.streamUserWithAuthToken(userId);
      _listenToUserStream();
    } else {
      // If no user ID, reset the app or show the login page
      setState(() {
        isSignedIn = false;
      });
    }
  }

  //2
  void _listenToUserStream() {
    userStreamSubscription?.cancel();
    userStreamSubscription = userStream.listen((data) {
      if (data != null && mounted && !hasNavigated) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            handleNavigation(data);
          }
        });
      }
    });
  }

  Future<void> _initUser() async {
    await context.read<UsersController>().initUser();
    if (context.read<UsersController>().user != null) {
      setState(() {
        isUserInitialized = true;
        isSignedIn = true;
      });
    }
  }

  Future<void> _initThemes() async {
    printOnDebug('Fetching themes');
    await context.read<ThemeController>().fetchAllThemes();
    printOnDebug('Themes fetched');
  }

  //3
  Future handleNavigation(dynamic data) async {
    if (!isUserInitialized || hasNavigated) {
      _navigateTo(const PhoneNumberRequestUI());
    }

    QuerySnapshot querySnapshot = data as QuerySnapshot;

    setState(() {
      hasNavigated = true;
    });

    try {
      if (context.read<AuthenticationController>().isPendingConnection) {
        await context.read<GuestsController>().createGuestFromUser(context.read<UsersController>().user!, context.read<EventsController>().event.id);
        if (!mounted) return;
        await context.read<UsersController>().addNewJoinedEvent(Event.instance.id, context);
        if (context.mounted) {
          await context.read<GuestsController>().getGuests(context.read<EventsController>().event.id).then((guests) async {
            await context.read<GuestsController>().addGuestsToEvent(guests, context);
          });
        }
        await context.read<EventsController>().confirmGuestAddition(context.read<EventsController>().event.id, context.read<UsersController>().user!.phone, context.read<UsersController>().user!.id);
        _navigateTo(const MyEvents());
      } else if (querySnapshot.docs.isNotEmpty) {
        _navigateTo(const MyEvents());
      }
    } catch (e) {
      printOnDebug("Handle Navigation : $e");
    } finally {}
  }

  void _navigateTo(Widget page) {
    setState(() {
      hasNavigated = false;
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      // Display loading screen or an appropriate UI if not signed in
      return const Scaffold(backgroundColor: kWhite, body: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)));
    }

    return const Scaffold(backgroundColor: kWhite, body: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)));
  }
}
