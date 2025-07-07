import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/views/guest/home/configuration.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class GuestWelcomeScreen extends StatefulWidget {
  const GuestWelcomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GuestWelcomeScreenState();
}

class _GuestWelcomeScreenState extends State<GuestWelcomeScreen> {
  @override
  void initState() {
    print(Event.instance.eventType);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: IcButton(
        backgroundColor: kBlack,
        borderColor: const Color.fromARGB(30, 0, 0, 0),
        borderWidth: 1,
        height: 48,
        radius: 8,
        width: MediaQuery.of(context).size.width - 40,
        onPressed: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GuestHomepageConfiguration()));
        },
        child: const Text('Suivant', style: TextStyle(color: kWhite, fontSize: 16, fontFamily: "Inter", fontWeight: FontWeight.w600)),
      ),
      backgroundColor: kWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(image: DecorationImage(colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.srcOver), image: NetworkImage(Event.instance.saveTheDateThumbnail), fit: BoxFit.cover)),
            child: const SizedBox.shrink(),
          ),

          // Texts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getWelcomeMessage(Event.instance.eventType), style: TextStyle(color: kBlack, fontSize: 24, height: 1.2, fontFamily: "Inter", fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                Text(
                  Event.instance.womanFirstName != '' ? '${capitalize(Event.instance.manFirstName)} & ${capitalize(Event.instance.womanFirstName)}' : '${capitalize(Event.instance.manFirstName)}',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: kBlack),
                ),
                const SizedBox(height: 16),

                // Welcome text
                Text("Nous sommes ravis de vous accueillir à cet événement", style: TextStyle(color: kBlack, fontSize: 16, fontFamily: "Inter", fontWeight: FontWeight.w400)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String getWelcomeMessage(String eventType) {
  switch (eventType.toLowerCase()) {
    case 'mariage':
      return "Bienvenue sur\nl’application officielle de mariage de";
    case 'salon':
      return "Bienvenue sur\nl’application officielle du salon de";
    case 'gala':
      return "Bienvenue sur\nl’application officielle du gala de";
    case 'soirée':
      return "Bienvenue sur\nl’application officielle de la soirée de";
    case 'anniversaire':
      return "Bienvenue sur\nl’application officielle de l’anniversaire de";
    case 'entreprise':
      return "Bienvenue sur\nl’application officielle de l’événement d'entreprise de";
    case 'bar mitsvah':
      return "Bienvenue sur\nl’application officielle de la bar mitsvah de";
    default:
      return "Bienvenue sur\nl’application officielle de l’événement de";
  }
}
