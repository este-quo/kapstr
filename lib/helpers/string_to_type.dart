import 'package:kapstr/models/modules/module.dart';

ModuleType stringToType(String type) {
  switch (type) {
    case "mairie":
      return ModuleType.mairie;
    case "invitation":
      return ModuleType.invitation;
    case "wedding":
      return ModuleType.wedding;
    case "budget":
      return ModuleType.budget;
    case "album_photo":
      return ModuleType.albumPhoto;
    case "tables":
      return ModuleType.tables;
    case "event":
      return ModuleType.customEvent;
    case "cagnotte":
      return ModuleType.cagnotte;
    case "golden_book":
      return ModuleType.goldenBook;
    case "media":
      return ModuleType.media;
    case "about":
      return ModuleType.about;

    default:
      return ModuleType.mairie;
  }
}
