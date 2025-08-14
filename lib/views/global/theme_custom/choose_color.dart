import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/global/theme_custom/choosen_color.dart';
import 'package:kapstr/views/global/theme_custom/favorite_colors.dart';
import 'package:kapstr/views/global/theme_custom/predefine_colors.dart';
import 'package:provider/provider.dart';

class ChooseCustomColor extends StatefulWidget {
  const ChooseCustomColor({super.key, required this.colorStringToUpdate, required this.description, required this.type, required this.isBackgroundColor});

  final String colorStringToUpdate;
  final String description;
  final String type;
  final bool isBackgroundColor;

  @override
  State<ChooseCustomColor> createState() => _ChooseCustomColorState();
}

class _ChooseCustomColorState extends State<ChooseCustomColor> {
  late Color colorToUpdate;

  @override
  void initState() {
    super.initState();
    colorToUpdate = Color(int.parse('0xFF${widget.colorStringToUpdate}'));
  }

  void _updateColor(Color newColor) {
    setState(() {
      colorToUpdate = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MainButton(
        onPressed: () async {
          String myColor;

          // Vérifier si c'est une couleur de fond et appliquer l'opacité
          if (widget.isBackgroundColor) {
            // Appliquer une opacité de 50% uniquement pour les couleurs de fond
            int alpha = (255 * 0.35).toInt(); // 50% d'opacité
            int colorValueWithAlpha = (colorToUpdate.toARGB32() & 0x00FFFFFF) | (alpha << 24); // Remplace le canal alpha
            myColor = colorValueWithAlpha.toRadixString(16).padLeft(8, '0');
          } else {
            // Utiliser la couleur telle quelle sans changer son opacité
            myColor = colorToUpdate.toARGB32().toRadixString(16).padLeft(8, '0');
          }

          // Ajouter aux couleurs favorites si elle n'existe pas déjà
          if (!Event.instance.favoriteColors.contains(myColor)) {
            Event.instance.favoriteColors.add(myColor);
          }

          // Mettre à jour les couleurs favorites dans EventsController
          await context.read<EventsController>().updateFavoriteColors(color: myColor);

          // Retourner la couleur sélectionnée et fermer le picker
          Navigator.pop(context, myColor);
        },
        backgroundColor: getButtonColor(widget.type, colorToUpdate), //default color

        child: Text('Valider', style: TextStyle(color: getButtonTextColor(widget.type, colorToUpdate), fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      ),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        actions: const [SizedBox(width: 91)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Choisissez votre couleur', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              Text(widget.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: kBlack)),
              const SizedBox(height: 16),
              SizedBox(width: MediaQuery.of(context).size.width - 40, child: PredefineColorsGrid(colorToUpdate: colorToUpdate, onColorSelected: _updateColor)),
              const SizedBox(height: 16),
              ChoosenColorRow(choosenColor: colorToUpdate),
              const SizedBox(height: 16),

              Event.instance.favoriteColors != []
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Récentes', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 8), FavoriteColors(initialColor: colorToUpdate, onColorSelected: _updateColor)])
                  : const SizedBox(),

              const SizedBox(height: 16),

              xLargeSpacerH(context),
              kNavBarSpacer(context),
            ],
          ),
        ),
      ),
    );
  }
}

Color getButtonColor(String type, Color colorToUpdate) {
  printOnDebug('color to update $colorToUpdate');
  printOnDebug('test : ${Color(int.parse('0xFF000000'))}');

  if (type == 'buttonColor') {
    if (colorToUpdate == Color(int.parse('0xFF000000'))) {
      return Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}'));
    } else {
      return colorToUpdate;
    }
  } else {
    return Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}'));
  }
}

Color getButtonTextColor(String type, Color colorToUpdate) {
  if (type == 'buttonTextColor') {
    if (colorToUpdate == Color(int.parse('0xFF000000'))) {
      return Event.instance.buttonTextColor == '' ? kWhite : Color(int.parse('0xFF${Event.instance.buttonTextColor}'));
    } else {
      return colorToUpdate;
    }
  } else {
    return Event.instance.buttonTextColor == '' ? kWhite : Color(int.parse('0xFF${Event.instance.buttonTextColor}'));
  }
}
