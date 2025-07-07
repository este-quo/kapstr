class Organizer {
  String phone;
  String userId;

  Organizer(this.userId, this.phone);

  factory Organizer.fromMap(Map<String, dynamic> json) {
    return Organizer(
      json['user_id'] ?? "",
      json['phone'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'phone': phone,
    };
  }
}
