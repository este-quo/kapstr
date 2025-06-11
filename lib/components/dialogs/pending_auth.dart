import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/home/configuration.dart';
import 'package:provider/provider.dart';

class PendingAuthentificationDialog extends StatelessWidget {
  const PendingAuthentificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenez l'événement actuel depuis le provider ou une autre source
    final event = Event.instance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Afficher l'image principale de l'événement
          if (event.modules[0].image.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(event.modules[0].image, height: 150, width: double.infinity, fit: BoxFit.cover)),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.4), // Opacité pour texte lisible
                  ),
                ),
                Text(
                  event.womanFirstName != ""
                      ? "${event.womanFirstName} & ${event.manFirstName}"
                      : event.eventName != ""
                      ? event.eventName
                      : "${event.eventType}: ${event.manFirstName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 16),
          // Titre de l'événement
          Text("Bienvenue en tant qu'invité, répondez à votre invitation et profitez de toutes les fonctionnalités de cet évènement", textAlign: TextAlign.center, style: const TextStyle(color: kDarkGrey, fontSize: 14)),
          const SizedBox(height: 16),
          // Bouton pour rediriger vers l'événement
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              QuerySnapshot currentUser = await context.read<UsersController>().currentUser();
              String? phone = currentUser.docs.first["phone"];
              if (phone != null) {
                await AppInitializer().initGuest(Event.instance.id, phone, context);

                if (context.read<EventsController>().isOrganizerCodeEntered) {
                  await context.read<EventsController>().initOrganizer(phone, context);
                }

                await context.read<UsersController>().addNewJoinedEvent(Event.instance.id, context);

                await context.read<RSVPController>().checkRSVPs(context);

                context.read<UsersController>().updateLastEventId(Event.instance.id);

                context.read<AuthenticationController>().setPendingConnection(false);

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestHomepageConfiguration()));
              }
            },
            child: const Text('Retourner à l\'événement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kWhite)),
          ),
          const SizedBox(height: 8),
          // Texte d'information
        ],
      ),
    );
  }
}
