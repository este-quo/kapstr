class User {
  String id;
  String name;
  String email;
  String imageUrl;
  String phone;
  List<String> joinedEvents;
  List<String> createdEvents;
  int credits;
  bool onboardingComplete;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.phone,
    required this.joinedEvents,
    required this.createdEvents,
    required this.credits,
    required this.onboardingComplete,
  });

  factory User.fromMap(Map<String, dynamic> json, String id) {
    return User(
      id: id,
      name: json['name'],
      email: json['email'],
      imageUrl: json['image_url'],
      phone: json['phone'],
      joinedEvents: List<String>.from(json['joined_events'] ?? []),
      createdEvents: List<String>.from(json['created_events'] ?? []),
      credits: json['credits'],
      onboardingComplete: json['onboarding_complete'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'phone': phone,
      'joined_events': joinedEvents,
      'created_events': createdEvents,
      'credits': credits,
      'onboarding_complete': onboardingComplete,
    };
  }

  void updateField(String key, dynamic value) {
    switch (key) {
      case 'name':
        name = value;
        break;
      case 'email':
        email = value;
        break;
      case 'imageUrl':
        imageUrl = value;
        break;
      case 'phone':
        phone = value;
        break;
      case 'joinedEvents':
        joinedEvents = value;
        break;
      case 'createdEvents':
        createdEvents = value;
        break;
      case 'credits':
        credits = value;
        break;
      case 'onboardingComplete':
        onboardingComplete = value;
        break;
    }
  }
}
