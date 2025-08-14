import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/invitations.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/editable_text.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

GlobalKey<MyEditableTextState> versoEditableTextKey = GlobalKey<MyEditableTextState>();

class CardVerso extends StatefulWidget {
  const CardVerso({super.key});

  @override
  State<CardVerso> createState() => _CardVersoState();
}

class _CardVersoState extends State<CardVerso> {
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
    String? partyPlaceAdress = Event.instance.modules.where((element) => element.type == 'wedding').first.placeAddress;
    String? partyPlaceName = Event.instance.modules.where((element) => element.type == 'wedding').first.placeName;

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
                  MyEditableText(
                    key: versoEditableTextKey,
                    initialText: invitation.names,
                    onConfirmation: (value, map) async {
                      invitation.names = value;
                      await context.read<InvitationsController>().updateStyleMap('namesStyles', map);
                    },
                    styleMap: invitation.namesStyles,
                  ),

                  const SizedBox(height: 32),

                  // Introduction
                  MyEditableText(
                    initialText: invitation.introduction,
                    onConfirmation: (value, map) async {
                      invitation.introduction = value;
                      await context.read<InvitationsController>().updateStyleMap('introductionStyle', map);
                    },
                    styleMap: invitation.introductionStyle,
                  ),

                  const SizedBox(height: 32),

                  // Party date
                  MyEditableText(
                    initialText: invitation.partyDateVerso == '' ? partyDate : invitation.partyDateVerso,
                    onConfirmation: (value, map) async {
                      if (value == partyDate) {
                        invitation.partyDateVerso = '';
                      } else {
                        invitation.partyDateVerso = value;
                      }
                      await context.read<InvitationsController>().updateStyleMap('partyDateVersoStyle', map);
                    },
                    styleMap: invitation.partyDateVersoStyle,
                  ),

                  // Text
                  MyEditableText(
                    initialText: invitation.partyLinking,
                    onConfirmation: (value, map) async {
                      invitation.partyLinking = value;

                      await context.read<InvitationsController>().updateStyleMap('partyLinkingStyle', map);
                    },
                    styleMap: invitation.partyLinkingStyle,
                  ),

                  // Party place name
                  MyEditableText(
                    initialText: invitation.partyPlaceName == '' ? partyPlaceName ?? 'Nom du lieu' : invitation.partyPlaceName,
                    onConfirmation: (value, map) async {
                      if (value == 'Nom du lieu') {
                        invitation.partyPlaceName = '';
                      } else {
                        invitation.partyPlaceName = value;
                      }
                      await context.read<InvitationsController>().updateStyleMap('partyPlaceNameStyle', map);
                    },
                    styleMap: invitation.partyPlaceNameStyle,
                  ),

                  const SizedBox(height: 32),

                  // Party place adress
                  MyEditableText(
                    initialText: invitation.partyPlaceAdress == '' ? partyPlaceAdress ?? 'Adresse du lieu' : invitation.partyPlaceAdress,
                    onConfirmation: (value, map) async {
                      if (value == 'Adresse du lieu') {
                        invitation.partyPlaceAdress = '';
                      } else {
                        invitation.partyPlaceAdress = value;
                      }
                      await context.read<InvitationsController>().updateStyleMap('partyPlaceAdressStyle', map);
                    },
                    styleMap: invitation.partyPlaceAdressStyle,
                  ),

                  const SizedBox(height: 12),

                  // Conclusion
                  MyEditableText(
                    initialText: invitation.conclusion,
                    onConfirmation: (value, map) async {
                      invitation.conclusion = value;

                      await context.read<InvitationsController>().updateStyleMap('conclusionStyle', map);
                    },
                    styleMap: invitation.conclusionStyle,
                  ),

                  // const SizedBox(height: 32),

                  // // Contacts
                  // MyEditableText(
                  //   initialText: invitation.contact1,
                  //   onConfirmation: (value, map) async {
                  //     invitation.contact1 = value;

                  //     await context.read<InvitationsController>().updateStyleMap('contact1Style', map);
                  //   },
                  //   styleMap: invitation.contact1Style,
                  // ),

                  // invitation.contact2 == ""
                  //     ? const SizedBox(height: 0)
                  //     : MyEditableText(
                  //         initialText: invitation.contact2,
                  //         onConfirmation: (value, map) async {
                  //           invitation.contact2 = value;

                  //           await context.read<InvitationsController>().updateStyleMap('contact2Style', map);
                  //         },
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
