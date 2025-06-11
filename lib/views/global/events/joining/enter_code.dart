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
    while (true) {
      try {
        QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);

        if (event.docs.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun événement trouvé avec ce code.')));
          return;
        }

        QuerySnapshot currentUser = await context.read<UsersController>().currentUser();

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
          bool isGuestAllowed = await context.read<EventsController>().checkIfGuestIsAllowed(eventId, codeController.text, phone, eventVisibility!);

          if (codeController.value.text == event.docs.first["code_organizer"]) {
            await context.read<EventsController>().initOrganizer(phone, context);
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
            await context.read<UsersController>().addNewEvent(eventId, context);

            // Create organizer in firebase
            var organisersMap = {'name': context.read<UsersController>().user!.name, 'image_url': context.read<UsersController>().user!.imageUrl, 'user_id': firebaseAuth.currentUser!.uid, "id_auth_token": auth_firebase.getAuthId(), "event_id": eventId, "phone": phone};

            printOnDebug('Organisers map: $organisersMap');

            await cloud_firestore.addOrganisers(organisersMap, eventId, firebaseAuth.currentUser!.uid);

            printOnDebug('Organisers added');

            await context.read<EventsController>().confirmOrganizerAddition(eventId, phone);

            // Redirect to organizer homepage
            await AppInitializer()
                .initOrganiser(eventId, context)
                .then((value) {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()));
                })
                .catchError((error) {
                  Navigator.pop(context);
                });
          } else if (isGuestAllowed) {
            printOnDebug('Event visibility: $eventVisibility');

            await AppInitializer().initGuest(eventId, phone, context);

            if (eventVisibility == "public") {
              await context.read<GuestsController>().createGuestFromUser(context.read<UsersController>().user!, eventId);

              if (context.mounted) {
                await context.read<GuestsController>().getGuests(eventId).then((guests) async {
                  await context.read<GuestsController>().addGuestsToEvent(guests, context);
                });
              }
              await context.read<EventsController>().confirmGuestAddition(eventId, phone, context.read<UsersController>().user!.id);
            }

            if (!mounted) return;
            await context.read<UsersController>().addNewJoinedEvent(eventId, context);
            await context.read<RSVPController>().checkRSVPs(context);
            context.read<UsersController>().updateLastEventId(eventId);
            Navigator.pop(context);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestWelcomeScreen()));
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous n\'êtes pas invité à cet événement.', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
          }
        }
        break;
      } catch (e) {
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
    showLoadingDialog(context); // Show a loading dialog while processing
    QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(codeController.text);

    if (event.docs.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun événement trouvé avec ce code.')));
      return;
    }

    try {
      String? eventId;

      if (event.docs.isNotEmpty) {
        eventId = event.docs.first.id;
      } else {
        Navigator.pop(context);
        return;
      }

      await context.read<GuestsController>().getGuests(eventId).then((guests) async {
        await context.read<GuestsController>().addGuestsToEvent(guests, context);
      });

      if (codeController.value.text == event.docs.first["code_organizer"]) {
        await context.read<EventsController>().initOrganizer(null, context);
      }

      await AppInitializer().initVisitor(eventId, context);

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestWelcomeScreen()));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingLayout(
      title: 'Code d\'invitation',
      confirm: () async {
        context.read<UsersController>().user != null ? await confirmWhenConnected() : await confirmWhenDisconnected();
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
