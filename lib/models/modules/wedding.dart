import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/models/modules/module.dart';

class WeddingModule extends Module {
  // Additional fields specific to PartyModule
  // ...

  WeddingModule({
    required super.id,
    required super.allowGuest,
    required super.colorFilter,
    required DateTime super.date,
    required super.image,
    required super.isEvent,
    required super.moreInfos,
    required super.name,
    required String super.placeAddress,
    required String super.placeName,
    required super.textColor,
    required super.textSize,
    required super.type,
    required super.fontType,
    // Add additional fields specific to PartyModule here
    // ...
  });

  static WeddingModule fromMap(String id, Map<String, dynamic> json) {
    DateTime date;
    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      date = DateTime.parse(json['date']);
    } else {
      date = DateTime.now();
    }
    return WeddingModule(
      id: id,
      allowGuest: json['allow_guests'] ?? true,
      colorFilter: json['color_filter'] ?? "",
      date: date,
      image: json['image'] ?? "",
      isEvent: json['is_event'] ?? true,
      moreInfos: json['more_infos'] ?? "",
      name: json['name'] ?? "",
      placeAddress: json['place_address'] ?? "",
      placeName: json['place_name'] ?? "",
      textColor: json['text_color'] ?? "",
      textSize: json['text_size'] is int ? json['text_size'] : 32,
      type: json['type'] ?? "",
      fontType: json['typographie'] ?? "",
      // Add additional fields specific to PartyModule here
      // ...
    );
  }
}
