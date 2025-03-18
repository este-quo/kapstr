class Guest {
  String userId = "";
  String id = "";
  String name = "";
  String phone = "";
  bool hasJoined = false;
  String tableId = "";
  String imageUrl = "";
  List<dynamic> postedPictures = [];
  bool isSelected;
  List<String> allowedModules = [];

  Guest({
    required this.userId,
    required this.id,
    required this.name,
    required this.phone,
    required this.tableId,
    required this.imageUrl,
    required this.postedPictures,
    required this.hasJoined,
    this.isSelected = false,
    required this.allowedModules,
  });

  factory Guest.fromMap(Map<String, dynamic> json, String id) {
    return Guest(
      userId: json['user_id'],
      id: id,
      name: json['name'],
      phone: json['phone'],
      tableId: json['table_id'],
      imageUrl: json['image_url'],
      hasJoined: json['has_joined'] ?? false,
      postedPictures: json['posted_pictures'] ?? [],
      allowedModules: List<String>.from(json['allowed_modules'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'id': id,
      'name': name,
      'phone': phone,
      'table_id': tableId,
      'has_joined': hasJoined,
      'image_url': imageUrl,
      'posted_pictures': postedPictures,
      'allowed_modules': allowedModules,
    };
  }

  void update(Map<String, dynamic> newValues) {
    if (newValues['name'] != null) {
      name = newValues['name'];
    }
    if (newValues['phone'] != null) {
      phone = newValues['phone'];
    }

    if (newValues['posted_pictures'] != null) {
      postedPictures = newValues['posted_pictures'];
    }
    if (newValues['table_id'] != null) {
      tableId = newValues['table_id'];
    }
    if (newValues['image_url'] != null) {
      imageUrl = newValues['image_url'];
    }

    if (newValues['has_joined'] != null) {
      hasJoined = newValues['has_joined'];
    }
    if (newValues['allowed_modules'] != null) {
      allowedModules = newValues['allowed_modules'];
    }
  }
}
