class AppGuest {
  String id = "";
  List<String> allowedModules = [];
  int totalOfPeople = 0;
  List<dynamic> children = [];
  String phone = "";
  String code = "";
  String name = "";
  String tableId = "";
  String imageUrl = "";
  List<dynamic> typeOfGuests = [];
  List<dynamic> postedPictures = [];
  bool isSelected = false;

  static final AppGuest _instance = AppGuest._internal();
  AppGuest._internal();
  static AppGuest get instance {
    return _instance;
  }

  factory AppGuest(Map<String, dynamic> user, String id) {
    _instance.allowedModules = List<String>.from(user['allowed_modules'] ?? []);
    _instance.totalOfPeople = user['total_of_people'] ?? 0;
    _instance.children = user['children'] ?? [];
    _instance.id = id;
    _instance.code = user['code'] ?? "";
    _instance.name = user['name'] ?? "";
    _instance.tableId = user['table_id'] ?? "";
    _instance.imageUrl = user['image_url'] ?? "";
    _instance.typeOfGuests = user['type_of_guests'] ?? [];
    _instance.postedPictures = user['posted_pictures'] ?? [];
    _instance.isSelected = false;
    _instance.phone = user['phone'] ?? "";

    return _instance;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': AppGuest.instance.id,
      'allowed_modules': AppGuest.instance.allowedModules,
      'total_of_people': AppGuest.instance.totalOfPeople,
      'children': AppGuest.instance.children,
      'phone': AppGuest.instance.phone,
      'code': AppGuest.instance.code,
      'name': AppGuest.instance.name,
      'table_id': AppGuest.instance.tableId,
      'image_url': AppGuest.instance.imageUrl,
      'type_of_guests': AppGuest.instance.typeOfGuests,
      'posted_pictures': AppGuest.instance.postedPictures,
    };

    return map;
  }
}
