import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/users_letters.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SaveTheDate extends StatefulWidget {
  const SaveTheDate({super.key, required this.isGuestView});

  final bool isGuestView;

  @override
  State<SaveTheDate> createState() => _SaveTheDateState();
}

class _SaveTheDateState extends State<SaveTheDate> {
  File? imageFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Event event = Event.instance;
    Module module = Event.instance.modules.firstWhere((module) => module.type == 'wedding');
    DateTime moduleDate = module.date!;
    String imageUrl = Event.instance.saveTheDateThumbnail;

    return Column(
      children: [
        const SizedBox(height: 64),
        const UserLetters(),
        const SizedBox(height: 32),
        Stack(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 92, backgroundColor: kLighterGrey),
            if (!widget.isGuestView)
              Positioned(
                top: 5,
                right: 10,
                child: Container(
                  width: 32,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.5), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))]),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    color: kBlack,
                    onPressed: () {
                      onEditButtonPressed();
                    },
                  ),
                ),
              ),
            if (isLoading) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)))),
          ],
        ),
        const SizedBox(height: 24),
        Text('Save the date', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
        const SizedBox(height: 24),
        buildDate(moduleDate, widget.isGuestView),
        const SizedBox(height: 24),
        Text(
          '${capitalize(event.manFirstName)} & ${capitalize(event.womanFirstName)}',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}'))),
        ),
        const SizedBox(height: 32),
        const Text('Ici vous posterez les photos de l\'évènement', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: kGrey, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Flex buildDate(DateTime moduleDate, bool isGuestView) {
    if (moduleDate == DateTime.parse(kDefaultDate)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text("La date n'est pas encore connue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              mediumSpacerH(context),
              if (!isGuestView)
                IcButton(
                  text: 'Modifier',
                  textColor: Event.instance.buttonTextColor == '' ? kWhite : Color(int.parse('0xFF${Event.instance.buttonTextColor}')),
                  backgroundColor: Event.instance.buttonColor == '' ? kYellow : Color(int.parse('0xFF${Event.instance.buttonColor}')),
                  width: MediaQuery.of(context).size.width * 0.5,
                  onPressed: () async {
                    // Sauvegardez la date sélectionnée par l'utilisateur dans une variable
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // La date initiale affichée dans le sélecteur
                      firstDate: DateTime(2000), // La première date disponible pour la sélection
                      lastDate: DateTime(2101), // La dernière date disponible pour la sélection
                    );

                    // Si l'utilisateur a sélectionné une date, mettez à jour la date de l'événement
                    if (pickedDate != null) {
                      if (!mounted) return;
                      await context.read<EventsController>().updateEventField(key: "date", value: pickedDate.toString());

                      setState(() {
                        Event.instance.date = pickedDate;
                      });
                    }
                  },
                ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const Divider(color: kGrey, thickness: 1, indent: 92, endIndent: 92),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(moduleDate.day.toString().padLeft(2, '0'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
              Text(' . ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
              Text(moduleDate.month.toString().padLeft(2, '0'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
              Text(' . ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
              Text(moduleDate.year.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.playfairDisplay().fontFamily, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
            ],
          ),
          const Divider(color: kGrey, thickness: 1, indent: 92, endIndent: 92),
        ],
      );
    }
  }

  void onEditButtonPressed() async {
    await _showImageDialog();
  }

  Future<void> _showImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          title: Center(child: Text('Merci de choisir une image', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize))),
          actions: <Widget>[
            TextButton(
              child: Text('Prendre une photo', style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
              onPressed: () async {
                XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
                if (pickedFile != null) {
                  setState(() {
                    Navigator.pop(dialogContext);
                    imageFile = File(pickedFile.path);
                  });
                } else {
                  return;
                }

                try {
                  setState(() {
                    isLoading = true;
                  });

                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/users_picture/${DateTime.now()}.jpg");
                  await storageRefPersonalThemes.putFile(imageFile!);
                  final url = await storageRefPersonalThemes.getDownloadURL();

                  Event.instance.saveTheDateThumbnail = url;

                  if (!mounted) return;
                  await context.read<EventsController>().updateSaveTheDateThumbnail(url: url);
                } catch (e) {
                  throw Exception(e);
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
            ),
            TextButton(
              child: Text('Voir ma gallerie', style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
              onPressed: () async {
                XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
                if (pickedFile != null) {
                  setState(() {
                    Navigator.pop(dialogContext);
                    imageFile = File(pickedFile.path);
                  });
                  try {
                    setState(() {
                      isLoading = true;
                    });

                    final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/users_picture/${DateTime.now()}.jpg");
                    await storageRefPersonalThemes.putFile(imageFile!);
                    final url = await storageRefPersonalThemes.getDownloadURL();

                    Event.instance.saveTheDateThumbnail = url;

                    if (!mounted) return;
                    await context.read<EventsController>().updateSaveTheDateThumbnail(url: url);
                  } catch (e) {
                    throw Exception(e);
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                } else {
                  return;
                }
              },
            ),
            TextButton(
              child: Text('Annuler', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}
