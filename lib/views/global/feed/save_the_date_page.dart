import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/feed.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/theme/background_theme.dart';

class SaveTheDatePage extends StatefulWidget {
  const SaveTheDatePage({super.key, required this.module, required this.moduleDate});

  final Module module;
  final DateTime moduleDate;

  @override
  State<SaveTheDatePage> createState() => _SaveTheDatePageState();
}

class _SaveTheDatePageState extends State<SaveTheDatePage> {
  File? imageFile;
  bool isLoading = false;

  String formatDate(DateTime date) {
    // Format the date but only get the month part
    String month = DateFormat('MMMM', 'fr_FR').format(date); // 'MMMM' will give the full month name

    // Capitalize the first letter of the month
    String capitalizedMonth = month.replaceRange(0, 1, month[0].toUpperCase());

    // Now build the full date string
    String formattedDate = '${date.day.toString().padLeft(2, '0')} $capitalizedMonth ${date.year}';

    return formattedDate;
  }

  void addToCalendar() {
    // Map des messages basés sur les types d'événements
    const Map<String, String> eventMessages = {'mariage': "Mariage", 'anniversaire': "Anniversaire", 'gala': "Gala", 'entreprise': "Entreprise", 'bar mitsvah': "Bar Mitsvah", 'salon': "Salon", 'soirée': "Soirée"};

    // Récupérer le type d'événement actuel
    String eventType = Event.instance.eventType;

    // Récupérer le message correspondant ou un message par défaut
    String eventTitle = eventMessages[eventType] ?? "Evenement";

    triggerShortVibration();
    final calendar.Event event = calendar.Event(title: eventTitle, description: 'Evenement le ${formatDate(widget.moduleDate)}', location: '${widget.module.placeName} ${widget.module.placeAddress}', startDate: widget.moduleDate, endDate: widget.moduleDate.add(const Duration(hours: 8)));

    calendar.Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    Event event = Event.instance;
    String imageUrl = Event.instance.saveTheDateThumbnail;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: const SizedBox(),
        actions: [
          // close
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: Padding(padding: const EdgeInsets.only(right: 16.0), child: Icon(Icons.close, size: 24, color: context.read<ThemeController>().getTextColor()))),
        ],
      ),
      body: BackgroundTheme(
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Save the date
                  Text('Save the date', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.greatVibes().fontFamily, color: context.read<ThemeController>().getTextColor())),

                  const SizedBox(height: 12),

                  // Date
                  Text(formatDate(widget.moduleDate), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily, color: context.read<ThemeController>().getTextColor())),

                  const SizedBox(height: 32),

                  // Image
                  Stack(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 128, backgroundColor: kLighterGrey),
                      !context.watch<EventsController>().isGuestPreview && !context.watch<FeedController>().isGuestView
                          ? // If the user is not a guest
                          Positioned(
                            top: 16,
                            right: 16,
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
                          )
                          : const SizedBox.shrink(),
                      if (isLoading) Positioned.fill(child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)))),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    event.eventType == 'mariage' ? '${capitalize(event.manFirstName)} & ${capitalize(event.womanFirstName)}' : capitalize(event.manFirstName),
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily, color: context.read<ThemeController>().getTextColor()),
                  ),

                  const SizedBox(height: 32),

                  IcButton(
                    onPressed: addToCalendar,
                    radius: 8,
                    backgroundColor: Colors.transparent,
                    borderColor: context.read<ThemeController>().getTextColor(),
                    borderWidth: 1,
                    width: 250,
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.calendar_add_on, color: context.read<ThemeController>().getTextColor(), size: 24),
                        const SizedBox(width: 8),
                        Text('Ajouter à mon agenda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.read<ThemeController>().getTextColor())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
