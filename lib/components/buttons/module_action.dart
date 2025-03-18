import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/views/organizer/modules/about/about.dart';
import 'package:kapstr/views/organizer/modules/album_photo/album_photo.dart';
import 'package:kapstr/views/organizer/modules/cagnotte/cagnotte.dart';
import 'package:kapstr/views/organizer/modules/golden_book/golden_book.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/card.dart';
import 'package:kapstr/views/organizer/modules/media/media.dart';
import 'package:kapstr/views/organizer/modules/menu/menu.dart';
import 'package:kapstr/views/organizer/modules/tables/tables.dart';
import 'package:kapstr/views/organizer/modules/text/text.dart';
import 'package:provider/provider.dart';

class ModuleAction extends StatelessWidget {
  final Module module;
  final String text;
  final IconData icon;

  const ModuleAction({Key? key, required this.module, required this.text, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Couleur de l'ombre
            spreadRadius: 1, // Taille de l'ombre
            blurRadius: 5, // Flou de l'ombre
            offset: const Offset(0, 3), // Ombre vers le bas (Offset)
          ),
        ],
      ),
      child: SizedBox(
        height: 48, // Taille du bouton
        child: OutlinedButton(
          onPressed: () {
            triggerShortVibration();
            switch (module.type) {
              case 'wedding':
              case 'mairie':
              case 'event':
                Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true)));
                break;
              case 'tables':
                context.read<TablesController>().getTables();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Tables(module: module)));
                break;
              case 'invitation':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InvitationCardPreview()));
                break;
              case 'album_photo':
                Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumPhoto(moduleId: module.id, isGuestView: false)));
                break;
              case 'golden_book':
                Navigator.push(context, MaterialPageRoute(builder: (context) => GoldenBookOrganiser(moduleId: module.id)));
                break;
              case 'cagnotte':
                Navigator.push(context, MaterialPageRoute(builder: (context) => Cagnotte(moduleId: module.id)));
                break;
              case 'menu':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuPreview()));
                break;
              case 'media':
                Navigator.push(context, MaterialPageRoute(builder: (context) => Media(moduleId: module.id)));
                break;
              case 'about':
                Navigator.push(context, MaterialPageRoute(builder: (context) => About(moduleId: module.id)));
                break;
              case 'text':
                Navigator.push(context, MaterialPageRoute(builder: (context) => TextPreview()));
                break;
              default:
                null;
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: kPrimary, width: 1.5), // Bordure rose
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bords arrondis
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16), // Espacement interne
            backgroundColor: Colors.white, // Fond blanc du bouton
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: kPrimary, // Icône rose
              ),
              const SizedBox(width: 8), // Espacement entre l'icône et le texte
              Text(
                text,
                style: TextStyle(
                  color: kPrimary, // Texte en rose
                  fontWeight: FontWeight.w500, // Texte semi-gras
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
