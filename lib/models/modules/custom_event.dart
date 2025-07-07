import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/models/modules/module.dart';

class CustomEvent extends Module {
  CustomEvent({
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
  });

  factory CustomEvent.fromMap(String id, Map<String, dynamic> json) {
    // Extracting the timestamp for date
    var dateTimestamp = json['date'];
    DateTime date = DateTime.now();
    if (dateTimestamp is Timestamp) {
      date = dateTimestamp.toDate();
    }

    return CustomEvent(
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
    );
  }
}
