import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DeleteGuestsButton extends StatelessWidget {
  const DeleteGuestsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GuestsController>(
      builder: (context, globalGuestProvider, child) {
        List<Guest> selectedGuests = globalGuestProvider.selectedGuests;

        if (!globalGuestProvider.hasAtLeastOneSelected()) return const SizedBox();

        return TextButton(
          onPressed: () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: kWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  surfaceTintColor: kWhite,
                  title: const Text('Confirmer la suppression'),
                  content: Text(selectedGuests.length > 1 ? 'Êtes-vous sûr de vouloir supprimer ${selectedGuests.length} invités ?' : 'Êtes-vous sûr de vouloir supprimer ${selectedGuests.length} invité ?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Annuler'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text('Confirmer'),
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
                for (var guest in selectedGuests) {
                  await globalGuestProvider.deleteGuest(guest.id);
                  globalGuestProvider.selectedGuests.remove(guest);
                }
              } catch (e) {
                printOnDebug("Erreur lors de la suppression des invités: $e");
              }
            }
          },
          child: Text(textAlign: TextAlign.center, selectedGuests.length > 1 ? 'Supprimer ${selectedGuests.length} invités' : 'Supprimer ${selectedGuests.length} invité', style: const TextStyle(color: kDanger, fontSize: 16.0, fontWeight: FontWeight.w400)),
        );
      },
    );
  }
}
