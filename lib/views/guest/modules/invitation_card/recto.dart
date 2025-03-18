import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/invitation_card/display_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CardRectoGuest extends StatefulWidget {
  const CardRectoGuest({super.key});

  @override
  State<CardRectoGuest> createState() => _CardRectoState();
}

class _CardRectoState extends State<CardRectoGuest> {
  @override
  Widget build(BuildContext context) {
    InvitationModule invitation = context.read<InvitationsController>().currentInvitation;

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    String formatWeddingDate(DateTime? date) {
      var formatter = DateFormat('EEEE d MMMM à H:mm', 'fr_FR');
      String formattedDate = formatter.format(date!);

      formattedDate = formattedDate.replaceAll(':', 'h');

      // Divisez la date en parties et mettez en majuscule chaque partie
      List<String> parts = formattedDate.split(' ');
      parts[0] = capitalizeFirstLetter(parts[0]); // Jour
      parts[2] = capitalizeFirstLetter(parts[2]); // Mois

      return parts.join(' ');
    }

    String weddingDate = formatWeddingDate(Event.instance.modules.where((element) => element.type == 'wedding').first.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: kWhite, boxShadow: [kBoxShadow]),
      height: 600,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackgroundTheme(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [MyDisplayText(text: invitation.title, styleMap: invitation.titleStyle), const SizedBox(height: 10.0), MyDisplayText(text: invitation.partyDateRecto == "" ? weddingDate : invitation.partyDateRecto, styleMap: invitation.partyDateRectoStyle)],
            ),
          ),
        ),
      ),
    );
  }
}
