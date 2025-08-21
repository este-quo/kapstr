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

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: UnconstrainedBox(
            child: Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(16), // Optional: for inner spacing
              decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8)),
              child: const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64),
            ),
          ),
        );
      },
    );
  }

  Future confirmWhenConnected() async {
    showLoadingDialog(context);
    String lastStep = 'start';
    while (true) {
      try {
  lastStep = 'checkIfEventExistWithCode';
  printOnDebug('[EnterGuestCode] about to call checkIfEventExistWithCode');
  QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);
  printOnDebug('[EnterGuestCode] checkIfEventExistWithCode returned ${event.docs.length} docs');

        if (event.docs.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun événement trouvé avec ce code.')));
          return;
        }

  lastStep = 'currentUser';
  printOnDebug('[EnterGuestCode] about to call currentUser');
  QuerySnapshot currentUser = await context.read<UsersController>().currentUser();
  printOnDebug('[EnterGuestCode] currentUser returned ${currentUser.docs.length} docs');

        String? eventId;
        String? phone;
        String? eventVisibility;

        if (event.docs.isNotEmpty) {
          eventId = event.docs.first.id;
          eventVisibility = event.docs.first["visibility"];

          printOnDebug('Event visibility: $eventVisibility');
        } else {
          Navigator.pop(context);
          return;
        }

        if (currentUser.docs.isNotEmpty) {
          phone = currentUser.docs.first["phone"];
        } else {
          Navigator.pop(context);
          return;
        }

        // Check if the user is allowed as a guest or organizer
        if (phone != null) {
          lastStep = 'checkIfGuestIsAllowed';
          printOnDebug('[EnterGuestCode] about to call checkIfGuestIsAllowed');
          bool isGuestAllowed = await context.read<EventsController>().checkIfGuestIsAllowed(eventId, codeController.text, phone, eventVisibility!);
          printOnDebug('[EnterGuestCode] checkIfGuestIsAllowed -> $isGuestAllowed');

          // Safe access to optional field 'code_organizer'
          try {
            final docData = event.docs.first.data() as Map<String, dynamic>? ?? <String, dynamic>{};
            if (docData.containsKey('code_organizer') && codeController.value.text == (docData['code_organizer'] ?? '')) {
              lastStep = 'initOrganizer';
              printOnDebug('[EnterGuestCode] about to call initOrganizer');
              await context.read<EventsController>().initOrganizer(phone, context);
              printOnDebug('[EnterGuestCode] initOrganizer completed');
            } else if (!docData.containsKey('code_organizer')) {
              printOnDebug('[EnterGuestCode] code_organizer not present in event doc, skipping initOrganizer');
            }
          } catch (e) {
            printOnDebug('[EnterGuestCode] error reading code_organizer safely: $e');
          }

          var organizerToAddField = event.docs.first["organizer_added"];
          bool isOrganizer;

          if (organizerToAddField is String) {
            isOrganizer = organizerToAddField == phone;
          } else if (organizerToAddField is List) {
            isOrganizer = organizerToAddField.contains(phone);
          } else {
            isOrganizer = false;
          }

          printOnDebug('Is organizer: $isOrganizer');

          if (isOrganizer) {
            // Organizer-specific onboarding process
            // Move event id to created not joined
            printOnDebug('[EnterGuestCode] about to call addNewEvent (organizer)');
            await context.read<UsersController>().addNewEvent(eventId, context);
            printOnDebug('[EnterGuestCode] addNewEvent (organizer) completed');

            // Create organizer in firebase
            var organisersMap = {'name': context.read<UsersController>().user!.name, 'image_url': context.read<UsersController>().user!.imageUrl, 'user_id': firebaseAuth.currentUser!.uid, "id_auth_token": auth_firebase.getAuthId(), "event_id": eventId, "phone": phone};

            printOnDebug('Organisers map: $organisersMap');

            printOnDebug('[EnterGuestCode] about to call cloud_firestore.addOrganisers with $organisersMap');
            await cloud_firestore.addOrganisers(organisersMap, eventId, firebaseAuth.currentUser!.uid);
            printOnDebug('[EnterGuestCode] cloud_firestore.addOrganisers completed');

            printOnDebug('[EnterGuestCode] Organisers added');

            printOnDebug('[EnterGuestCode] about to call confirmOrganizerAddition');
            await context.read<EventsController>().confirmOrganizerAddition(eventId, phone);
            printOnDebug('[EnterGuestCode] confirmOrganizerAddition completed');

            // Redirect to organizer homepage
            printOnDebug('[EnterGuestCode] about to call AppInitializer.initOrganiser');
            await AppInitializer()
                .initOrganiser(eventId, context)
                .then((value) {
                  printOnDebug('[EnterGuestCode] initOrganiser succeeded');
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()));
                })
                .catchError((error) {
                  printOnDebug('[EnterGuestCode] initOrganiser failed: $error');
                  Navigator.pop(context);
                });
          } else if (isGuestAllowed) {
            printOnDebug('Event visibility: $eventVisibility');

            lastStep = 'initGuest';
            printOnDebug('[EnterGuestCode] about to call AppInitializer.initGuest');
            await AppInitializer().initGuest(eventId, phone, context);
            printOnDebug('[EnterGuestCode] AppInitializer.initGuest completed');

            if (eventVisibility == "public") {
              lastStep = 'createGuestFromUser';
              printOnDebug('[EnterGuestCode] about to call createGuestFromUser');
              await context.read<GuestsController>().createGuestFromUser(context.read<UsersController>().user!, eventId);
              printOnDebug('[EnterGuestCode] createGuestFromUser completed');

              if (context.mounted) {
                lastStep = 'getGuests';
                printOnDebug('[EnterGuestCode] about to call getGuests');
                await context.read<GuestsController>().getGuests(eventId).then((guests) async {
                  lastStep = 'addGuestsToEvent';
                  printOnDebug('[EnterGuestCode] about to call addGuestsToEvent with ${guests.length} guests');
                  await context.read<GuestsController>().addGuestsToEvent(guests, context);
                  printOnDebug('[EnterGuestCode] addGuestsToEvent completed (public event)');
                });
              }
              lastStep = 'confirmGuestAddition';
              printOnDebug('[EnterGuestCode] about to call confirmGuestAddition');
              await context.read<EventsController>().confirmGuestAddition(eventId, phone, context.read<UsersController>().user!.id);
              printOnDebug('[EnterGuestCode] confirmGuestAddition completed');
            }

            if (!mounted) return;
            printOnDebug('[EnterGuestCode] adding event to user');
            lastStep = 'addNewJoinedEvent';
            printOnDebug('[EnterGuestCode] about to call addNewJoinedEvent');
            await context.read<UsersController>().addNewJoinedEvent(eventId, context);
            printOnDebug('[EnterGuestCode] addNewJoinedEvent completed');
            printOnDebug('[EnterGuestCode] calling checkRSVPs');
            lastStep = 'checkRSVPs';
            printOnDebug('[EnterGuestCode] about to call checkRSVPs');
            await context.read<RSVPController>().checkRSVPs(context);
            printOnDebug('[EnterGuestCode] checkRSVPs completed');
            context.read<UsersController>().updateLastEventId(eventId);
            printOnDebug('[EnterGuestCode] updateLastEventId completed');
            Navigator.pop(context);
            printOnDebug('[EnterGuestCode] about to navigate to GuestWelcomeScreen');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestWelcomeScreen()));
            printOnDebug('[EnterGuestCode] navigation to GuestWelcomeScreen completed');
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous n\'êtes pas invité à cet événement.', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
          }
        }
        break;
  } catch (e, s) {
        printOnDebug('[EnterGuestCode] confirmWhenConnected ERROR at step: $lastStep -> $e');
        printOnDebug('[EnterGuestCode] stacktrace: $s');

        bool retry = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Erreur"),
              content: const Text("Une erreur est survenue. Voulez-vous réessayer ?"),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Annuler")), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Réessayer"))],
            );
          },
        );

        if (!retry) {
          Navigator.pop(context);
          break;
        }
      }
    }
  }

  Future confirmWhenDisconnected() async {
    String lastStep = 'start';
    showLoadingDialog(context); // Show a loading dialog while processing
  printOnDebug('[EnterGuestCode] about to call checkIfEventExistWithCode (disconnected)');
  QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);
  printOnDebug('[EnterGuestCode] checkIfEventExistWithCode (disconnected) returned ${event.docs.length} docs');

    if (event.docs.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun événement trouvé avec ce code.')));
      return;
    }

    try {
      String? eventId;

      lastStep = 'extractEventId';
      if (event.docs.isNotEmpty) {
        eventId = event.docs.first.id;
      } else {
        Navigator.pop(context);
        return;
      }

      lastStep = 'getGuests';
      printOnDebug('[EnterGuestCode] about to call getGuests (disconnected)');
      await context.read<GuestsController>().getGuests(eventId).then((guests) async {
        lastStep = 'addGuestsToEvent';
        printOnDebug('[EnterGuestCode] about to call addGuestsToEvent (disconnected) with ${guests.length} guests');
        await context.read<GuestsController>().addGuestsToEvent(guests, context);
        printOnDebug('[EnterGuestCode] addGuestsToEvent (disconnected) completed');
      });

      lastStep = 'initOrganizerIfNeeded';
      // Safe access to optional field 'code_organizer' for disconnected flow
      try {
        final docData = event.docs.first.data() as Map<String, dynamic>? ?? <String, dynamic>{};
        if (docData.containsKey('code_organizer') && codeController.value.text == (docData['code_organizer'] ?? '')) {
          printOnDebug('[EnterGuestCode] disconnected: code matches organizer code, calling initOrganizer');
          await context.read<EventsController>().initOrganizer(null, context);
        } else if (!docData.containsKey('code_organizer')) {
          printOnDebug('[EnterGuestCode] disconnected: code_organizer not present in event doc, skipping initOrganizer');
        }
      } catch (e) {
        printOnDebug('[EnterGuestCode] disconnected: error reading code_organizer safely: $e');
      }

  lastStep = 'initVisitor';
  printOnDebug('[EnterGuestCode] about to call AppInitializer.initVisitor');
  await AppInitializer().initVisitor(eventId, context);
  printOnDebug('[EnterGuestCode] AppInitializer.initVisitor completed');

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestWelcomeScreen()));
    } catch (e, s) {
      printOnDebug('[EnterGuestCode] confirmWhenDisconnected ERROR at step: $lastStep -> $e');
      printOnDebug('[EnterGuestCode] stacktrace: $s');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingLayout(
      title: 'Code d\'invitation',
      confirm: () async {
        final String reqId = DateTime.now().toIso8601String();
        printOnDebug('[EnterGuestCode][$reqId] confirm pressed with code: ${codeController.text}');
        if (_isProcessing) {
          printOnDebug('[EnterGuestCode][$reqId] confirm ignored: already processing');
          return;
        }
        _isProcessing = true;
        try {
          if (context.read<UsersController>().user != null) {
            printOnDebug('[EnterGuestCode][$reqId] user is logged in, running confirmWhenConnected');
            await confirmWhenConnected();
          } else {
            printOnDebug('[EnterGuestCode][$reqId] no user logged in, running confirmWhenDisconnected');
            await confirmWhenDisconnected();
          }
        } finally {
          _isProcessing = false;
          printOnDebug('[EnterGuestCode][$reqId] processing finished');
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
