import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kapstr/configuration/firebase_options.dart';
import 'package:kapstr/controllers/customization.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/controllers/in-app.dart';
import 'package:kapstr/controllers/modules/about.dart';
import 'package:kapstr/controllers/modules/cagnotte.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/controllers/modules/media.dart';
import 'package:kapstr/controllers/modules/menu.dart';
import 'package:kapstr/controllers/modules/text.dart';
import 'package:kapstr/controllers/notification.dart';
import 'package:kapstr/controllers/organizers.dart';
import 'package:kapstr/controllers/modules/wedding.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/configuration/navigation/app_routes.dart';
import 'package:kapstr/configuration/navigation/navigation_service.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/controllers/contacts.dart';
import 'package:kapstr/controllers/guest_tabs.dart';
import 'package:kapstr/controllers/organizer_tabs.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/controllers/version.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/firebase_service.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/services/firebase/messaging/messaging.dart';
import 'package:kapstr/widgets/layout/app_scroll_behavior.dart';
import 'package:kapstr/themes/colors/light_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MyAppWithProviders());
  });
}

class MyAppWithProviders extends StatelessWidget {
  const MyAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OrganizersController>(create: (_) => OrganizersController()),
        ChangeNotifierProvider<AuthenticationController>(create: (_) => AuthenticationController()),
        ChangeNotifierProvider<OrgaTabBarController>(create: (_) => OrgaTabBarController()),
        ChangeNotifierProvider<GuestTabBarController>(create: (_) => GuestTabBarController()),
        ChangeNotifierProvider<EventDataController>(create: (_) => EventDataController()),
        ChangeNotifierProvider<EventsController>(create: (_) => EventsController(Event.instance)),
        ChangeNotifierProvider<GuestsController>(create: (_) => GuestsController(Event.instance)),
        ChangeNotifierProvider<ContactsController>(create: (_) => ContactsController([])),
        ChangeNotifierProvider<ModulesController>(create: (_) => ModulesController(Event.instance)),
        ChangeNotifierProvider<UsersController>(create: (_) => UsersController()),
        ChangeNotifierProvider<TablesController>(create: (_) => TablesController()),
        ChangeNotifierProvider<RSVPController>(create: (_) => RSVPController()),
        ChangeNotifierProvider<InvitationsController>(create: (_) => InvitationsController()),
        ChangeNotifierProvider<WeddingController>(create: (_) => WeddingController()),
        ChangeNotifierProvider<CagnotteController>(create: (_) => CagnotteController()),
        ChangeNotifierProvider<GoldenBookController>(create: (_) => GoldenBookController()),
        ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
        ChangeNotifierProvider<FeedController>(create: (_) => FeedController()),
        ChangeNotifierProvider<NotificationController>(create: (_) => NotificationController()),
        ChangeNotifierProvider<MenuModuleController>(create: (_) => MenuModuleController()),
        ChangeNotifierProvider<MediaController>(create: (_) => MediaController()),
        ChangeNotifierProvider<AboutController>(create: (_) => AboutController()),
        ChangeNotifierProvider<TextModuleController>(create: (_) => TextModuleController()),
        ChangeNotifierProvider<CustomizationController>(create: (_) => CustomizationController()),
        ChangeNotifierProvider<InAppController>(create: (_) => InAppController()),
        ChangeNotifierProvider<VersionProvider>(create: (_) => VersionProvider()),
        ChangeNotifierProvider<PlacesController>(create: (_) => PlacesController()),
      ],
      child: const MyApp(),
    );
  }
}

Future<void> initializeServices() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      printOnDebug('Firebase initialisé directement SANS App Check');
    }

    // Assurez-vous qu'App Check est configuré
    await setupFirebaseAppCheck(); // <-- Cette ligne appelle la fonction d'activation d'App Check

    await diagnoseAppCheck(); // Vous pouvez le conserver pour le débogage

    await NotificationService.initializeNotification();
    await setupFirebaseMessaging();

    await initializeDateFormatting('fr_FR', null);
  } catch (e) {
    printOnDebug('Erreur lors de l\'initialisation : $e');
  }
}

Future<void> setupFirebaseMessaging() async {
  try {
    // Configuration du messaging comme dans FirebaseHelper
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );

    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      printOnDebug('Firebase Messaging Token: $token');
    }
  } catch (e) {
    printOnDebug('Firebase Messaging Setup Error: $e');
  }
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  printOnDebug('onBackgroundMessage: $message');
}

Future<void> setupFirebaseAppCheck() async {
  try {
    // APP CHECK N'EST PLUS DÉSACTIVÉ ICI.
    // Le 'return;' a été supprimé pour permettre l'activation.

    if (kDebugMode) {
      // En mode debug, utiliser le provider debug avec auto-refresh
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      // Activer le rafraîchissement automatique
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      printOnDebug('App Check activé en mode debug');
    } else {
      // En mode release, utiliser Play Integrity
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
      );

      printOnDebug('App Check activé en mode production');
    }
  } catch (e) {
    printOnDebug('Firebase App Check Activation Error: $e');
    // Ne pas faire échouer l'app si App Check échoue
  }
}

Future<void> diagnoseAppCheck() async {
  try {
    // Vérifier si App Check est configuré
    final appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken != null) {
      printOnDebug('App Check Token trouvé: ${appCheckToken.substring(0, 50)}...');
      printOnDebug('App Check est ACTIF - cela peut causer des problèmes');
    } else {
      printOnDebug('App Check Token: null - App Check semble désactivé');
    }
  } catch (e) {
    printOnDebug('Erreur lors de la vérification App Check: $e');
    printOnDebug('App Check semble désactivé');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // lock screen in portrait mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [Locale('fr', 'FR')],
      onGenerateRoute: AppRoute().onGenerateRoute,
      navigatorKey: NavigationService().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Kapstr',
      theme: lightTheme,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)), child: ScrollConfiguration(behavior: AppScrollBehavior(), child: child ?? const SizedBox.shrink()));
      },
    );
  }
}
