import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<CroppedFile?> onChangePicture({required BuildContext context, required Module module, required ImageSource source}) async {
  XFile? pickedFile = await ImagePicker().pickImage(source: source, maxWidth: 1800, maxHeight: 1800);

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
      uiSettingsList.add(WebUiSettings(context: context, presentStyle: WebPresentStyle.dialog));
    }
    // ignore: use_build_context_synchronously

    // Crop the image
    final croppedFile = await ImageCropper().cropImage(aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), sourcePath: pickedFile!.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: uiSettingsList);

    return croppedFile;
  } catch (e) {
    return null;
  }
}
