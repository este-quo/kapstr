// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/sizer.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';

import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/views/global/events/joining/welcome.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:kapstr/services/firebase/authentication/auth_firebase.dart' as auth_firebase;

class EnterGuestCode extends StatefulWidget {
  const EnterGuestCode({super.key});

  @override
  State<StatefulWidget> createState() => _EnterGuestCodeState();
}

class _EnterGuestCodeState extends State<EnterGuestCode> {
  TextEditingController codeController = TextEditingController();
  bool _isProcessing = false;
  String? _currentEventId;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: UnconstrainedBox(child: Container(width: 92, height: 92, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8)), child: const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))));
      },
    );
  }

  void _dismissLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
  }

  Future<void> _safeNavigateTo(Widget page) async {
    if (!mounted) return;
    try {
      _dismissLoadingDialog();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
    } catch (e) {
      printOnDebug('Navigation error: $e');
      _showErrorSnackBar('Erreur de navigation. Veuillez réessayer.');
    }
  }

  // Méthode pour vérifier que l'événement correct est chargé
  Future<bool> _verifyEventLoaded(String expectedEventId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final currentEventId = context.read<EventsController>().event.id;
      printOnDebug('Verification - Expected event ID: $expectedEventId, Current event ID: $currentEventId');

      if (currentEventId != expectedEventId) {
        printOnDebug('Event ID mismatch! Expected: $expectedEventId, Got: $currentEventId');
        return false;
      }

      return true;
    } catch (e) {
      printOnDebug('Error verifying event: $e');
      return false;
    }
  }

  Future<void> confirmWhenConnected() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      showLoadingDialog(context);

      // Validation du code
      if (codeController.text.trim().isEmpty) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Veuillez entrer un code d\'invitation.');
        return;
      }

      // Vérification de l'événement
      QuerySnapshot event;
      try {
        event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);
      } catch (e) {
        printOnDebug('Error checking event: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la vérification de l\'événement.');
        return;
      }

      if (event.docs.isEmpty) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Aucun événement trouvé avec ce code.');
        return;
      }

      // Récupération de l'utilisateur actuel
      QuerySnapshot currentUser;
      try {
        currentUser = await context.read<UsersController>().currentUser();
      } catch (e) {
        printOnDebug('Error getting current user: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la récupération des informations utilisateur.');
        return;
      }

      if (currentUser.docs.isEmpty) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Informations utilisateur non trouvées.');
        return;
      }

      // Extraction des données de l'événement
      String? eventId;
      String? phone;
      String? eventVisibility;

      try {
        eventId = event.docs.first.id;
        eventVisibility = event.docs.first["visibility"] as String?;
        phone = currentUser.docs.first["phone"] as String?;

        printOnDebug('Event visibility: $eventVisibility');
        printOnDebug('Event ID: $eventId');
        printOnDebug('Phone: $phone');
      } catch (e) {
        printOnDebug('Error extracting event data: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la lecture des données de l\'événement.');
        return;
      }

      if (eventId == null || phone == null || eventVisibility == null) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Données d\'événement incomplètes.');
        return;
      }

      // Stocker l'ID de l'événement pour vérification
      _currentEventId = eventId;

      // Vérification des permissions
      bool isGuestAllowed;
      try {
        isGuestAllowed = await context.read<EventsController>().checkIfGuestIsAllowed(eventId, codeController.text, phone, eventVisibility);
        printOnDebug('Is guest allowed: $isGuestAllowed');
      } catch (e) {
        printOnDebug('Error checking guest permissions: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la vérification des permissions.');
        return;
      }

      // Vérification du code organisateur
      try {
        if (codeController.value.text == event.docs.first["code_organizer"]) {
          await context.read<EventsController>().initOrganizer(phone, context);
        }
      } catch (e) {
        printOnDebug('Error initializing organizer: $e');
        // Continue execution, not critical
      }

      // Détermination du rôle (Organisateur ou Invité)
      var organizerToAddField = event.docs.first["organizer_added"];
      bool isOrganizer = false;

      try {
        if (organizerToAddField is String) {
          isOrganizer = organizerToAddField == phone;
        } else if (organizerToAddField is List) {
          isOrganizer = organizerToAddField.contains(phone);
        }
        printOnDebug('Is organizer: $isOrganizer');
      } catch (e) {
        printOnDebug('Error determining organizer status: $e');
        isOrganizer = false;
      }

      // Traitement selon le rôle avec vérification
      if (isOrganizer) {
        await _handleOrganizerFlow(eventId, phone);
      } else if (isGuestAllowed) {
        await _handleGuestFlow(eventId, phone, eventVisibility);
      } else {
        _dismissLoadingDialog();
        _showErrorSnackBar('Vous n\'êtes pas invité à cet événement.');
      }
    } catch (e) {
      printOnDebug('Unexpected error in confirmWhenConnected: $e');
      _dismissLoadingDialog();
      _showErrorSnackBar('Une erreur inattendue s\'est produite. Veuillez réessayer.');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _handleOrganizerFlow(String eventId, String phone) async {
    try {
      printOnDebug('Starting organizer flow for event: $eventId');

      // Ajout de l'événement à l'utilisateur
      await context.read<UsersController>().addNewEvent(eventId, context);

      // Création de l'organisateur dans Firebase
      var organisersMap = {'name': context.read<UsersController>().user!.name, 'image_url': context.read<UsersController>().user!.imageUrl, 'user_id': firebaseAuth.currentUser!.uid, "id_auth_token": auth_firebase.getAuthId(), "event_id": eventId, "phone": phone};

      printOnDebug('Organisers map: $organisersMap');

      await cloud_firestore.addOrganisers(organisersMap, eventId, firebaseAuth.currentUser!.uid);
      printOnDebug('Organisers added');

      await context.read<EventsController>().confirmOrganizerAddition(eventId, phone);

      // Initialisation et redirection avec vérification
      bool initSuccess = await AppInitializer().initOrganiser(eventId, context);
      if (!initSuccess) {
        throw Exception('Failed to initialize organizer');
      }

      // Vérifier que le bon événement est chargé
      bool eventVerified = await _verifyEventLoaded(eventId);
      if (!eventVerified) {
        printOnDebug('Event verification failed, retrying initialization...');
        // Réessayer l'initialisation
        initSuccess = await AppInitializer().initOrganiser(eventId, context);
        eventVerified = await _verifyEventLoaded(eventId);

        if (!eventVerified) {
          throw Exception('Failed to load correct event after retry');
        }
      }

      printOnDebug('Organizer flow completed successfully for event: $eventId');
      await _safeNavigateTo(const OrgaHomepageConfiguration());
    } catch (e) {
      printOnDebug('Error in organizer flow: $e');
      _dismissLoadingDialog();
      _showErrorSnackBar('Erreur lors de la configuration de l\'organisateur.');
    }
  }

  Future<void> _handleGuestFlow(String eventId, String phone, String eventVisibility) async {
    try {
      printOnDebug('Starting guest flow for event: $eventId');
      printOnDebug('Event visibility: $eventVisibility');

      // Initialisation de l'invité avec vérification
      bool initSuccess = await AppInitializer().initGuest(eventId, phone, context);
      if (!initSuccess) {
        throw Exception('Failed to initialize guest');
      }

      // Vérifier que le bon événement est chargé
      bool eventVerified = await _verifyEventLoaded(eventId);
      if (!eventVerified) {
        printOnDebug('Event verification failed, retrying initialization...');
        // Réessayer l'initialisation
        initSuccess = await AppInitializer().initGuest(eventId, phone, context);
        eventVerified = await _verifyEventLoaded(eventId);

        if (!eventVerified) {
          throw Exception('Failed to load correct event after retry');
        }
      }

      if (eventVisibility == "public") {
        await context.read<GuestsController>().createGuestFromUser(context.read<UsersController>().user!, eventId);

        if (context.mounted) {
          var guests = await context.read<GuestsController>().getGuests(eventId);
          await context.read<GuestsController>().addGuestsToEvent(guests, context);
        }

        await context.read<EventsController>().confirmGuestAddition(eventId, phone, context.read<UsersController>().user!.id);
      }

      if (!mounted) return;

      await context.read<UsersController>().addNewJoinedEvent(eventId, context);
      await context.read<RSVPController>().checkRSVPs(context);
      context.read<UsersController>().updateLastEventId(eventId);

      printOnDebug('Guest flow completed successfully for event: $eventId');
      await _safeNavigateTo(const GuestWelcomeScreen());
    } catch (e) {
      printOnDebug('Error in guest flow: $e');
      _dismissLoadingDialog();
      _showErrorSnackBar('Erreur lors de la configuration de l\'invité.');
    }
  }

  Future<void> confirmWhenDisconnected() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      showLoadingDialog(context);

      // Validation du code
      if (codeController.text.trim().isEmpty) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Veuillez entrer un code d\'invitation.');
        return;
      }

      // Vérification des événements
      QuerySnapshot event;
      QuerySnapshot event_organizer;

      try {
        event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);
        event_organizer = await context.read<EventsController>().checkIfEventExistWithOrganizerCode(codeController.text);
      } catch (e) {
        printOnDebug('Error checking events: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la vérification des événements.');
        return;
      }

      // Vérification sécurisée des résultats
      if (event_organizer.docs.isNotEmpty) {
        try {
          printOnDebug('Event organizer ID: ${event_organizer.docs.first.id}');
          printOnDebug("Nouveau organisateur détecté");
          await context.read<EventsController>().initOrganizer(null, context);
        } catch (e) {
          printOnDebug('Error initializing organizer: $e');
          // Continue execution
        }
      } else if (event.docs.isEmpty) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Aucun événement trouvé avec ce code.');
        return;
      }

      // Détermination de l'ID de l'événement
      String? eventId;
      try {
        if (event_organizer.docs.isNotEmpty) {
          eventId = event_organizer.docs.first.id;
        } else if (event.docs.isNotEmpty) {
          eventId = event.docs.first.id;
        }
      } catch (e) {
        printOnDebug('Error extracting event ID: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de la récupération de l\'ID de l\'événement.');
        return;
      }

      if (eventId == null) {
        _dismissLoadingDialog();
        _showErrorSnackBar('Impossible de déterminer l\'événement.');
        return;
      }

      // Stocker l'ID de l'événement pour vérification
      _currentEventId = eventId;

      // Récupération et ajout des invités
      try {
        var guests = await context.read<GuestsController>().getGuests(eventId);
        await context.read<GuestsController>().addGuestsToEvent(guests, context);
      } catch (e) {
        printOnDebug('Error handling guests: $e');
        // Continue execution, not critical
      }

      // Initialisation du visiteur avec vérification
      try {
        bool initSuccess = await AppInitializer().initVisitor(eventId, context);
        if (!initSuccess) {
          throw Exception('Failed to initialize visitor');
        }

        // Vérifier que le bon événement est chargé
        bool eventVerified = await _verifyEventLoaded(eventId);
        if (!eventVerified) {
          printOnDebug('Event verification failed, retrying initialization...');
          // Réessayer l'initialisation
          initSuccess = await AppInitializer().initVisitor(eventId, context);
          eventVerified = await _verifyEventLoaded(eventId);

          if (!eventVerified) {
            throw Exception('Failed to load correct event after retry');
          }
        }

        printOnDebug('Visitor initialization completed successfully for event: $eventId');
      } catch (e) {
        printOnDebug('Error initializing visitor: $e');
        _dismissLoadingDialog();
        _showErrorSnackBar('Erreur lors de l\'initialisation du visiteur.');
        return;
      }

      await _safeNavigateTo(const GuestWelcomeScreen());
    } catch (e) {
      printOnDebug('Unexpected error in confirmWhenDisconnected: $e');
      _dismissLoadingDialog();
      _showErrorSnackBar('Une erreur inattendue s\'est produite. Veuillez réessayer.');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingLayout(
      title: 'Code d\'invitation',
      confirm: () async {
        if (_isProcessing) return;

        try {
          if (context.read<UsersController>().user != null) {
            await confirmWhenConnected();
          } else {
            await confirmWhenDisconnected();
          }
        } catch (e) {
          printOnDebug('Error in confirm action: $e');
          _showErrorSnackBar('Erreur lors de la validation du code.');
        }
      },
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 16.0),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  cursorColor: kBlack,
                  controller: codeController,
                  style: const TextStyle(color: kBlack, fontSize: 16),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    hintText: 'Entrez votre code d\'invitation',
                    filled: true,
                    fillColor: kLightWhiteTransparent1,
                    hintStyle: TextStyle(color: kGrey, fontSize: 16, fontWeight: FontWeight.w400),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizer(context).getWidgetHeight()),
          ],
        ),
      ],
    );
  }
}
