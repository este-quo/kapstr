import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/controllers/events.dart';

import 'package:kapstr/helpers/debug_helper.dart';

import 'package:kapstr/helpers/event_type.dart' as event_type_helper;
import 'package:kapstr/models/app_event.dart';

import 'package:kapstr/themes/constants.dart';

import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/views/global/events/create/text_field.dart';
import 'package:kapstr/widgets/logo_loader.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateEventPage extends StatefulWidget {
  const UpdateEventPage({super.key});

  @override
  UdpateEventPageState createState() => UdpateEventPageState();
}

class UdpateEventPageState extends State<UpdateEventPage> {
  File? imageFile;
  final nameFormKey = GlobalKey<FormState>();
  final _womanFirstNameFieldFocusNode = FocusNode();
  final _womanLastNameFieldFocusNode = FocusNode();
  final _manFirstNameFieldFocusNode = FocusNode();
  final _manLastNameFieldFocusNode = FocusNode();
  event_type_helper.EventTypes currentEventType = event_type_helper.Event.getEventTypeFromString(Event.instance.eventType);

  TextEditingController firstNameManController = TextEditingController();
  TextEditingController lastNameManController = TextEditingController();
  TextEditingController firstNameWomanController = TextEditingController();
  TextEditingController lastNameWomanController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    firstNameManController.text = Event.instance.manFirstName;
    lastNameManController.text = Event.instance.manLastName;
    firstNameWomanController.text = Event.instance.womanFirstName;
    lastNameWomanController.text = Event.instance.womanLastName;
  }

  @override
  void dispose() {
    firstNameManController.dispose();
    lastNameManController.dispose();
    firstNameWomanController.dispose();
    lastNameWomanController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> confirm() async {
    if (nameFormKey.currentState!.validate()) {
      await updateEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: OnBoardingLayout(
        confirm: confirm,
        title: 'Informations',
        children: [
          const SizedBox(height: 20),
          Form(
            key: nameFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section mes événements
                Text(getEventTitle(event_type_helper.Event.getEventTypeFromString(Event.instance.eventType)), style: const TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                OnboardingTextField(
                  key: const Key('firstNameMan'),
                  focusNode: _manFirstNameFieldFocusNode,
                  suffixIcon: const SizedBox(),
                  isPassword: false,
                  keyboardType: TextInputType.name,
                  validateInput: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez renseigner ce champ pour continuer';
                    }
                    Event.instance.manFirstName = value;
                    return null;
                  },
                  title: getEventTitle(currentEventType),
                  controller: firstNameManController,
                  onValidatedInput: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(_manLastNameFieldFocusNode);
                  },
                ),
                if (currentEventType == event_type_helper.EventTypes.wedding || currentEventType == event_type_helper.EventTypes.birthday || currentEventType == event_type_helper.EventTypes.barMitsvah)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      OnboardingTextField(
                        focusNode: _manLastNameFieldFocusNode,
                        key: const Key('lastNameMan'),
                        suffixIcon: const SizedBox(),
                        isPassword: false,
                        keyboardType: TextInputType.name,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }
                          Event.instance.manLastName = value;
                          return null;
                        },
                        title: 'Votre nom de famille',
                        controller: lastNameManController,
                        onValidatedInput: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).requestFocus(_womanFirstNameFieldFocusNode);
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                if (currentEventType == event_type_helper.EventTypes.wedding)
                  // Section mes événements
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Votre partenaire', style: TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      OnboardingTextField(
                        focusNode: _womanFirstNameFieldFocusNode,
                        key: const Key('firstNameWoman'),
                        suffixIcon: const SizedBox(),
                        isPassword: false,
                        keyboardType: TextInputType.name,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }
                          Event.instance.womanFirstName = value;
                          return null;
                        },
                        title: 'Prénom de votre partenaire',
                        controller: firstNameWomanController,
                        onValidatedInput: () {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).requestFocus(_womanLastNameFieldFocusNode);
                        },
                      ),
                      const SizedBox(height: 12),
                      OnboardingTextField(
                        focusNode: _womanLastNameFieldFocusNode,
                        key: const Key('lastNameWoman'),
                        suffixIcon: const SizedBox(),
                        isPassword: false,
                        keyboardType: TextInputType.name,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }
                          Event.instance.womanLastName = value;
                          return null;
                        },
                        title: 'Nom de famille de votre partenaire',
                        controller: lastNameWomanController,
                        onValidatedInput: () {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                if (currentEventType == event_type_helper.EventTypes.enterprise ||
                    currentEventType == event_type_helper.EventTypes.gala ||
                    currentEventType == event_type_helper.EventTypes.other ||
                    currentEventType == event_type_helper.EventTypes.salon ||
                    currentEventType == event_type_helper.EventTypes.party)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      RichText(text: const TextSpan(text: 'Votre logo ', style: TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500), children: [TextSpan(text: ' (optionnel)', style: TextStyle(color: kLightGrey, fontSize: 12, fontWeight: FontWeight.w400))])),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          _showImageDialog();
                        },
                        child: Center(
                          child:
                              Event.instance.logoUrl.isEmpty
                                  ? const CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: Icon(Icons.image, color: kWhite, size: 48))
                                  : Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: Event.instance.logoUrl,
                                        imageBuilder: (context, imageProvider) => CircleAvatar(radius: 92, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                                        errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                                        progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64))),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            Event.instance.logoUrl = '';
                                          });

                                          context.read<EventDataController>().updateEventLogo("");

                                          // Update the event in the controller or perform other necessary actions
                                        },
                                        child: const Text('Supprimer le logo', style: TextStyle(color: Colors.red, fontSize: 14)),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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

                List<PlatformUiSettings> uiSettingsList = []; // Initialize the list

                if (Platform.isAndroid) {
                  uiSettingsList.add(
                    AndroidUiSettings(
                      toolbarTitle: 'Rogner',
                      toolbarColor: Colors.deepOrange,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.square, // Set to square
                      lockAspectRatio: false,
                    ),
                  );
                } else if (Platform.isIOS) {
                  uiSettingsList.add(
                    IOSUiSettings(
                      title: 'Rogner',
                      rectHeight: 480, // These settings will depend on your requirements
                      rectWidth: 480, // These settings will depend on your requirements
                      minimumAspectRatio: 1.0, // Ensures the aspect ratio is square
                    ),
                  );
                } else {
                  // For other platforms, adjust as necessary
                  uiSettingsList.add(WebUiSettings(context: context));
                }
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent,
                  barrierDismissible: false, // Prevents closing the dialog by tapping outside
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
                // Crop the image
                final croppedFile = await ImageCropper().cropImage(
                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                  sourcePath: pickedFile!.path,
                  compressFormat: ImageCompressFormat.jpg,
                  compressQuality: 100,
                  uiSettings: uiSettingsList, // Pass the list here
                );

                try {
                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/logos/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                  await storageRefPersonalThemes.putFile(File(croppedFile!.path));
                  final url = await storageRefPersonalThemes.getDownloadURL();
                  Event.instance.logoUrl = url;

                  context.read<EventDataController>().updateEventLogo(url);

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

                  List<PlatformUiSettings> uiSettingsList = []; // Initialize the list

                  if (Platform.isAndroid) {
                    uiSettingsList.add(
                      AndroidUiSettings(
                        toolbarTitle: 'Rogner',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.square, // Set to square
                        lockAspectRatio: false,
                      ),
                    );
                  } else if (Platform.isIOS) {
                    uiSettingsList.add(
                      IOSUiSettings(
                        title: 'Rogner',
                        rectHeight: 480, // These settings will depend on your requirements
                        rectWidth: 480, // These settings will depend on your requirements
                        minimumAspectRatio: 1.0, // Ensures the aspect ratio is square
                      ),
                    );
                  } else {
                    // For other platforms, adjust as necessary
                    uiSettingsList.add(WebUiSettings(context: context));
                  }
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    barrierDismissible: false, // Prevents closing the dialog by tapping outside
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
                  // Crop the image
                  final croppedFile = await ImageCropper().cropImage(
                    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                    sourcePath: pickedFile!.path,
                    compressFormat: ImageCompressFormat.jpg,
                    compressQuality: 100,
                    uiSettings: uiSettingsList, // Pass the list here
                  );

                  try {
                    final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/logos/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                    await storageRefPersonalThemes.putFile(File(croppedFile!.path));

                    final String url = await storageRefPersonalThemes.getDownloadURL();

                    printOnDebug('URL: $url');

                    if (!mounted) return;
                    Event.instance.logoUrl = url;

                    context.read<EventDataController>().updateEventLogo(url);
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

  Future<void> updateEvent() async {
    if (currentEventType != event_type_helper.EventTypes.wedding && currentEventType != event_type_helper.EventTypes.birthday && currentEventType != event_type_helper.EventTypes.barMitsvah) {
      Event.instance.womanFirstName = "";
      Event.instance.womanLastName = "";
      Event.instance.manLastName = "";
    }

    if (!mounted) return;
    setState(() {
      Event.instance.manFirstName = firstNameManController.text;
      Event.instance.manLastName = lastNameManController.text;
      Event.instance.womanLastName = lastNameWomanController.text;
      Event.instance.womanFirstName = firstNameWomanController.text;
    });
    await context.read<EventsController>().updateEventFields(fieldsToUpdate: {'man_first_name': firstNameManController.text, 'man_last_name': lastNameManController.text, 'woman_first_name': firstNameWomanController.text, 'woman_last_name': lastNameWomanController.text}, eventId: Event.instance.id);

    Navigator.pop(context);
  }

  String getEventTitle(event_type_helper.EventTypes eventType) {
    switch (eventType) {
      case event_type_helper.EventTypes.wedding:
        return 'Vous';
      case event_type_helper.EventTypes.birthday:
        return 'Vous';
      case event_type_helper.EventTypes.gala:
        return 'Votre Gala';
      case event_type_helper.EventTypes.enterprise:
        return 'Votre Entreprise';
      case event_type_helper.EventTypes.barMitsvah:
        return 'Vous';
      case event_type_helper.EventTypes.salon:
        return 'Votre Salon';
      default:
        return 'Nom de l\'événement';
    }
  }

  getHintText(event_type_helper.EventTypes eventType) {
    switch (eventType) {
      case event_type_helper.EventTypes.wedding:
        return 'Votre prénom';
      case event_type_helper.EventTypes.birthday:
        return 'Votre prénom';
      case event_type_helper.EventTypes.gala:
        return 'Nom du gala';
      case event_type_helper.EventTypes.enterprise:
        return 'Nom de l\'entreprise';
      case event_type_helper.EventTypes.barMitsvah:
        return 'Votre prénom';
      case event_type_helper.EventTypes.salon:
        return 'Nom du salon';
      default:
        return 'Nom de l\'événement';
    }
  }
}
