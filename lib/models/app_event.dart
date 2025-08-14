import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/module.dart';

class Event {
  String plan = "";
  DateTime? planEndAt;
  String eventName = "";
  String manFirstName = "";
  String manLastName = "";
  String womanFirstName = "";
  String womanLastName = "";
  bool showTablesEarly = false;
  String eventType = "";
  String blocDisposition = "";
  String buttonColor = "";
  String buttonTextColor = "";
  DateTime? date;
  List<String> favoriteColors = [];
  List<String> favoriteFonts = [];
  List<String> organiserAuthId = [];
  String textColor = "";
  String fullResThemeUrl = "";
  String lowResThemeUrl = "";
  String themeType = "";
  String themeName = "";
  List<String> themeColors = [];
  List<String> customThemeUrls = [];
  List<String> modulesOrder = [];
  List<String> organizerToAdd = [];
  List<String> organizerAdded = [];
  double themeOpacity = 100.0;
  List<Module> modules = [];
  String id = "";
  List<Guest> guests = [];
  String code = "";
  String code_organizer = "";
  String saveTheDateThumbnail = "";
  DateTime? createdAt;
  String visibility = "";
  String logoUrl = "";
  bool isUnlocked = false;

  static final Event _instance = Event._internal();
  Event._internal();
  static Event get instance {
    return _instance;
  }

  factory Event(Map<String, dynamic> eventData, String id, List<Module> modules, List<Guest> guests) {
    _instance.id = id;
    _instance.eventName = eventData['event_name'] ?? "";
    _instance.manFirstName = eventData['man_first_name'] ?? "";
    _instance.manLastName = eventData['man_last_name'] ?? "";
    _instance.womanFirstName = eventData['woman_first_name'] ?? "";
    _instance.womanLastName = eventData['woman_last_name'] ?? "";
    _instance.showTablesEarly = eventData['show_tables_early'] ?? false;
    _instance.blocDisposition = eventData['bloc_disposition'] ?? "grid";
    _instance.buttonColor = eventData['button_color'] ?? "";
    _instance.buttonTextColor = eventData['button_text_color'] ?? "";
    _instance.eventType = eventData['event_type'] ?? "";
    _instance.date = DateTime.parse(eventData['date'] ?? "");
    _instance.favoriteColors = List<String>.from(eventData['favorite_colors'] ?? []);
    _instance.favoriteFonts = List<String>.from(eventData['favorite_fonts'] ?? []);
    _instance.organizerToAdd = List<String>.from(eventData['organizer_to_add'] ?? []);
    _instance.organizerAdded = List<String>.from(eventData['organizer_added'] ?? []);
    _instance.organiserAuthId = List<String>.from(eventData['organiser_auth_id'] ?? []);
    _instance.modulesOrder = List<String>.from(eventData['modules_order'] ?? []);
    _instance.textColor = eventData['text_color'] ?? "";
    _instance.lowResThemeUrl = eventData['low_res_theme_url'] ?? "";
    _instance.fullResThemeUrl = eventData['full_res_theme_url'] ?? "";
    _instance.themeType = eventData['theme_type'] ?? "";
    _instance.themeName = eventData['theme_name'] ?? "";
    _instance.themeOpacity = eventData['theme_opacity'] is int ? (eventData['theme_opacity'] as int).toDouble() : eventData['theme_opacity'] ?? 100.0;
    _instance.themeColors = List<String>.from(eventData['theme_colors'] ?? []);
    _instance.modules = modules;
    _instance.guests = guests;
    _instance.visibility = eventData['visibility'] ?? "";
    _instance.code = eventData["code"] ?? "";
    _instance.code_organizer = eventData["code_organizer"] ?? "";

    _instance.saveTheDateThumbnail = eventData["save_the_date_thumbnail"] ?? "";
    _instance.createdAt = DateTime.parse(eventData["created_at"] ?? "");
    _instance.logoUrl = eventData["event_logo_url"] ?? "";
    _instance.plan = eventData["plan"] ?? "free_plan";
    _instance.planEndAt = eventData["plan_end_at"] != null ? DateTime.parse(eventData["plan_end_at"]) : null;
    _instance.customThemeUrls = List<String>.from(eventData['custom_theme_urls'] ?? []);
    _instance.isUnlocked = eventData['isUnlocked'] ?? false;

    return _instance;
  }

  Map<String, dynamic> toMap() {
    return {
      'event_name': eventName,
      'man_first_name': manFirstName,
      'man_last_name': manLastName,
      'woman_first_name': womanFirstName,
      'woman_last_name': womanLastName,
      'show_tables_early': showTablesEarly,
      'bloc_disposition': blocDisposition,
      'button_color': buttonColor,
      'button_text_color': buttonTextColor,
      'event_type': eventType,
      'date': date?.toIso8601String(),
      'favorite_colors': favoriteColors,
      'favorite_fonts': favoriteFonts,
      'organizer_to_add': organizerToAdd,
      'organizer_added': organizerAdded,
      'organiser_auth_id': organiserAuthId,
      'modules_order': modulesOrder,
      'text_color': textColor,
      'low_res_theme_url': lowResThemeUrl,
      'full_res_theme_url': fullResThemeUrl,
      'theme_type': themeType,
      'theme_name': themeName,
      'theme_opacity': themeOpacity,
      'theme_colors': themeColors,
      'custom_theme_urls': customThemeUrls,
      'visibility': visibility,
      'code': code,
      'code_organizer': code_organizer,
      'save_the_date_thumbnail': saveTheDateThumbnail,
      'created_at': createdAt?.toIso8601String(),
      'event_logo_url': logoUrl,
      'plan': plan,
      'plan_end_at': planEndAt?.toIso8601String(),
      'is_unlocked': isUnlocked,
    };
  }

  List<Module> get modulesAllowingGuest {
    return modules.where((module) => module.allowGuest == true).toList();
  }

  void addOrganizer(String guestId) {
    if (!organizerAdded.contains(guestId)) {
      organizerAdded.add(guestId);
    }
  }

  void removeOrganizerToAdd(String organizerId) {
    organizerToAdd.remove(organizerId);
  }

  void removeOrganizerAdded(String organizerId) {
    organizerAdded.remove(organizerId);
  }

  String getOrganizerNameByPhone(String guestPhone) {
    // Trouver le guest correspondant à l'ID
    Guest? organizer = guests.firstWhere((guest) => guest.phone == guestPhone, orElse: () => Guest(userId: '', id: '', name: 'Inconnu', phone: '', tableId: '', hasJoined: false, imageUrl: '', postedPictures: [], allowedModules: []));
    return organizer.name;
  }

  bool getOrganizerHasJoinedByPhone(String guestPhone) {
    // Trouver le guest correspondant à l'ID
    Guest? organizer = guests.firstWhere((guest) => guest.phone == guestPhone, orElse: () => Guest(userId: '', id: '', name: 'Inconnu', phone: '', tableId: '', hasJoined: false, imageUrl: '', postedPictures: [], allowedModules: []));
    return organizer.hasJoined;
  }

  String getOrganizerImageUrlByPhone(String guestPhone) {
    // Trouver le guest correspondant à l'ID
    Guest? organizer = guests.firstWhere(
      (guest) => guest.phone == guestPhone,
      orElse: () => Guest(userId: '', id: '', name: 'Inconnu', phone: '', tableId: '', hasJoined: false, imageUrl: '', postedPictures: [], allowedModules: []), // Retourner un invité par défaut si non trouvé
    );
    return organizer.imageUrl;
  }
}
