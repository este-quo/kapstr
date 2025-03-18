import 'package:flutter/material.dart';
import 'package:kapstr/components/dialogs/organizer_sms_dialog.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

Future showGuestDialog(BuildContext context, Guest guest) async {
  bool isCoOrganizer = Event.instance.organizerAdded.contains(guest.phone); // État pour gérer l'on/off

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permet d'utiliser la totalité de l'écran si nécessaire
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton "Co-organisateur" avec commutateur On/Off
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kWhite, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                    onPressed: () async {
                      setState(() {
                        isCoOrganizer = !isCoOrganizer; // Basculer l'état
                      });
                      await updateCoOrganizers(isCoOrganizer, guest, context); // Appeler la fonction
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligner le texte à gauche et l'icône à droite
                      children: [
                        const Text(
                          'Co-organisateur',
                          style: TextStyle(
                            fontSize: 16,
                            color: kBlack, // Changer la couleur du texte
                          ),
                        ),
                        Switch(
                          value: isCoOrganizer, // L'état du commutateur
                          activeColor: kPrimary,
                          onChanged: (value) async {
                            setState(() {
                              isCoOrganizer = value;
                            });

                            await updateCoOrganizers(value, guest, context); // Appeler la fonction
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton "Supprimer cet invité"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: kWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            surfaceTintColor: kWhite,
                            title: const Text('Confirmer la suppression'),
                            content: const Text('Êtes-vous sûr de vouloir supprimer cet invité ?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Annuler'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Confirmer'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          // Supprimer l'invité du modèle global et de la base de données
                          await context.read<GuestsController>().deleteGuest(guest.id);
                          Navigator.of(context).pop(); // Fermer le modal une fois l'invité supprimé
                        } catch (e) {
                          print("Erreur lors de la suppression de l'invité: $e");
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Supprimer cet invité',
                          style: TextStyle(
                            fontSize: 16,
                            color: kAbsent, // Changer la couleur du texte
                          ),
                        ),
                        const Icon(Icons.delete, color: kAbsent), // Icône à droite
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future updateCoOrganizers(bool isCoOrganizer, Guest guest, BuildContext context) async {
  if (isCoOrganizer) {
    await showDialog(
      context: context,
      builder: (context) {
        return CoOrganizerSMSDialog(
          onSend: () async {
            await sendSMS([guest.phone], getCoOrganizerMessage(Event.instance.eventType));
            Navigator.of(context).pop();
          },
          onSkip: () {
            Navigator.of(context).pop();
          },
        );
      },
    );

    Event.instance.addOrganizer(guest.phone);

    await context.read<EventsController>().updateEventField(key: 'organizer_added', value: Event.instance.organizerAdded);

    await context.read<EventsController>().updateEventField(key: 'organizer_to_add', value: Event.instance.organizerAdded);
  } else {
    Event.instance.removeOrganizerAdded(guest.phone);

    await context.read<EventsController>().updateEventField(key: 'organizer_added', value: Event.instance.organizerAdded);
  }
}
