import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/editable_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

GlobalKey<MyEditableTextState> rectoEditableTextKey = GlobalKey<MyEditableTextState>();

class CardRecto extends StatefulWidget {
  const CardRecto({super.key});

  @override
  State<CardRecto> createState() => _CardRectoState();
}

class _CardRectoState extends State<CardRecto> {
  @override
  Widget build(BuildContext context) {
    InvitationModule invitation = context.watch<InvitationsController>().currentInvitation;

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    String formatPartyDate(DateTime? date) {
      var formatter = DateFormat('EEEE d MMMM à H:mm', 'fr_FR');
      String formattedDate = formatter.format(date!);

      formattedDate = formattedDate.replaceAll(':', 'h');

      // Divisez la date en parties et mettez en majuscule chaque partie
      List<String> parts = formattedDate.split(' ');
      parts[0] = capitalizeFirstLetter(parts[0]); // Jour
      parts[2] = capitalizeFirstLetter(parts[2]); // Mois

      return parts.join(' ');
    }

    String partyDate = formatPartyDate(Event.instance.modules.where((element) => element.type == 'wedding').first.date);

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
              children: [
                MyEditableText(
                  key: rectoEditableTextKey,
                  initialText: invitation.title,
                  onConfirmation: (value, map) async {
                    invitation.title = value;
                    await context.read<InvitationsController>().updateStyleMap('titleStyle', map);
                  },
                  styleMap: invitation.titleStyle,
                ),
                const SizedBox(height: 10.0),
                MyEditableText(
                  initialText: invitation.partyDateRecto == '' ? partyDate : invitation.partyDateRecto,
                  onConfirmation: (value, map) async {
                    if (value == partyDate) {
                      invitation.partyDateRecto = '';
                    } else {
                      invitation.partyDateRecto = value;
                    }

                    await context.read<InvitationsController>().updateStyleMap('partyDateRectoStyle', map);
                  },
                  styleMap: invitation.partyDateRectoStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
