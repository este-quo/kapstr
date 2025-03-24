// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/components/dialogs/delete_event.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/guest/home/configuration.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:kapstr/services/firebase/authentication/auth_firebase.dart' as auth_firebase;

class JoinedEventCard extends StatefulWidget {
  const JoinedEventCard({super.key, required this.eventData, required this.eventCode, required this.eventDate, required this.callBack, required this.eventId});

  final Map<String, dynamic> eventData;
  final String eventCode;
  final String eventDate;
  final String eventId;

  final Function callBack;

  @override
  State<JoinedEventCard> createState() => _JoinedEventCardState();
}

class _JoinedEventCardState extends State<JoinedEventCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String eventName = widget.eventData["event_name"];
    String eventType = widget.eventData["event_type"];
    String manFirstName = widget.eventData["man_first_name"];
    String womanFirstName = widget.eventData["woman_first_name"];

    String displayName;

    if (eventName != '') {
      displayName = eventName;
    } else {
      if (eventType == 'mariage') {
        displayName = '$manFirstName & $womanFirstName';
      } else {
        displayName = manFirstName;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(boxShadow: [kBoxShadow], color: kWhite, borderRadius: BorderRadius.circular(8), border: context.read<UsersController>().lastEventId == widget.eventId ? Border.all(color: kPrimary, width: 1) : null),
      child: InkWell(
        onTap: () async {
          triggerShortVibration();
          showLoadingDialog(context);
          QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(widget.eventCode);
          QuerySnapshot currentUser = await context.read<UsersController>().currentUser();

          try {
            String? eventId;
            String? phone;
            String? eventVisibility;

            if (event.docs.isNotEmpty) {
              eventId = event.docs.first.id;
              eventVisibility = event.docs.first["visibility"];
            } else {
              Navigator.pop(context); // Close the loading dialog
              return;
            }

            if (currentUser.docs.isNotEmpty) {
              phone = currentUser.docs.first["phone"];
            } else {
              Navigator.pop(context); // Close the loading dialog
              return;
            }

            if (phone != null) {
              if (context.mounted) {
                bool isGuestAllowed = await context.read<EventsController>().checkIfGuestIsAllowed(eventId, widget.eventCode, phone, eventVisibility!);

                if (isGuestAllowed) {
                  // Assuming 'organizer_to_add' can be either a String or a List<String>

                  var organizerToAddField = event.docs.first["organizer_added"];
                  bool isOrganizer;

                  if (organizerToAddField is String) {
                    // If 'organizer_to_add' is a single String
                    isOrganizer = organizerToAddField == phone;
                  } else if (organizerToAddField is List) {
                    // If 'organizer_to_add' is a List
                    isOrganizer = organizerToAddField.contains(phone);
                  } else {
                    // Default case if 'organizer_to_add' is neither String nor List
                    isOrganizer = false;
                  }

                  if (isOrganizer) {
                    await context.read<EventsController>().joinedToCreatedEvent(eventId);

                    // Create organizer in firebase
                    var organisersMap = {'name': context.read<UsersController>().user!.name, 'image_url': context.read<UsersController>().user!.imageUrl, 'user_id': firebaseAuth.currentUser!.uid, "id_auth_token": auth_firebase.getAuthId(), "event_id": eventId, "phone": phone};

                    await cloud_firestore.addOrganisers(organisersMap, eventId, firebaseAuth.currentUser!.uid);

                    context.read<UsersController>().updateLastEventId(eventId);
                    await AppInitializer()
                        .initOrganiser(eventId, context)
                        .then((value) {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration())).then((value) => widget.callBack());
                        })
                        .catchError((error) {
                          Navigator.pop(context);
                        });
                  } else {
                    await AppInitializer().initGuest(eventId, phone, context);

                    if (!mounted) return;
                    await context.read<UsersController>().addNewJoinedEvent(eventId, context);

                    await context.read<RSVPController>().checkRSVPs(context);

                    context.read<UsersController>().updateLastEventId(eventId);

                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GuestHomepageConfiguration())).then((value) => widget.callBack());
                  }
                } else {
                  Navigator.pop(context); // Close the loading dialog
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous n\'êtes pas invité à cet évènement')));
                }
              }
            }
          } catch (e) {
            Navigator.pop(context); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.')));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 104, height: 140, decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)), image: DecorationImage(image: NetworkImage(widget.eventData["save_the_date_thumbnail"]), fit: BoxFit.cover))),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capitalizeNames(widget.eventData["event_type"]), style: const TextStyle(textBaseline: TextBaseline.alphabetic, color: kLightGrey, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        Flex(
                          direction: Axis.horizontal,
                          children: [Flexible(child: Text(displayName, style: const TextStyle(textBaseline: TextBaseline.alphabetic, overflow: TextOverflow.ellipsis, color: kBlack, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start))],
                        ),
                      ],
                    ),
                    Text(widget.eventDate, style: const TextStyle(textBaseline: TextBaseline.alphabetic, color: kBlack, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PopupMenuButton(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  padding: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  shadowColor: kBlack.withValues(alpha: 0.2),
                  icon: const Icon(Icons.more_vert, color: kBlack),
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Quitter', textAlign: TextAlign.right, style: TextStyle(color: kDanger, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400)), Icon(Icons.logout, color: kDanger)]),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      showDeleteEventDialog(
                        context,
                        onConfirm: () async {
                          QuerySnapshot event = await context.read<EventsController>().checkIfEventExistWithCode(widget.eventCode);
                          await context.read<EventsController>().leaveEvent(event.docs.first.id, context);

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyEvents(isPendingVerif: false)), (Route<dynamic> route) => false);

                          setState(() {}); // Reconstruit la page après la fermeture
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Événement quitté', style: TextStyle(color: kWhite, fontWeight: FontWeight.w400, fontSize: 14)), backgroundColor: kSuccess));
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 1), // Fond presque blanc
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (value) async => false, // Empêche le retour à l'écran précédent
          child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
        );
      },
    );
  }
}
