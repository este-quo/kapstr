import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/message.dart';
import 'package:kapstr/views/organizer/modules/golden_book/profile_picture.dart';
import 'package:kapstr/views/organizer/modules/golden_book/skeleton.dart';
import 'package:provider/provider.dart';

class GuestTile extends StatelessWidget {
  const GuestTile({super.key, required this.moduleId, required this.message});

  final String moduleId;
  final GoldenBookMessage message;

  @override
  Widget build(BuildContext context) {
    String getMonthName(int monthNumber) {
      const monthNames = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"];
      return monthNames[monthNumber - 1];
    }

    String getElapsedTime(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        // Plus d'un mois, retourner la date
        return "${date.day} ${getMonthName(date.month)}";
      } else if (difference.inDays >= 1) {
        // Entre un jour et un mois, retourner le nombre de jours
        return "${difference.inDays}j";
      } else if (difference.inHours >= 1) {
        // Entre une heure et un jour, retourner le nombre d'heures
        return "${difference.inHours}h";
      } else {
        // Moins d'une heure, retourner le nombre de minutes
        return "${difference.inMinutes}m";
      }
    }

    return FutureBuilder<Guest>(
      future: context.read<GoldenBookController>().getGuestFromMessages(moduleId, message),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affichez un indicateur de chargement si la requête est en cours
          return const GuestTileSkeleton();
        } else if (snapshot.hasError) {
          // Affichez une erreur si quelque chose s'est mal passé
          return const Center(child: Text('Erreur lors du chargement des données'));
        } else if (snapshot.hasData) {
          // Les données du guest sont chargées, construisez l'UI avec ces données
          Guest guest = snapshot.data!;

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GuestMessage(moduleId: moduleId, message: message, guest: guest)));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              height: 64,
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(color: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : kWhite.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Padding
                  const SizedBox(width: 16),

                  // Profile picture
                  SizedBox(width: 48, height: 48, child: ProfilePicture(name: guest.name, imageUrl: guest.imageUrl, moduleId: moduleId, message: message, guest: guest)),

                  // Padding
                  const SizedBox(width: 16),

                  // Name
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(guest.name, style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                          const SizedBox(width: 4),
                          const Text("•", style: TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                          const SizedBox(width: 4),
                          Text(getElapsedTime(message.date), style: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      SizedBox(width: 200, child: Text(message.message, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400))),
                    ],
                  ),

                  // Spacer
                  const Spacer(),
                ],
              ),
            ),
          );
        }

        // Si les données n'ont pas encore été récupérées, affichez un indicateur de chargement
        return const GuestTileSkeleton();
      },
    );
  }
}
