import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/views/global/theme_custom/choose_color.dart';
import 'package:kapstr/views/global/theme_custom/custom_card.dart';

class AppCustom extends StatefulWidget {
  const AppCustom({super.key});

  @override
  AppCustomState createState() => AppCustomState();
}

class AppCustomState extends State<AppCustom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Row(children: [Icon(size: 16, Icons.arrow_back_ios, color: Colors.black), Text('Retour', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
      ),
      backgroundColor: kWhite,
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text('Couleurs', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () async {
                final selectedColor = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseCustomColor(type: 'textColor', colorStringToUpdate: Event.instance.textColor == '' ? '000000' : Event.instance.textColor, description: "Choisissez la couleur du texte de l'application", isBackgroundColor: false)),
                );

                if (selectedColor != null) {
                  printOnDebug('$selectedColor selectedColor');
                  setState(() {
                    Event.instance.textColor = selectedColor;
                  });

                  context.read<ThemeController>().updateTextColor(selectedColor);

                  await context.read<EventsController>().updateEventField(key: 'text_color', value: selectedColor);
                }
              },
              child: AppCustomCard(title: 'Couleur textes', color: Event.instance.textColor == '' ? '000000' : Event.instance.textColor),
            ),
            mediumSpacerH(),
            GestureDetector(
              onTap: () async {
                final selectedColor = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseCustomColor(type: 'buttonColor', colorStringToUpdate: Event.instance.buttonColor == '' ? '000000' : Event.instance.buttonColor, description: "Choisissez la couleur des boutons de l'application", isBackgroundColor: false)),
                );

                if (selectedColor != null) {
                  printOnDebug('$selectedColor selectedColor');
                  setState(() {
                    Event.instance.buttonColor = selectedColor;
                  });
                  context.read<ThemeController>().updateButtonColor(selectedColor);

                  await context.read<EventsController>().updateEventField(key: 'button_color', value: selectedColor);
                }
              },
              child: AppCustomCard(title: 'Couleur boutons', color: Event.instance.buttonColor == '' ? '000000' : Event.instance.buttonColor),
            ),
            mediumSpacerH(),
            GestureDetector(
              onTap: () async {
                final selectedColor = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseCustomColor(type: 'buttonTextColor', colorStringToUpdate: Event.instance.buttonTextColor == '' ? 'ffffff' : Event.instance.buttonTextColor, description: "Choisissez la couleur du texte de l'application", isBackgroundColor: false)),
                );

                if (selectedColor != null) {
                  printOnDebug('$selectedColor selectedColor');
                  setState(() {
                    Event.instance.buttonTextColor = selectedColor;
                  });

                  context.read<ThemeController>().updateButtonTextColor(selectedColor);

                  await context.read<EventsController>().updateEventField(key: 'button_text_color', value: selectedColor);
                }
              },
              child: AppCustomCard(title: 'Couleur textes de bouton', color: Event.instance.buttonTextColor == '' ? 'ffffff' : Event.instance.buttonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
