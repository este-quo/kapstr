import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id = '';
  String name = '';
  String profilePictureUrl = '';
  List<String> imagesUrl = [];
  String content = '';
  DateTime postedAt = DateTime.now();
  String userId = '';
  List<String> warns = [];

  Post({
    required this.id,
    required this.name,
    required this.imagesUrl,
    required this.profilePictureUrl,
    required this.content,
    required this.postedAt,
    required this.userId,
    required this.warns,
  });

  factory Post.fromMap(String id, Map<String, dynamic> json) {
    // Handle 'postedAt' as Timestamp and convert to DateTime
    var postedAt = json['posted_at'];
    DateTime parsedPostedAt;

    if (postedAt is Timestamp) {
      // Convert Firebase Timestamp to DateTime
      parsedPostedAt = postedAt.toDate();
    } else {
      // Handle other cases or provide a default value
      // You can log an error or use a default date
      parsedPostedAt = DateTime.now(); // or handle error as needed
    }

    return Post(
      id: id,
      name: json['name'],
      imagesUrl: List<String>.from(json['images_url'] ?? []),
      profilePictureUrl: json['profile_picture_url'],
      content: json['content'],
      postedAt: parsedPostedAt,
      userId: json['user_id'],
      warns: List<String>.from(json['warns'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imagesUrl,
      'profile_picture_url': profilePictureUrl,
      'content': content,
      'posted_at': postedAt.toString(),
      'user_id': userId,
      'warns': warns,
    };
  }
}
