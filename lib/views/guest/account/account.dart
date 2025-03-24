import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:kapstr/configuration/navigation/entry_point.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/rate_app.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/views/global/profile/modify_profile.dart';
import 'package:kapstr/views/organizer/account/feature.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/account/feature_sections.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class GuestAccountPage extends StatefulWidget {
  const GuestAccountPage({super.key});

  @override
  GuestAccountPageState createState() => GuestAccountPageState();
}

class GuestAccountPageState extends State<GuestAccountPage> {
  AppGuest guest = AppGuest.instance;
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kLighterGrey,
        appBar: AppBar(backgroundColor: kLighterGrey, surfaceTintColor: kWhite, elevation: 0, centerTitle: false, leading: SizedBox.shrink(), leadingWidth: 0, title: const Text('Mon profil', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600))),
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
                            ? const CircleAvatar(radius: 32, backgroundColor: kLightGrey, child: Icon(Icons.person, color: kWhite, size: 24))
                            : CachedNetworkImage(
                              imageUrl: context.watch<UsersController>().user!.imageUrl,
                              imageBuilder: (context, imageProvider) => CircleAvatar(radius: 32, backgroundColor: kLightGrey, backgroundImage: imageProvider),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: kWhite),
                              progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircleAvatar(radius: 32, backgroundColor: kLightGrey, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 20))),
                            ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(capitalizeNames(context.watch<UsersController>().user!.name), style: const TextStyle(fontSize: 20, color: kBlack, fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                Text("Code évènement : ${Event.instance.code}", style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400)),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: Event.instance.code));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Code copié dans le presse-papier', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
                                  },
                                  icon: const Icon(Icons.copy, color: kBlack, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    AccountFeature(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ModifyProfile())).then((value) => setState(() {}));
                      },
                      title: const Text('Modifer mon profil', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                      icon: const Icon(Icons.person_outline_outlined, color: kBlack, size: 20),
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
                    // Account Features
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      bool? shouldDisconnect = await _showDisconnectDialog(context);

                      if (shouldDisconnect == true) {
                        if (context.mounted) await context.read<AuthenticationController>().logout(context);
                        if (context.mounted) context.read<UsersController>().user = null;

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
}
