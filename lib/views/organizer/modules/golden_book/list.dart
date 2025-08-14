import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/evently_message.dart';
import 'package:kapstr/views/organizer/modules/golden_book/guest_tile.dart';

import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:provider/provider.dart';

class GoldenBookOrganiserList extends StatelessWidget {
  const GoldenBookOrganiserList({super.key, required this.moduleId, required this.messages});

  final String moduleId;
  final List<GoldenBookMessage> messages;

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: context.read<ThemeController>().getTextColor()), Text('Retour', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : Colors.transparent,
      body: BackgroundTheme(
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Livre d'or", textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w600)),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text('${messages.length} invités vous ont laissé un message', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: context.read<ThemeController>().getTextColor(), fontWeight: FontWeight.w400)),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // Messages tiles
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Pour éviter le scroll imbriqué
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EventlyMessage()));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                            height: 64,
                            width: MediaQuery.of(context).size.width - 40,
                            decoration: BoxDecoration(color: context.watch<EventsController>().event.fullResThemeUrl == '' ? kWhite : kWhite.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Padding
                                const SizedBox(width: 16),

                                // Profile picture
                                SizedBox(width: 48, height: 48, child: ClipRRect(borderRadius: BorderRadius.circular(50), child: SizedBox(width: 80, height: 80, child: Image.asset('assets/logos/evently_logo.png', fit: BoxFit.cover)))),

                                // Padding
                                const SizedBox(width: 16),

                                // Name
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Kapstr', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                                        const SizedBox(width: 4),
                                        const Text("•", style: TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                                        const SizedBox(width: 4),
                                        Text(getElapsedTime(Event.instance.createdAt!), style: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        "Félicitations aux jeunes mariés ! Que ce jour spécial marque le début d'une vie remplie de bonheur et d'amour. Nous vous souhaitons tout le meilleur pour l'avenir. Avec nos vœux les plus chaleureux, L'équipe Kapstr",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),

                                // Spacer
                                const Spacer(),
                              ],
                            ),
                          ),
                        );
                      } else {
                        var adjustedIndex = index - 1;
                        var message = messages[adjustedIndex];
                        return GuestTile(moduleId: moduleId, message: message);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
