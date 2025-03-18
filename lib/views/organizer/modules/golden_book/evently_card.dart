import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';

class EventlyMessageCard extends StatelessWidget {
  const EventlyMessageCard({super.key, this.length, this.index});

  final int? length;
  final int? index;

  String getEventMessage() {
    switch (Event.instance.eventType) {
      case 'mariage':
        return "Félicitations aux jeunes mariés ! Que ce jour spécial marque le début d'une vie remplie de bonheur et d'amour. Nous vous souhaitons tout le meilleur pour l'avenir.";
      case 'anniversaire':
        return "Joyeux anniversaire ! Que cette année de plus soit le début de nouvelles aventures remplies de joie et de réussites.";
      case 'gala':
        return "Nous vous souhaitons une soirée mémorable et pleine de succès lors de ce gala exceptionnel. Profitez bien de cette célébration !";
      case 'entreprise':
        return "Bienvenue à cet événement d'entreprise. Nous espérons que vous trouverez inspiration et opportunités dans chaque moment partagé aujourd'hui.";
      case 'bar mitsvah':
        return "Félicitations pour cette étape importante. Que cette Bar Mitzvah marque le début d'une vie pleine de foi et de sagesse.";
      case 'salon':
        return "Bienvenue à ce salon. Nous espérons que vous découvrirez des innovations et des idées enrichissantes tout au long de l'événement.";
      case 'soirée':
        return "Que la fête commence ! Amusez-vous et faites de cette soirée un moment inoubliable.";
      default:
        return "Bienvenue à cet événement spécial. Nous vous souhaitons une expérience mémorable et enrichissante.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Message Container
        Container(
          padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(top: 40),
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1)),
          child: Column(
            children: [
              Text(getEventMessage(), textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 22, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily)),
              const Spacer(),
              Text('Kapstr', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 26, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.greatVibes().fontFamily)),
              const SizedBox(height: 8),
              if (index != null && length != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${index! + 1} / $length', style: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400))]),
            ],
          ),
        ),
        // Profile Picture
        Positioned(
          top: 1,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Event.instance.fullResThemeUrl == '' ? kLightGrey.withOpacity(0.2) : kWhite, borderRadius: BorderRadius.circular(100), border: Border.all(color: kLighterGrey, width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
            child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Center(child: Image.asset('assets/logos/evently_logo.png', fit: BoxFit.cover))),
          ),
        ),
      ],
    );
  }
}
