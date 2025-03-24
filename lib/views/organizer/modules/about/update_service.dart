import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/about.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/organizer/modules/infos_textfield.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateServicePage extends StatefulWidget {
  const UpdateServicePage({super.key, required this.service, required this.moduleId});

  final AboutService service;
  final String moduleId;

  @override
  _UpdateServicePageState createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateServicePage> {
  late final TextEditingController _serviceNameController = TextEditingController();
  late final TextEditingController _serviceDescriptionController = TextEditingController();

  final FocusNode _serviceNameFocusNode = FocusNode();
  final FocusNode _serviceDescriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _serviceNameController.text = widget.service.name;
    _serviceDescriptionController.text = widget.service.description;
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _serviceNameFocusNode.dispose();
    _serviceDescriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateService() async {
    await context.read<AboutController>().updateAboutServiceFields(fields: {'name': _serviceNameController.text, 'description': _serviceDescriptionController.text}, serviceId: widget.service.id, moduleId: widget.moduleId);

    widget.service.name = _serviceNameController.text;
    widget.service.description = _serviceDescriptionController.text;

    Navigator.of(context).pop(widget.service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0 ? MainButton(onPressed: _updateService, child: const Text('Enregistrer', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500))) : null,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75,
        toolbarHeight: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(widget.service), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Title
            Text(capitalize(getNameOfCategory()), textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

            const SizedBox(height: 8),

            // Subtitle
            const Text('Ajoutez vos informations et personnalisez votre module selon vos envies', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),

            const SizedBox(height: 24),

            Text('Nom ${getNameOfCategoryWithPrefix()}', style: const TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

            const SizedBox(height: 8),

            CustomModuleTextField(controller: _serviceNameController, focusNode: _serviceNameFocusNode, hintText: 'Nom ${getNameOfCategoryWithPrefix()}'),

            const SizedBox(height: 24),

            // Image label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Image ${getNameOfCategoryWithPrefix()}', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
                PopupMenuButton(
                  elevation: 10,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  shadowColor: kBlack.withValues(alpha: 0.2),
                  onSelected: (String value) async {
                    switch (value) {
                      case 'gallery':
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

                          widget.service.imageUrl = url;

                          if (context.mounted) {
                            await context.read<AboutController>().updateAboutServiceImage(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          printOnDebug('Error: $e');
                          throw Exception(e);
                        }
                        setState(() {});
                        break;
                      case 'camera':
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

                          widget.service.imageUrl = url;

                          if (context.mounted) {
                            await context.read<AboutController>().updateAboutServiceImage(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          printOnDebug('Error: $e');
                          throw Exception(e);
                        }
                        setState(() {});

                        break;

                      default:
                        // Pas d'action nécessaire pour annuler
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(value: 'gallery', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Voir ma galerie', style: TextStyle(color: kBlack)), Icon(Icons.photo_library_outlined, color: kBlack, size: 20)])),
                      PopupMenuItem(
                        height: 1,
                        value: 'divider',
                        child: Container(
                          height: 1,
                          color: kBlack.withValues(alpha: 0.1), // Couleur du Divider
                        ),
                      ),
                      const PopupMenuItem(value: 'camera', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Prendre une photo', style: TextStyle(color: kBlack)), Icon(Icons.camera_alt_outlined, color: kBlack, size: 20)])),
                    ];
                  },
                  child: const Text('Modifier', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
                ),
              ],
            ),

            const SizedBox(height: 12),

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

                                widget.service.imageUrl = url;

                                if (context.mounted) {
                                  await context.read<AboutController>().updateAboutServiceImage(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

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

                                widget.service.imageUrl = url;

                                if (context.mounted) {
                                  await context.read<AboutController>().updateAboutServiceImage(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 250,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kGrey),
                  child: CachedNetworkImage(imageUrl: widget.service.imageUrl, fit: BoxFit.cover, placeholder: (context, url) => Container(color: kWhite), errorWidget: (context, url, error) => Container(color: kWhite)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Description ${getNameOfCategoryWithPrefix()}', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            CustomModuleTextField(controller: _serviceDescriptionController, focusNode: _serviceDescriptionFocusNode, hintText: 'Description ${getNameOfCategoryWithPrefix()}', maxLines: 10),

            const SizedBox(height: 16),

            const Text('Vos images', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),

            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.service.imageUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.service.imageUrls.length) {
                    return GestureDetector(
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

                                        widget.service.imageUrls.add(url);

                                        if (context.mounted) {
                                          await context.read<AboutController>().updateAboutServiceImagesList(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

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

                                        widget.service.imageUrls.add(url);

                                        if (context.mounted) {
                                          await context.read<AboutController>().updateAboutServiceImagesList(newImage: url, serviceId: widget.service.id, moduleId: widget.moduleId);

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
                      child: Container(
                        width: 175,
                        height: 280,
                        decoration: BoxDecoration(color: const Color.fromARGB(255, 230, 230, 230), borderRadius: BorderRadius.circular(8), border: Border.all(color: kGrey, width: 1)),
                        alignment: Alignment.center,
                        child: const CircleAvatar(backgroundColor: kBlack, radius: 24, child: Icon(Icons.add_rounded, size: 24, color: kWhite)),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () async {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 175,
                      height: 280,
                      decoration: BoxDecoration(color: kGrey, borderRadius: BorderRadius.circular(8)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: widget.service.imageUrls[index], fit: BoxFit.cover, placeholder: (context, url) => Container(color: kWhite), errorWidget: (context, url, error) => Container(color: kWhite))),
                    ),
                  );
                },
              ),
            ),

            Center(
              child: TextButton(
                onPressed: (() async {
                  await deleteModuleDialog(context, widget.service.id, widget.moduleId);
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Supprimer ${getNameOfCategory()}', style: const TextStyle(color: kDanger, fontSize: 14, fontWeight: FontWeight.w500)), SizedBox(width: 8), Icon(Icons.delete_outline_outlined, color: kDanger, size: 18)],
                ),
              ),
            ),

            const SizedBox(height: 92),
          ],
        ),
      ),
    );
  }
}

Future<void> deleteModuleDialog(BuildContext context, String serviceId, moduleId) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        titlePadding: EdgeInsets.zero,
        surfaceTintColor: kWhite,
        backgroundColor: kWhite,
        title: const SizedBox(),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce module ?', style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 16)),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: kBlack)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Supprimer', style: TextStyle(color: kDanger)),
            onPressed: () async {
              await context
                  .read<AboutController>()
                  .deleteAboutService(serviceId, moduleId)
                  .then((value) {
                    SnackBar(content: Text('${getNameOfCategory()} supprimé'));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  })
                  .onError((error, stackTrace) {
                    SnackBar(content: Text('Erreur lors de la suppression du ${getNameOfCategory()}'), backgroundColor: kDanger);
                  });
            },
          ),
        ],
      );
    },
  );
}

String getNameOfCategory() {
  switch (Event.instance.eventType) {
    case 'soirée':
      return 'offre';
    case 'gala':
      return 'action';
    default:
      return 'service';
  }
}

String getNameOfCategoryWithPrefix() {
  switch (Event.instance.eventType) {
    case 'soirée':
      return 'de l\'offre';
    case 'gala':
      return 'de l\'action';
    default:
      return 'du service';
  }
}
