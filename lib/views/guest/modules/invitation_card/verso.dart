import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/invitation_card/display_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class CardVersoGuest extends StatefulWidget {
  const CardVersoGuest({super.key});

  @override
  State<CardVersoGuest> createState() => _CardVersoState();
}

class _CardVersoState extends State<CardVersoGuest> {
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
    String? weddingPlaceAdress = Event.instance.modules.where((element) => element.type == 'wedding').first.placeAddress;
    String? weddingPlaceName = Event.instance.modules.where((element) => element.type == 'wedding').first.placeName;

    String getNames() {
      String names = '';

      Event.instance.womanFirstName == '' ? names = Event.instance.manFirstName : names = '${Event.instance.manFirstName} & ${Event.instance.womanFirstName}';
      return names;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: kWhite, boxShadow: [kBoxShadow]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackgroundTheme(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 48),

                  // Names
                  MyDisplayText(text: invitation.names == '' ? getNames() : invitation.names, styleMap: invitation.namesStyles),

                  const SizedBox(height: 32),

                  // Introduction
                  MyDisplayText(text: invitation.introduction, styleMap: invitation.introductionStyle),

                  const SizedBox(height: 32),

                  // wEDDING date
                  MyDisplayText(text: invitation.partyDateVerso == "" ? weddingDate : invitation.partyDateVerso, styleMap: invitation.partyDateVersoStyle),

                  // Text
                  MyDisplayText(text: invitation.partyLinking, styleMap: invitation.partyLinkingStyle),

                  // Wedding place name
                  MyDisplayText(text: invitation.partyPlaceName == "" ? weddingPlaceAdress ?? 'Nom du lieu' : invitation.partyPlaceName, styleMap: invitation.partyPlaceNameStyle),

                  const SizedBox(height: 32),

                  MyDisplayText(text: invitation.partyPlaceAdress == "" ? weddingPlaceName ?? 'Adresse du lieu' : invitation.partyPlaceAdress, styleMap: invitation.partyPlaceAdressStyle),

                  const SizedBox(height: 12),

                  // Conclusion
                  MyDisplayText(text: invitation.conclusion, styleMap: invitation.conclusionStyle),

                  // const SizedBox(height: 32),

                  // // Contacts
                  // MyDisplayText(
                  //   text: invitation.contact1,
                  //   styleMap: invitation.contact1Style,
                  // ),

                  // invitation.contact2 == ""
                  //     ? const SizedBox(height: 0)
                  //     : MyDisplayText(
                  //         text: invitation.contact2,
                  //         styleMap: invitation.contact2Style,
                  //       ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
