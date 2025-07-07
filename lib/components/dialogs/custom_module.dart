import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/components/buttons/options/font.dart';
import 'package:kapstr/components/buttons/options/image.dart';
import 'package:kapstr/components/buttons/options/number.dart';
import 'package:kapstr/components/buttons/options/color.dart';
import 'package:kapstr/components/buttons/primary_button.dart';
import 'package:kapstr/components/buttons/secondary_button.dart';
import 'package:kapstr/components/dialogs/save_customization.dart';
import 'package:kapstr/controllers/customization.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/helpers/format_colors.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/widgets/organizer/modules/change_module_picture.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CustomModuleDialog extends StatefulWidget {
  const CustomModuleDialog({super.key, required this.module});

  final Module module;

  @override
  State<CustomModuleDialog> createState() => _CustomModuleDialogState();
}

class _CustomModuleDialogState extends State<CustomModuleDialog> {
  late String _selectedBackgroundColor;
  late String _selectedTextColor;
  late String _selectedFont;
  late int _selectedFontSize;
  late String _selectedImage;

  void _updateTextColor(String newColor) {
    context.read<CustomizationController>().updatedCustomization.textColor = newColor;
    setState(() {
      _selectedTextColor = newColor;
    });
  }

  void _updateBackgroundColor(String newColor) {
    context.read<CustomizationController>().updatedCustomization.backgroundColor = newColor;
    setState(() {
      _selectedBackgroundColor = newColor;
    });
  }

  void _updateFont(String newFont) {
    context.read<CustomizationController>().updatedCustomization.fontName = newFont;
    setState(() {
      _selectedFont = newFont;
    });
  }

  Future _updateFontSize(int newSize) async {
    context.read<CustomizationController>().updatedCustomization.fontSize = newSize;
    setState(() {
      _selectedFontSize = newSize;
    });
  }

  void _save() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SaveCustomizationDialog(module: widget.module);
      },
    );
  }

  void _reset() {
    showReinitAlertDialog(context);
    setState(() {
      _selectedBackgroundColor = widget.module.colorFilter;
      _selectedTextColor = widget.module.textColor;
      _selectedFont = widget.module.fontType;
      _selectedFontSize = widget.module.textSize;
      _selectedImage = widget.module.image;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedBackgroundColor = widget.module.colorFilter;
    _selectedTextColor = widget.module.textColor;
    _selectedFont = widget.module.fontType;
    _selectedFontSize = widget.module.textSize;
    _selectedImage = widget.module.image;
  }

  Future _updateImage(CroppedFile? file) async {
    if (file != null) {
      final storageRef = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/${widget.module.id}/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await storageRef.putFile(File(file.path));

      final url = await storageRef.getDownloadURL();

      widget.module.image = url;

      context.read<CustomizationController>().updatedCustomization.imageUrl = url;
      Navigator.pop(context);

      setState(() {
        _selectedImage = url;
      });
    }
  }

  Future<void> changeImage(String newFont) async {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      backgroundColor: kWhite,
      elevation: 10,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: kWhite,
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Voir ma galerie', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () async {
                  CroppedFile? file = await onChangePicture(context: context, module: widget.module, source: ImageSource.gallery);
                  await _updateImage(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Prendre une photo', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () async {
                  CroppedFile? file = await onChangePicture(context: context, module: widget.module, source: ImageSource.camera);
                  await _updateImage(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined, color: kBlack),
                title: const Text('Réinitialiser', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  showReinitAlertDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_outlined, color: kDanger),
                title: const Text('Supprimer la photo', style: TextStyle(color: kDanger, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  context.read<ModulesController>().updateImage(moduleId: widget.module.id, newImage: '');
                  setState(() {
                    widget.module.image = '';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: Stack(
        children: [
          // Contenu principal du dialog
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(color: kMediumGrey, borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(widget.module.image), fit: BoxFit.cover, colorFilter: ColorFilter.mode(fromHex(_selectedBackgroundColor), BlendMode.srcOver))),
                  child: Center(child: Text(widget.module.name, textAlign: TextAlign.center, style: TextStyle(color: fromHex(_selectedTextColor), fontFamily: GoogleFonts.getFont(_selectedFont).fontFamily, fontSize: _selectedFontSize.toDouble()))),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ColorOptionButton(title: "Fond", initialColorHex: _selectedBackgroundColor, isBackgroundColor: true, onColorSelected: _updateBackgroundColor, module: widget.module),
                    FontOptionButton(initialFont: _selectedFont, title: "Police", onFontSelected: _updateFont),
                    NumberOptionButton(title: "Taille", initialValue: _selectedFontSize, onNumberSelected: _updateFontSize),
                    ColorOptionButton(title: "Texte", initialColorHex: _selectedTextColor, isBackgroundColor: false, onColorSelected: _updateTextColor, module: widget.module),
                    ImageOptionButton(title: "Image", initialImagePath: _selectedImage, onImageSelected: changeImage),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: Row(children: [SecondaryButton(onPressed: _reset, width: 70, icon: Icons.restore), const SizedBox(width: 12), Flexible(child: PrimaryButton(onPressed: _save, text: "Sauvegarder", icon: Icons.save))])),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Croix pour fermer
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
              },
            ),
          ),
        ],
      ),
    );
  }

  Future showReinitAlertDialog(BuildContext context) async {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Oui", style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      onPressed: () async {
        await context.read<ModulesController>().clearDesign(moduleId: widget.module.id);

        if (!mounted) return;
        context.read<EventsController>().updateModules(await context.read<ModulesController>().getModules(Event.instance.id));

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()), (Route<dynamic> route) => route.isFirst);
      },
    );

    Widget cancelButton = TextButton(
      child: Text("J'annule", style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      surfaceTintColor: kWhite,
      backgroundColor: kWhite,
      title: Text("Réinitialisation du module", style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.titleMedium!.fontSize)),
      content: Text("Êtes-vous sûr ?", style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
      actions: [okButton, cancelButton],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
