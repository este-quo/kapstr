import 'package:flutter/material.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/guest/modules/about/about.dart';
import 'package:kapstr/views/guest/modules/album_photo/album_photo.dart';
import 'package:kapstr/views/guest/modules/cagnotte/cagnotte.dart';
import 'package:kapstr/views/guest/modules/golden_book/golden_book.dart';
import 'package:kapstr/views/guest/modules/invitation_card/card.dart';
import 'package:kapstr/views/guest/modules/media/media.dart';
import 'package:kapstr/views/guest/modules/menu/menu.dart';
import 'package:kapstr/views/guest/modules/text/text.dart';
import 'package:kapstr/views/guest/modules/wedding/wedding.dart';
import 'package:kapstr/views/guest/modules/tables/table.dart';

Widget buildGuestModuleView({required Module module, isPreview = false}) {
  switch (module.type) {
    // done
    case 'mairie':
      return WeddingGuest(module: module, isPreview: isPreview);
    case 'album_photo':
      return AlbumPhotoGuest(moduleId: module.id, isPreview: isPreview);
    // done
    case 'wedding':
      return WeddingGuest(module: module, isPreview: isPreview);
    // done
    case 'invitation':
      return InvitationCard(isPreview: isPreview);
    // done
    case 'event':
      return WeddingGuest(module: module, isPreview: isPreview);
    // done
    case 'cagnotte':
      return GuestCagnotteModule(moduleId: module.id, isPreview: isPreview);
    // done
    case 'tables':
      return TablesGuest(module: module, isPreview: isPreview);
    // done
    case 'media':
      return MediaGuest(moduleId: module.id, isPreview: isPreview);
    // done
    case 'menu':
      return MenuGuest(isPreview: isPreview);
    // done
    case 'golden_book':
      return GoldenBookGuest(moduleId: module.id, isPreview: isPreview);
    case 'about':
      return AboutGuest(moduleId: module.id);

    case 'text':
      return TextGuest(isPreview: isPreview);
    default:
      return const Text('Module non reconnu');
  }
}
