// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:kapstr/components/credits_card.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/in-app.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/rate_app.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/views/global/profile/modify_profile.dart';
import 'package:kapstr/views/organizer/account/event_settings.dart';
import 'package:kapstr/views/organizer/account/feature.dart';
import 'package:kapstr/views/organizer/account/feature_sections.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/views/organizer/account/manage_organizers.dart';
import 'package:kapstr/views/organizer/account/udpate_event.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  UserAccountPageState createState() => UserAccountPageState();
}

class UserAccountPageState extends State<UserAccountPage> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    String getInitials(String name) {
      return name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join().toUpperCase();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(backgroundColor: kWhite, surfaceTintColor: kWhite, leading: const SizedBox(), leadingWidth: 0, centerTitle: false, toolbarHeight: 70, title: const Text('Mon profil', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600))),
        backgroundColor: kWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                FeaturesSection(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        context.watch<UsersController>().user!.imageUrl == ""
                            ? GestureDetector(
                              onTap: () {
                                _showImageDialog();
                              },
                              child: const CircleAvatar(radius: 32, backgroundColor: kLightGrey, child: Icon(Icons.person, color: kWhite, size: 24)),
                            )
                            : GestureDetector(
                              onTap: () {
                                _showImageDialog();
                              },
                              child: CachedNetworkImage(
                                imageUrl: context.watch<UsersController>().user!.imageUrl,
                                imageBuilder: (context, imageProvider) => CircleAvatar(radius: 32, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                                progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircleAvatar(radius: 32, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32))),
                              ),
                            ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(capitalizeNames(context.watch<UsersController>().user!.name), style: const TextStyle(fontSize: 20, color: kBlack, fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                Event.instance.isUnlocked ? Text("Code évènement: ${Event.instance.code}", style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400)) : SizedBox(),
                                Event.instance.isUnlocked
                                    ? IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: Event.instance.code));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Code copié dans le presse-papier', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
                                      },
                                      icon: const Icon(Icons.copy, color: kBlack, size: 18),
                                    )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    CreditDisplay(credits: context.watch<UsersController>().user!.credits),

                    const SizedBox(height: 32),

                    // Account Features
                    AccountFeature(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ModifyProfile())).then((value) => setState(() {}));
                      },
                      title: const Text('Modifier mon profil', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.person_outline_outlined, color: kBlack, size: 20),
                    ),

                    AccountFeature(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventPage())).then((value) {
                          setState(() {});
                        });
                      },
                      title: const Text('Modifier mes informations ', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.draw_outlined, color: kBlack, size: 20),
                    ),

                    AccountFeature(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ManageOrganizers(isOnboarding: false))).then((value) {
                          setState(() {});
                        });
                      },
                      title: const Text('Gérer mes organisateurs', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.person_3, color: kBlack, size: 20),
                    ),

                    AccountFeature(
                      onTap: () {
                        shareApp();
                      },
                      title: const Text('Partager l\'application', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.share_outlined, color: kBlack, size: 20),
                    ),
                    AccountFeature(
                      onTap: () {
                        rateApp();
                      },
                      title: const Text('Noter l\'application', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.star_border_outlined, color: kBlack, size: 20),
                    ),
                    AccountFeature(
                      onTap: () async {
                        final Email email = Email(body: 'Bonjour, je rencontre un problème avec l\'application Kapstr. Voici les détails: ', subject: 'Demande d\'aide', recipients: ['contact@kapstr.com'], isHTML: false);

                        await FlutterEmailSender.send(email);
                      },
                      title: const Text('Obtenir de l\'aide', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.help_outline, color: kBlack, size: 20),
                    ),
                  ],
                ),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      bool? shouldDisconnect = await _showDisconnectDialog(context);

                      if (shouldDisconnect == true) {
                        await context.read<AuthenticationController>().logout(context);
                        context.read<UsersController>().user = null;

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EntryPoint()));
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [Text('Me déconnecter', style: TextStyle(color: kDanger, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w400)), const SizedBox(width: 8), const Icon(Icons.logout, color: kDanger, size: 20)],
                    ),
                  ),
                ),
                const SizedBox(height: 96),
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

  void _showCodeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Center(child: Text('Mon code invité', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20),
                      Text(Event.instance.code, style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize)),
                      // Copy code button
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: Event.instance.code));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Code copié dans le presse-papier', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
                        },
                        icon: const Icon(Icons.copy, color: kBlack, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer', style: TextStyle(color: kBlack, fontSize: 16)),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
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

                try {
                  final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                  await storageRefPersonalThemes.putFile(imageFile!);
                  final url = await storageRefPersonalThemes.getDownloadURL();

                  await context.read<UsersController>().updateUserFields({'imageUrl': url});

                  if (!mounted) return;
                  await context.read<UsersController>().saveUser();
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
                  try {
                    final storageRefPersonalThemes = FirebaseStorage.instance.ref().child("users_picture/${firebaseAuth.currentUser!.uid}/${DateTime.now()}.jpg");

                    await storageRefPersonalThemes.putFile(imageFile!);

                    final String url = await storageRefPersonalThemes.getDownloadURL();

                    printOnDebug('URL: $url');

                    if (!mounted) return;

                    await context.read<UsersController>().updateUserFields({'imageUrl': url});

                    if (!mounted) return;
                    await context.read<UsersController>().saveUser();
                  } catch (e) {
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

String getPlanText(String plan) {
  switch (plan) {
    case 'kapstr_basic_plan':
      return 'Basique';
    case 'kapstr_premium_plan':
      return 'Premium';
    case 'kapstr_premium_plus_plan':
      return 'Premium +';
    case 'kapstr_unlimited_plan':
      return 'Illimité';
    default:
      return 'Gratuit';
  }
}

Future<void> _showRenameDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Changer le nom de l\'événement', style: TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w500)),
        content: TextField(controller: nameController, maxLength: 20, decoration: const InputDecoration(hintText: "Entrez un nouveau nom", hintStyle: TextStyle(color: kLightGrey, fontSize: 14))),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Ici, récupérez la valeur du TextField et utilisez-la comme vous le souhaitez
              Navigator.pop(dialogContext);
              printOnDebug('Nouveau nom: ${nameController.text}');

              context.read<EventsController>().updateEventName(Event.instance.id, nameController.text);
            },
            child: Text('Confirmer'),
          ),
        ],
      );
    },
  );
}
