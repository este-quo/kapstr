import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/event_type.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/views/global/events/create/text_field.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/organizer/home/configuration.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/helpers/event_type.dart' as event_type_helper;

class EventCard extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;
  final String eventCode;
  final String eventDate;
  final Function callBack;

  const EventCard({super.key, required this.eventId, required this.eventData, required this.eventCode, required this.eventDate, required this.callBack});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String eventName = widget.eventData["event_name"];
    String eventType = widget.eventData["event_type"];
    String manFirstName = widget.eventData["man_first_name"];
    String womanFirstName = widget.eventData["woman_first_name"];

    String displayName;

    if (eventName != '') {
      displayName = eventName;
    } else {
      if (eventType == 'mariage') {
        displayName = '$manFirstName & $womanFirstName';
      } else {
        displayName = '$manFirstName';
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(boxShadow: [kBoxShadow], color: kWhite, borderRadius: BorderRadius.circular(8), border: context.read<UsersController>().lastEventId == widget.eventId ? Border.all(color: kPrimary, width: 1) : null),
      child: InkWell(
        onTap: () async {
          triggerShortVibration();
          showLoadingDialog(context); // Assuming this shows a loading indicator to the user

          try {
            // Attempt to initialize the organizer

            bool isSuccess = await AppInitializer().initOrganiser(widget.eventId, context);

            // Dismiss the loading dialog
            Navigator.pop(context);

            // Proceed only if the initialization was successful
            if (isSuccess) {
              context.read<UsersController>().updateLastEventId(widget.eventId);
              // Navigate to the OrgaHomepageConfiguration
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrgaHomepageConfiguration()));

              // Callback function to execute after returning from OrgaHomepageConfiguration
              widget.callBack();
            } else {
              // Handle the case where initialization was not successful, if needed
              // For example, show an error dialog or message to the user
            }
          } catch (error) {
            // Error handling: Dismiss the loading dialog and possibly inform the user
            Navigator.pop(context);
            // Consider showing an error dialog or a toast message here to inform the user
            print('Error initializing organizer: $error');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 104, height: 140, decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)), image: DecorationImage(image: NetworkImage(widget.eventData["save_the_date_thumbnail"]), fit: BoxFit.cover))),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capitalizeNames(widget.eventData["event_type"]), style: const TextStyle(textBaseline: TextBaseline.alphabetic, color: kLightGrey, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        Flex(direction: Axis.horizontal, children: [Flexible(child: Text(displayName, style: const TextStyle(textBaseline: TextBaseline.alphabetic, color: kBlack, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start))]),
                      ],
                    ),
                    Text(widget.eventDate, style: const TextStyle(textBaseline: TextBaseline.alphabetic, color: kBlack, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                PopupMenuButton(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  padding: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  shadowColor: kBlack.withOpacity(0.2),
                  icon: const Icon(Icons.more_vert, color: kBlack),
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Renommer', textAlign: TextAlign.right, style: TextStyle(color: kBlack, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400)), Icon(Icons.edit, color: kBlack)]),
                        ),
                        const PopupMenuItem(
                          value: 'edit_picture',
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Modifier l\'image', textAlign: TextAlign.right, style: TextStyle(color: kBlack, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400)), Icon(Icons.image, color: kBlack)]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Supprimer', textAlign: TextAlign.right, style: TextStyle(color: kDanger, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400)), Icon(Icons.delete_outline_rounded, color: kDanger)]),
                        ),
                      ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'rename':
                        await _showRenameDialog(context, widget.eventId);
                        break;
                      case 'delete':
                        bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: kWhite,
                              surfaceTintColor: kWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              title: const Text('Confirmation', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w600)),
                              content: const Text('Êtes-vous sûr de vouloir supprimer cet événement ? Cette action est irréversible.', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
                              actions: <Widget>[
                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler', style: TextStyle(color: kBlack, fontWeight: FontWeight.w400, fontSize: 14))),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Supprimer', style: TextStyle(color: kDanger, fontWeight: FontWeight.w400, fontSize: 14)),
                                ),
                              ],
                            );
                          },
                        );

                        // Check the value of confirmDelete and act accordingly.
                        if (confirmDelete == true) {
                          await context.read<EventsController>().deleteEvent(widget.eventId, context);

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Événement supprimé', style: TextStyle(color: kWhite, fontWeight: FontWeight.w400, fontSize: 14)), backgroundColor: kSuccess));

                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyEvents()));
                        }
                        break;
                      case 'edit_picture':
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
                                    leading: const Icon(Icons.camera_alt_outlined),
                                    title: const Text('Prendre une photo', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                                    onTap: () async {
                                      XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
                                      if (pickedFile != null) {
                                        setState(() {
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
                                        showCustomLoadingDialog(context);

                                        setState(() {
                                          isLoading = true;
                                        });

                                        final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("events/${widget.eventId}/users_picture/${DateTime.now()}.jpg");
                                        await storageRefPersonalThemes.putFile(File(croppedFile!.path));
                                        final url = await storageRefPersonalThemes.getDownloadURL();

                                        if (!mounted) return;
                                        await context.read<EventsController>().updateSaveTheDateThumbnailFromId(url: url, eventId: widget.eventId);
                                      } catch (e) {
                                        throw Exception(e);
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            Navigator.of(context).pop();
                                            isLoading = false;
                                            Navigator.pop(bc);

                                            widget.callBack();
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library_outlined),
                                    title: const Text('Voir ma galerie', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                                    onTap: () async {
                                      XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
                                      if (pickedFile != null) {
                                        setState(() {
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
                                              child: Container(decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(8))), height: 64, width: 64, child: const PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)),
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
                                          showCustomLoadingDialog(context);
                                          setState(() {
                                            isLoading = true;
                                          });

                                          final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("events/${widget.eventId}/users_picture/${DateTime.now()}.jpg");
                                          await storageRefPersonalThemes.putFile(File(croppedFile!.path));

                                          final url = await storageRefPersonalThemes.getDownloadURL();

                                          if (!mounted) return;
                                          await context.read<EventsController>().updateSaveTheDateThumbnailFromId(url: url, eventId: widget.eventId);
                                        } catch (e) {
                                          throw Exception(e);
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              Navigator.of(context).pop();
                                              isLoading = false;
                                              Navigator.pop(bc);

                                              widget.callBack();
                                            });
                                          }
                                        }
                                      } else {
                                        return;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, String eventId) async {
    TextEditingController firstNameManController = TextEditingController(text: widget.eventData["man_first_name"]);
    TextEditingController lastNameManController = TextEditingController(text: widget.eventData["man_last_name"]);
    TextEditingController firstNameWomanController = TextEditingController(text: widget.eventData["woman_first_name"]);
    TextEditingController lastNameWomanController = TextEditingController(text: widget.eventData["woman_last_name"]);
    final _womanFirstNameFieldFocusNode = FocusNode();
    final _womanLastNameFieldFocusNode = FocusNode();
    final _manFirstNameFieldFocusNode = FocusNode();
    final _manLastNameFieldFocusNode = FocusNode();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    event_type_helper.EventTypes currentEventType = event_type_helper.Event.getEventTypeFromString(widget.eventData["event_type"]);

    Future<void> updateEvent() async {
      if (currentEventType != event_type_helper.EventTypes.wedding && currentEventType != event_type_helper.EventTypes.birthday && currentEventType != event_type_helper.EventTypes.barMitsvah) {
        widget.eventData["woman_first_name"] = "";
        widget.eventData["woman_last_name"] = "";
        widget.eventData["man_last_name"] = "";
      }

      if (!mounted) return;
      setState(() {
        widget.eventData["man_first_name"] = firstNameManController.text;
        widget.eventData["man_last_name"] = lastNameManController.text;
        widget.eventData["woman_last_name"] = lastNameWomanController.text;
        widget.eventData["woman_first_name"] = firstNameWomanController.text;
      });
      await context.read<EventsController>().updateEventFields(fieldsToUpdate: {'man_first_name': firstNameManController.text, 'man_last_name': lastNameManController.text, 'woman_first_name': firstNameWomanController.text, 'woman_last_name': lastNameWomanController.text}, eventId: eventId);

      Navigator.pop(context);
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Modifier les informations de l\'événement', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingTextField(
                    focusNode: _manFirstNameFieldFocusNode,
                    key: const Key('firstNameMan'),
                    suffixIcon: const SizedBox(),
                    isPassword: false,
                    keyboardType: TextInputType.name,
                    controller: firstNameManController,
                    validateInput: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez renseigner ce champ pour continuer';
                      }
                      return null;
                    },
                    title: getEventTitle(currentEventType),
                    onValidatedInput: () {
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(_manFirstNameFieldFocusNode);
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
                          controller: lastNameManController,
                          validateInput: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez renseigner ce champ pour continuer';
                            }
                            return null;
                          },
                          title: 'Votre nom de famille',
                          onValidatedInput: () {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context).requestFocus(_manLastNameFieldFocusNode);
                          },
                        ),
                        if (currentEventType == event_type_helper.EventTypes.wedding)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              const Text('Votre partenaire', style: TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              OnboardingTextField(
                                focusNode: _womanFirstNameFieldFocusNode,
                                key: const Key('firstNameWoman'),
                                suffixIcon: const SizedBox(),
                                isPassword: false,
                                keyboardType: TextInputType.name,
                                controller: firstNameWomanController,
                                validateInput: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez renseigner ce champ pour continuer';
                                  }
                                  return null;
                                },
                                title: 'Prénom de votre partenaire',
                                onValidatedInput: () {
                                  FocusScope.of(context).unfocus();
                                  FocusScope.of(context).requestFocus(_womanFirstNameFieldFocusNode);
                                },
                              ),
                              const SizedBox(height: 12),
                              OnboardingTextField(
                                focusNode: _womanLastNameFieldFocusNode,
                                key: const Key('lastNameWoman'),
                                suffixIcon: const SizedBox(),
                                isPassword: false,
                                keyboardType: TextInputType.name,
                                controller: lastNameWomanController,
                                validateInput: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez renseigner ce champ pour continuer';
                                  }
                                  return null;
                                },
                                title: 'Nom de famille de votre partenaire',
                                onValidatedInput: () {
                                  FocusScope.of(context).unfocus();
                                  FocusScope.of(context).requestFocus(_womanLastNameFieldFocusNode);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (currentEventType == event_type_helper.EventTypes.enterprise ||
                      currentEventType == event_type_helper.EventTypes.gala ||
                      currentEventType == event_type_helper.EventTypes.other ||
                      currentEventType == event_type_helper.EventTypes.salon ||
                      currentEventType == event_type_helper.EventTypes.party)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(text: const TextSpan(text: 'Votre logo ', style: TextStyle(color: kBlack, fontSize: 18, fontFamily: "Inter", fontWeight: FontWeight.w500), children: [TextSpan(text: ' (optionnel)', style: TextStyle(color: kLightGrey, fontSize: 12, fontWeight: FontWeight.w400))])),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await updateEvent();
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(1), // Fond presque blanc
      builder: (BuildContext context) {
        return PopScope(onPopInvoked: (value) async => false, child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64)));
      },
    );
  }
}

void showCustomLoadingDialog(BuildContext context) {
  showDialog(
    barrierColor: Colors.transparent,
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.transparent,
        shadowColor: null,
        elevation: 0,
        child: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)), child: const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 60))),
      );
    },
  );
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
