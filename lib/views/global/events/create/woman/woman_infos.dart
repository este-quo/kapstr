import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/event_data.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/helpers/generate_code.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/browse_themes_onboarding.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/views/global/events/create/text_field.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:kapstr/services/firebase/authentication/auth_firebase.dart' as auth_firebase;

class WomanInfosUI extends StatefulWidget {
  const WomanInfosUI({super.key});

  @override
  GetWomanInfosState createState() => GetWomanInfosState();
}

class GetWomanInfosState extends State<WomanInfosUI> {
  File? imageFile;
  final nameFormKey = GlobalKey<FormState>();
  final _womanFirstNameFieldFocusNode = FocusNode();
  final _womanLastNameFieldFocusNode = FocusNode();
  final _manFirstNameFieldFocusNode = FocusNode();
  final _manLastNameFieldFocusNode = FocusNode();

  TextEditingController firstNameManController = TextEditingController();
  TextEditingController lastNameManController = TextEditingController();
  TextEditingController firstNameWomanController = TextEditingController();
  TextEditingController lastNameWomanController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

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
      await createNewEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = context.watch<EventDataController>();

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
                Text(getEventTitle(onboardingData.eventType), style: const TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                OnboardingTextField(
                  key: const Key('firstNameMan'),
                  focusNode: _manFirstNameFieldFocusNode,
                  suffixIcon: const SizedBox(),
                  isPassword: false,
                  keyboardType: TextInputType.text,
                  validateInput: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez renseigner ce champ pour continuer';
                    }
                    onboardingData.manFirstName = value;

                    return null;
                  },
                  title: getHintText(onboardingData.eventType),
                  controller: firstNameManController,
                  onValidatedInput: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(_manLastNameFieldFocusNode);
                  },
                ),
                if (onboardingData.eventType == EventTypes.wedding || onboardingData.eventType == EventTypes.birthday || onboardingData.eventType == EventTypes.barMitsvah)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      OnboardingTextField(
                        focusNode: _manLastNameFieldFocusNode,
                        key: const Key('lastNameMan'),
                        suffixIcon: const SizedBox(),
                        isPassword: false,
                        keyboardType: TextInputType.text,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }
                          onboardingData.manLastName = value;

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

                if (onboardingData.eventType == EventTypes.wedding)
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
                        keyboardType: TextInputType.text,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }

                          onboardingData.womanFirstName = value;

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
                        keyboardType: TextInputType.text,
                        validateInput: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez renseigner ce champ pour continuer';
                          }

                          onboardingData.womanLastName = value;

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
                if (onboardingData.eventType == EventTypes.enterprise || onboardingData.eventType == EventTypes.gala || onboardingData.eventType == EventTypes.other || onboardingData.eventType == EventTypes.salon || onboardingData.eventType == EventTypes.party)
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
                              onboardingData.logoUrl.isEmpty
                                  ? const CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: Icon(Icons.image, color: kWhite, size: 48))
                                  : Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: onboardingData.logoUrl,
                                        imageBuilder: (context, imageProvider) => CircleAvatar(radius: 92, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                                        errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                                        progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64))),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            onboardingData.logoUrl = '';
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
                  sourcePath: pickedFile.path,
                  compressFormat: ImageCompressFormat.jpg,
                  compressQuality: 100,
                  uiSettings: uiSettingsList, // Pass the list here
                );

                try {
                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/logos/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                  await storageRefPersonalThemes.putFile(File(croppedFile!.path));
                  final url = await storageRefPersonalThemes.getDownloadURL();

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
                    sourcePath: pickedFile.path,
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

  Future<void> createNewEvent() async {
    final onboardingData = context.read<EventDataController>();

    QuerySnapshot currentUser = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();
    String userId = currentUser.docs.first.id;
    DateTime currentDate = DateTime.now();

    String formattedDate = currentDate.toString();

    printOnDebug('Event type: ${Event.getStringFromEventType(onboardingData.eventType)}');

    if (onboardingData.eventType != EventTypes.wedding && onboardingData.eventType != EventTypes.birthday && onboardingData.eventType != EventTypes.barMitsvah) {
      onboardingData.womanFirstName = "";
      onboardingData.womanLastName = "";
      onboardingData.manLastName = "";
    }

    final eventMap = {
      "plan": "free_plan",
      "plan_end_at": null,
      "event_name": "",
      "man_first_name": onboardingData.manFirstName,
      "woman_first_name": onboardingData.womanFirstName,
      "man_last_name": onboardingData.manLastName,
      "woman_last_name": onboardingData.womanLastName,
      'event_type': Event.getStringFromEventType(onboardingData.eventType),
      'show_tables_early': false,
      'organiser_auth_id': [auth_firebase.getAuthId()],
      'bloc_disposition': 'grid',
      'text_color': '',
      'visibility': onboardingData.eventVisibility,
      'button_color': '',
      'button_text_color': '',
      'organizer_to_add': [],
      'organizer_added': [],
      'theme_opacity': 100.0,
      'theme_type': '',
      'theme_name': '',
      'custom_theme_urls': [],
      'event_logo_url': onboardingData.logoUrl,
      'date': formattedDate,
      'favorite_colors': [],
      'favorite_fonts': [],
      'isUnlocked': false,
      'code': getRandomString(6),
      'code_organizer': getRandomString(6),
      'save_the_date_thumbnail': kEventModuleImages[Event.getStringFromEventType(onboardingData.eventType)]!["wedding"],
      'created_at': formattedDate,
    };

    DocumentReference<Map<String, dynamic>> newEvent = await cloud_firestore.createEvent(eventMap);

    var organisersMap = {'name': '${onboardingData.manFirstName} ${onboardingData.manLastName}', 'image_url': '', 'user_id': userId, "id_auth_token": auth_firebase.getAuthId(), "event_id": newEvent.id, "phone": firebaseAuth.currentUser!.phoneNumber};

    await cloud_firestore.addOrganisers(organisersMap, newEvent.id, userId);

    Future<void> addModulesInOrder(String eventId) async {
      await generateModulesFromEventType(eventId, Event.getStringFromEventType(onboardingData.eventType), onboardingData);
    }

    await addModulesInOrder(newEvent.id);

    await context.read<UsersController>().addNewEvent(newEvent.id, context);

    await AppInitializer().initOrganiser(newEvent.id, context);

    if (!mounted) return;

    onboardingData.reset();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => const BrowseThemesOnBoarding())));
  }

  String getEventTitle(EventTypes eventType) {
    switch (eventType) {
      case EventTypes.wedding:
        return 'Vous';
      case EventTypes.birthday:
        return 'Vous';
      case EventTypes.gala:
        return 'Votre Gala';
      case EventTypes.enterprise:
        return 'Votre Entreprise';
      case EventTypes.barMitsvah:
        return 'Vous';
      case EventTypes.salon:
        return 'Votre Salon';
      default:
        return 'Nom de l\'événement';
    }
  }

  getHintText(EventTypes eventType) {
    switch (eventType) {
      case EventTypes.wedding:
        return 'Votre prénom';
      case EventTypes.birthday:
        return 'Votre prénom';
      case EventTypes.gala:
        return 'Nom du gala';
      case EventTypes.enterprise:
        return 'Nom de l\'entreprise';
      case EventTypes.barMitsvah:
        return 'Votre prénom';
      case EventTypes.salon:
        return 'Nom du salon';
      default:
        return 'Nom de l\'événement';
    }
  }
}
