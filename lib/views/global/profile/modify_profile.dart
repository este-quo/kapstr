import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/organizers.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:kapstr/widgets/text_input.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';

class ModifyProfile extends StatefulWidget {
  const ModifyProfile({super.key});

  @override
  State<ModifyProfile> createState() => _ModifyProfileState();
}

class _ModifyProfileState extends State<ModifyProfile> {
  File? imageFile;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;

  @override
  void initState() {
    super.initState();
    initTextControllers();
  }

  void initTextControllers() {
    name = TextEditingController(text: context.read<UsersController>().user!.name);
    email = TextEditingController(text: context.read<UsersController>().user!.email);
    phone = TextEditingController(text: context.read<UsersController>().user!.phone);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userInitials = context.read<UsersController>().user!.name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();
    return Scaffold(
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
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: true,
      floatingActionButton:
          MediaQuery.of(context).viewInsets.bottom == 0
              ? MainButton(
                onPressed: () async {
                  if (isLoading) {
                    return;
                  }
                  await handleConfirmation(context);
                },
                child: isLoading ? const SizedBox(height: 20, width: 20, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 20)) : const Text('Enregistrer', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),

                // Title
                const Text('Modifer mon profil', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)),

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
                              progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 92, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64))),
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
                const SizedBox(height: 16),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Votre nom', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      // Nom
                      ProfileTextInput(controller: name, hintText: "Votre nom", inputLabel: 'Votre nom'),

                      const SizedBox(height: 24),

                      // Email label

                      // const Text('Votre email', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      // // Email

                      // ProfileTextInput(
                      //   controller: email,
                      //   hintText: "Votre email",
                      //   inputLabel: 'Votre email',
                      //   enabled: false,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Veuillez entrer un email valide';
                      //     } else if (!value.contains('@')) {
                      //       return 'Veuillez entrer un email valide';
                      //     }
                      //     return null;
                      //   },
                      // ),

                      // const SizedBox(height: 24),

                      // Phone label
                      const Text('Votre téléphone', style: TextStyle(fontSize: 18, color: kBlack, fontWeight: FontWeight.w500)),

                      // Phone
                      ProfileTextInput(controller: phone, enabled: false, hintText: "Votre téléphone", inputLabel: 'Votre téléphone'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: InkWell(
                    onTap: () async {
                      bool? shouldDisconnect = await _showDisconnectDialog(context);

                      if (shouldDisconnect == true) {
                        context.read<AuthenticationController>().logout(context);
                        context.read<UsersController>().user = null;

                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EntryPoint()), (route) => false);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [Text('Me déconnecter', style: TextStyle(color: kDanger, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w400)), const SizedBox(width: 8), const Icon(Icons.logout, color: kDanger, size: 20)],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Divider(color: Colors.black.withOpacity(0.1), thickness: 1),
                const SizedBox(height: 4),

                Center(
                  child: InkWell(
                    onTap: () async {
                      bool? shouldDelete = await _showDeletionDialog(context);

                      if (shouldDelete == true) {
                        await context.read<UsersController>().deleteUser(context.read<UsersController>().user!.id, context);
                        context.read<UsersController>().user = null;

                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const EntryPoint()), (route) => false);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [Text('Suppprimer mon compte', style: TextStyle(color: kDanger, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w400)), const SizedBox(width: 8), const Icon(Icons.delete_forever, color: kDanger, size: 20)],
                    ),
                  ),
                ),
                const SizedBox(height: 92),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDisconnectDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: kBlack)),
              onPressed: () {
                Navigator.of(context).pop(false); // Returns false to the Future
              },
            ),
            TextButton(
              child: const Text('Déconnexion', style: TextStyle(color: kDanger)),
              onPressed: () {
                Navigator.of(context).pop(true); // Returns true to the Future
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeletionDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrer "Je confirme" pour supprimer votre compte. Cette action est irréversible.'),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                style: const TextStyle(color: kDanger),
                decoration: const InputDecoration(
                  hintText: "Je confirme",
                  hintStyle: TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
                  fillColor: kWhite,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  labelStyle: TextStyle(color: kLighterGrey, fontSize: 14, fontWeight: FontWeight.w400),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: kBlack)),
              onPressed: () {
                Navigator.of(context).pop(false); // Returns false to the Future
              },
            ),
            TextButton(
              child: const Text('Supprimer', style: TextStyle(color: kDanger)),
              onPressed: () {
                if (_controller.text == 'Je confirme') {
                  Navigator.of(context).pop(true); // Returns true to the Future
                } else {
                  // Show an error or handle invalid input
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez taper "Je confirme" pour continuer.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> handleConfirmation(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    await context.read<UsersController>().updateUserFields({'name': name.text, 'email': email.text, 'phone': phone.text});

    await context.read<UsersController>().saveUser();

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  Future<void> _showImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          surfaceTintColor: kWhite,
          backgroundColor: kWhite,
          title: Center(child: Text('Merci de choisir une image', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize))),
          actions: <Widget>[
            _buildImageOptionButton(dialogContext, 'Prendre une photo', ImageSource.camera),
            _buildImageOptionButton(dialogContext, 'Voir ma gallerie', ImageSource.gallery),
            TextButton(child: Text('Annuler', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)), onPressed: () => Navigator.pop(dialogContext)),
          ],
        );
      },
    );
  }

  Widget _buildImageOptionButton(BuildContext dialogContext, String buttonText, ImageSource source) {
    return TextButton(child: Text(buttonText, style: TextStyle(color: kYellow, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)), onPressed: () => _handleImageSelection(source, dialogContext));
  }

  Future<void> _handleImageSelection(ImageSource source, BuildContext dialogContext) async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: source, maxWidth: 1800, maxHeight: 1800);
      if (pickedFile != null) {
        await _processPickedImage(pickedFile, dialogContext);
      } else {
        Navigator.pop(context); // Close the dialog if no file was picked
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error picking image: $e"); // Handle the error more gracefully
    }
  }

  Future<void> _processPickedImage(XFile pickedFile, BuildContext dialogContext) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const Dialog(
          insetPadding: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color.fromARGB(15, 0, 0, 0), // Semi-transparent background
          child: Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64)),
        );
      },
    );

    final croppedFile = await _cropImage(pickedFile);
    Navigator.pop(context); // Dismiss the progress indicator

    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path); // Assuming imageFile is a File type state variable
      });
      await _uploadImage(croppedFile, dialogContext);
    } else {
      Navigator.pop(dialogContext); // Close the dialog if cropping failed or was canceled
    }
  }

  Future<File?> _cropImage(XFile file) async {
    List<PlatformUiSettings> uiSettingsList = [];

    if (Platform.isAndroid) {
      uiSettingsList.add(AndroidUiSettings(toolbarTitle: 'Ajuster votre image', toolbarColor: Colors.blueAccent, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false));
    } else if (Platform.isIOS) {
      uiSettingsList.add(IOSUiSettings(title: 'Ajuster votre image', rectWidth: 480, rectHeight: 480, minimumAspectRatio: 1.0));
    }

    final croppedFile = await ImageCropper().cropImage(sourcePath: file.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 90);

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _uploadImage(File image, BuildContext dialogContext) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child("users_picture/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      await context.read<UsersController>().updateUserFields({'imageUrl': downloadUrl});

      await context.read<UsersController>().saveUser();

      print('Image uploaded. URL: $downloadUrl');

      if (!mounted) return;
      Navigator.pop(dialogContext); // Close the dialog after successful upload
    } catch (e) {
      print('Error uploading image: $e');
      Navigator.pop(dialogContext); // Ensure dialog is closed even on error
    }
  }
}
