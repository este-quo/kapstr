import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/modules/golden_book.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/golden_book/profile_picture.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.moduleId, required this.message, this.length, this.index});

  final String moduleId;
  final GoldenBookMessage message;
  final int? length;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Guest>(
      future: context.read<GoldenBookController>().getGuestFromMessages(moduleId, message),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affichez un indicateur de chargement si la requête est en cours
          return const Center(child: SizedBox(height: 32, width: 32, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 32)));
        } else if (snapshot.hasError) {
          // Affichez une erreur si quelque chose s'est mal passé
          return const Text('Erreur lors du chargement des données');
        } else if (snapshot.hasData) {
          // Les données du guest sont chargées, construisez l'UI avec ces données
          Guest guest = snapshot.data!;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Message Container
              Container(
                padding: const EdgeInsets.only(top: 62, left: 16, right: 16, bottom: 16),
                margin: const EdgeInsets.only(top: 40),
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1)),
                child: Column(
                  children: [
                    Text(message.message, textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 22, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily)),
                    const Spacer(),
                    Text(
                      capitalizeNames(guest.name), // Utilisation des données du guest
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kBlack, fontSize: 26, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.greatVibes().fontFamily),
                    ),
                    const SizedBox(height: 8),
                    if (index != null && length != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${index! + 1} / $length', style: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400))]),
                  ],
                ),
              ),

              // Profile Picture
              Positioned(top: 1, child: ProfilePicture(name: guest.name, imageUrl: guest.imageUrl, moduleId: moduleId, message: message, guest: guest)),
            ],
          );
        } else {
          // Affichez un message si aucune donnée n'est disponible
          return Text('Aucune message disponible pour le moment, revenez plus tard !', style: TextStyle(color: context.read<ThemeController>().getTextColor(), fontSize: 16, fontWeight: FontWeight.w400));
        }
      },
    );
  }
}
