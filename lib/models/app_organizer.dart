class AppOrganizer {
  String name = "";
  String id = "";
  String email = "";
  String eventId = "";
  String imageUrl = "";
  bool onboardingComplete = true;
  String phone = "";

  static final AppOrganizer _instance = AppOrganizer._internal();
  AppOrganizer._internal();
  static AppOrganizer get instance {
    return _instance;
  }

  factory AppOrganizer(Map<String, dynamic> user, String id) {
    _instance.name = user['name'] ?? "";
    _instance.email = user['email'] ?? "";
    _instance.eventId = user['event_id'] ?? "";
    _instance.imageUrl = user['image_url'] ?? "";
    _instance.onboardingComplete = user['onboarding_complete'] ?? false;
    _instance.phone = user['phone'] ?? "";
    _instance.id = id;
    return _instance;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': AppOrganizer.instance.id,
      'name': AppOrganizer.instance.name,
      'email': AppOrganizer.instance.email,
      'event_id': AppOrganizer.instance.eventId,
      'image_url': AppOrganizer.instance.imageUrl,
      'onboarding_complete': AppOrganizer.instance.onboardingComplete,
      'phone': AppOrganizer.instance.phone,
    };

    return map;
  }
}
