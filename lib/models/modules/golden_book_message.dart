import 'package:cloud_firestore/cloud_firestore.dart';

class GoldenBookMessage {
  final String guestId;
  final String message;
  DateTime date;

  GoldenBookMessage(
    this.guestId,
    this.message,
    this.date,
  );

  Map<String, dynamic> toMap() {
    return {
      'guest_id': guestId,
      'message': message,
      'date': date,
    };
  }

  static GoldenBookMessage fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;

    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.parse(map['date'] ?? DateTime.now().toString());
    }
    return GoldenBookMessage(map['guest_id'], map['message'], parsedDate);
  }
}
