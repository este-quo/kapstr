import 'package:cloud_firestore/cloud_firestore.dart';

class MyNotification {
  String id;
  String title;
  String body;
  String? image;
  String target;
  String type;
  List<String> seenBy = [];
  Timestamp createdAt = Timestamp.now();

  MyNotification({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    required this.target,
    this.type = 'notification',
    required this.seenBy,
    required this.createdAt,
  });

  factory MyNotification.fromMap(String id, Map<String, dynamic> json) {
    return MyNotification(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'] ?? '',
      target: json['target'] ?? '',
      seenBy: List<String>.from(json['seen_by'] ?? []),
      type: json['type'] ?? 'notification',
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'image': image,
      'target': target,
      'type': type,
      'seen_by': seenBy,
      'createdAt': createdAt,
    };
  }
}
