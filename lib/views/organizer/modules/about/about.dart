import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/about.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/about.dart';
import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/about/update_service.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/organizer/modules/infos_textfield.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class About extends StatefulWidget {
  const About({super.key, required this.moduleId});
  final String moduleId;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool isLoading = false;
  bool isDataLoaded = false;

  late Future<AboutModule?> _aboutModuleFuture;

  TextEditingController moduleTitleController = TextEditingController();
  TextEditingController moduleDescriptionController = TextEditingController();
  TextEditingController moduleAddressController = TextEditingController();
  TextEditingController modulePhoneController = TextEditingController();
  TextEditingController moduleEmailController = TextEditingController();
  TextEditingController moduleWebsiteController = TextEditingController();

  // focus nodes
  FocusNode moduleTitleFocusNode = FocusNode();
  FocusNode moduleDescriptionFocusNode = FocusNode();
  FocusNode moduleAddressFocusNode = FocusNode();
  FocusNode modulePhoneFocusNode = FocusNode();
  FocusNode moduleEmailFocusNode = FocusNode();
  FocusNode moduleWebsiteFocusNode = FocusNode();

  Future<AboutModule?> _fetchAboutModule() async {
    try {
      return await context.read<AboutController>().getAboutById(widget.moduleId);
    } catch (e) {
      printOnDebug("Error fetching cagnotte module: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _aboutModuleFuture = _fetchAboutModule();
  }

  @override
  void dispose() {
    moduleTitleController.dispose();
    moduleDescriptionController.dispose();
    moduleAddressController.dispose();
    modulePhoneController.dispose();
    moduleEmailController.dispose();
    moduleWebsiteController.dispose();

    moduleTitleFocusNode.dispose();
    moduleDescriptionFocusNode.dispose();
    moduleAddressFocusNode.dispose();
    modulePhoneFocusNode.dispose();
    moduleEmailFocusNode.dispose();
    moduleWebsiteFocusNode.dispose();

    super.dispose();
  }

  Future<void> saveData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {'title': moduleTitleController.text, 'description': moduleDescriptionController.text, 'adress': moduleAddressController.text, 'phone': modulePhoneController.text, 'email': moduleEmailController.text, 'website': moduleWebsiteController.text};

    await context.read<AboutController>().updateAboutFields(fields: data, moduleId: widget.moduleId);

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: kWhite,
      child: FutureBuilder<AboutModule?>(
        future: _aboutModuleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            printOnDebug("About module fetched: ${snapshot.data!.services.length}");
            snapshot.data!.title == '' ? snapshot.data!.title == Event.instance.logoUrl : snapshot.data!.title;

            if (!isDataLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                moduleTitleController.text = snapshot.data!.title;
                moduleDescriptionController.text = snapshot.data!.description;
                moduleAddressController.text = snapshot.data!.adress;
                modulePhoneController.text = snapshot.data!.phone;
                moduleEmailController.text = snapshot.data!.email;
                moduleWebsiteController.text = snapshot.data!.website;

                if (!isDataLoaded) {
                  setState(() {
                    isDataLoaded = true;
                  });
                }
              });
            }

            return Scaffold(
              backgroundColor: kWhite,
              floatingActionButton:
                  MediaQuery.of(context).viewInsets.bottom == 0
                      ? MainButton(
                        onPressed: () async {
                          triggerShortVibration();

                          await saveData();
                        },
                        child: const Text('Sauvegarder', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                      )
                      : null,
              appBar: AppBar(
                backgroundColor: kWhite,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 75,
                toolbarHeight: 40,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8), // Title
                          const Text('Modifier A propos', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

                          const SizedBox(height: 8),

                          // Subtitle
                          const Text('Ajoutez vos informations et personnalisez votre module selon vos envies', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),

                          const SizedBox(height: 24),

                          // Name label
                          const Text('Textes du à propos', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                          const SizedBox(height: 8),

                          // Module name
                          CustomModuleTextField(controller: moduleTitleController, focusNode: moduleTitleFocusNode, hintText: 'Entrez le titre'),

                          const SizedBox(height: 16),

                          // Module description
                          CustomModuleTextField(controller: moduleDescriptionController, focusNode: moduleDescriptionFocusNode, hintText: 'Entrez la description', maxLines: 10),

                          const SizedBox(height: 24),

                          // logo
                          const Text('Logo', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () async {
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
                                            XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);

                                            try {
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

                                              final storageRef = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/${widget.moduleId}/${DateTime.now().millisecondsSinceEpoch}.jpg");
                                              await storageRef.putFile(File(croppedFile!.path));
                                              final url = await storageRef.getDownloadURL();

                                              snapshot.data!.logoUrl = url;

                                              if (context.mounted) {
                                                await context.read<AboutController>().updateModuleLogo(newLogo: url, moduleId: widget.moduleId);

                                                Navigator.of(context).pop();
                                              }
                                            } catch (e) {
                                              Navigator.of(context).pop();
                                              printOnDebug('Error: $e');
                                              throw Exception(e);
                                            }
                                            setState(() {});

                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt_outlined),
                                          title: const Text('Prendre une photo', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
                                          onTap: () async {
                                            XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);

                                            try {
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

                                              final storageRef = FirebaseStorage.instance.ref().child("events/${Event.instance.id}/${widget.moduleId}/${DateTime.now().millisecondsSinceEpoch}.jpg");
                                              await storageRef.putFile(File(croppedFile!.path));
                                              final url = await storageRef.getDownloadURL();

                                              snapshot.data!.logoUrl = url;

                                              if (context.mounted) {
                                                await context.read<AboutController>().updateModuleLogo(newLogo: url, moduleId: widget.moduleId);

                                                Navigator.of(context).pop();
                                              }
                                            } catch (e) {
                                              Navigator.of(context).pop();
                                              printOnDebug('Error: $e');
                                              throw Exception(e);
                                            }

                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child:
                                snapshot.data!.logoUrl != ""
                                    ? Center(
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data!.logoUrl,
                                        imageBuilder: (context, imageProvider) => CircleAvatar(backgroundColor: kWhite, radius: 48, backgroundImage: imageProvider),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CircleAvatar(radius: 48, backgroundColor: Color.fromARGB(255, 230, 230, 230), child: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 48))),
                                        errorWidget: (context, url, error) => const CircleAvatar(radius: 48, backgroundColor: Color.fromARGB(255, 230, 230, 230), child: Icon(Icons.error, color: kBlack, size: 40)),
                                      ),
                                    )
                                    : const CircleAvatar(radius: 48, backgroundColor: Color.fromARGB(255, 230, 230, 230), child: Center(child: Icon(Icons.add_a_photo, color: kBlack, size: 40))),
                          ),

                          const SizedBox(height: 12),

                          // Name label
                          Text('Vos ${getNameOfCategory()}', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                          const SizedBox(height: 8),

                          Text('Ajoutez des ${getNameOfCategory()} pour compléter votre page', style: const TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // A l'intérieur de votre méthode build, où vous avez votre FutureBuilder
                    SizedBox(
                      height: 280, // Définissez une hauteur fixe pour la liste déroulante
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        scrollDirection: Axis.horizontal,

                        shrinkWrap: true,
                        itemCount: snapshot.data!.services.length + 1, // Ajoutez 1 pour la carte spéciale
                        itemBuilder: (context, index) {
                          // Vérifier si l'index est pour la dernière "carte spéciale"
                          if (index == snapshot.data!.services.length) {
                            // La dernière carte avec le bouton +
                            return Card(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  AboutService? service = await context.read<AboutController>().createAboutService(widget.moduleId);

                                  if (service != null) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (context) => DraggableScrollableSheet(initialChildSize: 1, expand: false, builder: (_, controller) => UpdateServicePage(moduleId: widget.moduleId, service: service)),
                                    ).then(
                                      (value) => setState(() {
                                        if (value != null) {
                                          snapshot.data!.services.add(value);
                                        }
                                      }),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 175,
                                  height: 280,
                                  decoration: BoxDecoration(color: const Color.fromARGB(255, 230, 230, 230), borderRadius: BorderRadius.circular(8), border: Border.all(color: kGrey, width: 1)),
                                  alignment: Alignment.center,
                                  child: const CircleAvatar(backgroundColor: kBlack, radius: 24, child: Icon(Icons.add_rounded, size: 24, color: kWhite)),
                                ),
                              ),
                            );
                          } else {
                            // Cartes pour chaque service
                            AboutService service = snapshot.data!.services[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, builder: (context) => DraggableScrollableSheet(initialChildSize: 1, expand: false, builder: (_, controller) => UpdateServicePage(moduleId: widget.moduleId, service: service))).then(
                                    (value) => setState(() {
                                      if (value != null) {
                                        snapshot.data!.services[index] = value as AboutService;
                                      }
                                    }),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    CachedNetworkImage(imageUrl: service.imageUrl, fit: BoxFit.cover, width: 175, height: 280, colorBlendMode: BlendMode.darken, color: Colors.black.withValues(alpha: 0.5)),
                                    Positioned(
                                      left: 8,
                                      bottom: 8,
                                      child: Container(
                                        width: 159, // Match the width of the image to constrain the text within it
                                        padding: const EdgeInsets.all(8.0), // Optionally add padding inside the container
                                        child: Text(
                                          service.name,
                                          textAlign: TextAlign.left, // Center align text
                                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                                          softWrap: true, // Enable text wrapping
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Name label
                          const Text('Vos informations de contact', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),

                          CustomModuleTextField(controller: moduleAddressController, focusNode: moduleAddressFocusNode, hintText: 'Entrez votre adresse'),

                          const SizedBox(height: 16),

                          CustomModuleTextField(controller: moduleEmailController, focusNode: moduleEmailFocusNode, hintText: 'Entrez votre adresse mail'),

                          const SizedBox(height: 16),

                          CustomModuleTextField(controller: modulePhoneController, focusNode: modulePhoneFocusNode, hintText: 'Entrez votre numéro de téléphone'),

                          const SizedBox(height: 16),

                          CustomModuleTextField(controller: moduleWebsiteController, focusNode: moduleWebsiteFocusNode, hintText: 'Entrez votre site web'),

                          const SizedBox(height: 128),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Erreur inconnue'));
        },
      ),
    );
  }
}

String getNameOfCategory() {
  switch (Event.instance.eventType) {
    case 'soirée':
      return 'offres';
    case 'gala':
      return 'actions';
    default:
      return 'services';
  }
}
