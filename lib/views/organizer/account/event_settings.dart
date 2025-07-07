// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/organizers.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/rate_app.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/views/global/in_app_purchase/purchase.dart';
import 'package:kapstr/views/global/profile/modify_profile.dart';
import 'package:kapstr/views/organizer/account/event_acessibility.dart';
import 'package:kapstr/views/organizer/account/feature.dart';
import 'package:kapstr/views/organizer/account/feature_sections.dart';
import 'package:kapstr/views/organizer/account/manage_organizers.dart';
import 'package:kapstr/views/organizer/account/udpate_event.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EventSettingsPage extends StatefulWidget {
  const EventSettingsPage({super.key});

  @override
  EventSettingsPageState createState() => EventSettingsPageState();
}

class EventSettingsPageState extends State<EventSettingsPage> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    String getInitials(String name) {
      return name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        centerTitle: false,
        leadingWidth: 75,
        toolbarHeight: 40,
      ),
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(color: Colors.transparent, width: double.infinity, child: const Padding(padding: EdgeInsets.only(right: 20, left: 20, bottom: 12), child: Text('Mon événement', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)))),
              const SizedBox(height: 12),
              FeaturesSection(
                children: [
                  // Account Features
                  AccountFeature(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventPage())).then((value) {
                        setState(() {});
                      });
                    },
                    title: const Text('Modifier les informations', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                    icon: const Icon(Icons.edit_outlined, color: kBlack, size: 20),
                  ),

                  // Account Feature
                ],
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          surfaceTintColor: kWhite,
          backgroundColor: kWhite,
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

                List<PlatformUiSettings> uiSettingsList = [];

                if (Platform.isAndroid) {
                  uiSettingsList.add(AndroidUiSettings(toolbarTitle: 'Rogner', toolbarColor: Colors.deepOrange, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: false));
                } else if (Platform.isIOS) {
                  uiSettingsList.add(IOSUiSettings(title: 'Rogner', rectHeight: 480, rectWidth: 480, minimumAspectRatio: 1.0));
                } else {
                  uiSettingsList.add(WebUiSettings(context: context));
                }

                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(0),
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Container(decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(8))), height: 64, width: 64, child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))),
                    );
                  },
                );

                final croppedFile = await ImageCropper().cropImage(aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: uiSettingsList);

                try {
                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/logos/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                  await storageRefPersonalThemes.putFile(File(croppedFile!.path));
                  final url = await storageRefPersonalThemes.getDownloadURL();

                  context.read<EventsController>().updateEventLogo(Event.instance.id, url);
                  Event.instance.logoUrl = url;
                  setState(() {});

                  if (!mounted) return;
                } catch (e) {
                  throw Exception(e);
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

                  List<PlatformUiSettings> uiSettingsList = [];

                  if (Platform.isAndroid) {
                    uiSettingsList.add(AndroidUiSettings(toolbarTitle: 'Rogner', toolbarColor: Colors.deepOrange, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: false));
                  } else if (Platform.isIOS) {
                    uiSettingsList.add(IOSUiSettings(title: 'Rogner', rectHeight: 480, rectWidth: 480, minimumAspectRatio: 1.0));
                  } else {
                    uiSettingsList.add(WebUiSettings(context: context));
                  }

                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.all(0),
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Container(decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(8))), height: 64, width: 64, child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))),
                      );
                    },
                  );

                  final croppedFile = await ImageCropper().cropImage(aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: uiSettingsList);

                  try {
                    final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/logos/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                    await storageRefPersonalThemes.putFile(File(croppedFile!.path));
                    final String url = await storageRefPersonalThemes.getDownloadURL();

                    printOnDebug('URL: $url');

                    if (!mounted) return;

                    context.read<EventsController>().updateEventLogo(Event.instance.id, url);
                    Event.instance.logoUrl = url;
                    setState(() {});

                    Navigator.pop(context);
                    if (!mounted) return;
                  } catch (e) {
                    Navigator.pop(context);
                    throw Exception(e);
                  }
                } else {
                  return;
                }
              },
            ),
            TextButton(
              child: Text('Supprimer le logo', style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
              onPressed: () async {
                try {
                  context.read<EventsController>().updateEventLogo(Event.instance.id, '');
                  Event.instance.logoUrl = '';
                  setState(() {});
                  Navigator.pop(dialogContext);
                } catch (e) {
                  Navigator.pop(dialogContext);
                  throw Exception(e);
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
