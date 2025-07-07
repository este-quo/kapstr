import 'package:kapstr/models/modules/about.dart';
import 'package:kapstr/models/modules/cagnotte.dart';
import 'package:kapstr/models/modules/custom_event.dart';
import 'package:kapstr/models/modules/golden_book.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/models/modules/mairie.dart';
import 'package:kapstr/models/modules/media.dart';
import 'package:kapstr/models/modules/text.dart';
import 'package:kapstr/models/modules/wedding.dart';
import 'package:kapstr/models/modules/album_photo.dart';
import 'package:kapstr/models/modules/tables.dart';

enum ModuleType { mairie, invitation, wedding, budget, albumPhoto, tables, customEvent, cagnotte, about, goldenBook, media, text }

class Module {
  String id = "";
  bool allowGuest = true;
  String colorFilter = "";
  DateTime? date;
  String image = "";

  bool isEvent = true;
  String moreInfos = "";
  String name = "";
  String? placeAddress = "";
  String? placeName = "";
  String textColor = "";
  int textSize = 0;
  String type = "";
  String fontType = "";

  Module({
    required this.id,
    required this.allowGuest,
    required this.colorFilter,
    this.date,
    required this.image,
    required this.isEvent,
    required this.moreInfos,
    required this.name,
    this.placeAddress,
    this.placeName,
    required this.textColor,
    required this.textSize,
    required this.type,
    required this.fontType,
  });

  factory Module.fromMap(String id, Map<String, dynamic> json, ModuleType type) {
    switch (type) {
      case ModuleType.mairie:
        return MairieModule.fromMap(id, json);
      case ModuleType.invitation:
        return InvitationModule.fromMap(id, json);
      case ModuleType.wedding:
        return WeddingModule.fromMap(id, json);
      case ModuleType.albumPhoto:
        return AlbumPhotoModule.fromMap(id, json);
      case ModuleType.tables:
        return TableModule.fromMap(id, json);
      case ModuleType.customEvent:
        return CustomEvent.fromMap(id, json);
      case ModuleType.cagnotte:
        return CagnotteModule.fromMap(id, json);
      case ModuleType.about:
        return AboutModule.fromMap(id, json);
      case ModuleType.goldenBook:
        return GoldenBookModule.fromMap(id, json);
      case ModuleType.media:
        return MediaModule.fromMap(id, json);
      case ModuleType.text:
        return TextModule.fromMap(id, json);
      default:
        return Module.fromMap(id, json, ModuleType.mairie);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'allow_guests': allowGuest,
      'color_filter': colorFilter,
      'date': date.toString(),
      'image': image,
      'is_event': isEvent,
      'more_infos': moreInfos,
      'name': name,
      'place_address': placeAddress,
      'place_name': placeName,
      'text_color': textColor,
      'text_size': textSize,
      'type': type,
      'font_type': fontType,
    };
  }
}
