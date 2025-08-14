import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/create/completed.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  ProfilePicturePageState createState() => ProfilePicturePageState();
}

class ProfilePicturePageState extends State<ProfilePicturePage> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    Future<void> confirm() async {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const OnboardingComplete()), (Route<dynamic> route) => route.isFirst);
    }

    String userInitials = context.read<UsersController>().user!.name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();

    return OnBoardingLayout(
      confirm: confirm,
      title: 'Photo de profil',
      children: [
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () async {
              _showImageDialog();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                context.watch<UsersController>().user!.imageUrl == ""
                    ? CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: Center(child: Text(userInitials, style: const TextStyle(color: kWhite, fontSize: 32, fontWeight: FontWeight.w500))))
                    : CachedNetworkImage(
                      imageUrl: context.watch<UsersController>().user!.imageUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(radius: 92, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                      progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64))),
                    ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () async {
                    _showImageDialog();
                  },
                  child: const Text('Modifier ma photo', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        ),
      ],
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

                if (croppedFile != null) {
                  setState(() {
                    Navigator.pop(dialogContext);
                    imageFile = File(croppedFile.path);
                  });
                } else {
                  return;
                }

                try {
                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                  await storageRefPersonalThemes.putFile(imageFile!);
                  final url = await storageRefPersonalThemes.getDownloadURL();

                  await context.read<UsersController>().updateUserFields({'imageUrl': url});

                  if (!mounted) return;
                  Navigator.pop(context);

                  await context.read<UsersController>().saveUser();
                } catch (e) {
                  Navigator.pop(context);

                  throw Exception(e);
                }
              },
            ),
            TextButton(
              child: Text('Voir ma gallerie', style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
              onPressed: () async {
                XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);

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

                if (croppedFile != null) {
                  setState(() {
                    Navigator.pop(dialogContext);
                    imageFile = File(croppedFile.path);
                  });

                  try {
                    final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                    await storageRefPersonalThemes.putFile(imageFile!);

                    final String url = await storageRefPersonalThemes.getDownloadURL();

                    printOnDebug('URL: $url');

                    if (!mounted) return;

                    await context.read<UsersController>().updateUserFields({'imageUrl': url});

                    if (!mounted) return;
                    await context.read<UsersController>().saveUser();
                    Navigator.pop(context);
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
}
