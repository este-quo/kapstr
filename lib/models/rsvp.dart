import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/models/added_guest.dart';

class RSVP {
  String? id;
  String guestId;
  String moduleId;
  bool isAllowed;
  String response;
  List<AddedGuest> adults;
  List<AddedGuest> children;
  DateTime createdAt;
  bool isAnswered;

  RSVP({this.id, required this.guestId, required this.moduleId, required this.isAllowed, required this.response, required this.adults, required this.children, required this.createdAt, required this.isAnswered});

  Map<String, dynamic> toMap() => {'guest_id': guestId, 'module_id': moduleId, 'is_allowed': isAllowed, 'response': response, 'adults': adults.map((guest) => guest.toMap()).toList(), 'children': children.map((guest) => guest.toMap()).toList(), 'created_at': createdAt, 'is_answered': isAnswered};

  factory RSVP.fromMap(Map<String, dynamic> json, String id) {
    DateTime createdAt;

    if (json['created_at'] is Timestamp) {
      createdAt = (json['created_at'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.parse(json['created_at']);
    }
    return RSVP(id: id, guestId: json['guest_id'], moduleId: json['module_id'], isAllowed: json['is_allowed'], response: json['response'], adults: fromMapList(json['adults']), children: fromMapList(json['children']), createdAt: createdAt, isAnswered: json['is_answered']);
  }
}
