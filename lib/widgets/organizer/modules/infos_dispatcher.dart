import 'package:flutter/material.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/guest/modules/view_manager.dart';
import 'package:kapstr/views/organizer/modules/about/about.dart';
import 'package:kapstr/views/organizer/modules/cagnotte/cagnotte.dart';
import 'package:kapstr/views/organizer/modules/golden_book/golden_book.dart';
import 'package:kapstr/views/organizer/modules/invitation_card/card.dart';
import 'package:kapstr/views/organizer/modules/media/media.dart';
import 'package:kapstr/views/organizer/modules/menu/menu.dart';
import 'package:kapstr/views/organizer/modules/tables/tables.dart';
import 'package:kapstr/views/organizer/modules/text/text.dart';
import 'package:kapstr/views/organizer/modules/album_photo/album_photo.dart';

class CustomModuleDispatcher extends StatelessWidget {
  final Module module;

  const CustomModuleDispatcher({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        triggerShortVibration();

        switch (module.type) {
          case 'wedding':
            Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true)));
            break;
          case 'mairie':
            Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true)));
            break;
          case 'event':
            Navigator.push(context, MaterialPageRoute(builder: (context) => buildGuestModuleView(module: module, isPreview: true)));
            break;
          case 'tables':
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
      child: Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: kBlack.withValues(alpha: 0.2), strokeAlign: BorderSide.strokeAlignOutside)),
        child: Row(),
      ),
    );
  }
}
