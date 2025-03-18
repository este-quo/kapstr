import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/themes/constants.dart';

Map<String, dynamic> weddingModule(String moduleName, String eventType) {
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'wedding',
    'allow_guests': true,
    'name': moduleName,
    'image': kEventModuleImages[eventType]?['wedding'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'is_event': true,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'more_infos': 'Plus d\'informations',
  };
}

Map<String, dynamic> goldenBookModule(String eventType) {
  return {
    'type': 'golden_book',
    'text_size': 32,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'color_filter': '99000000',
    'allow_guests': true,
    'name': 'Livre d\'or',
    'image': kEventModuleImages[eventType]?['golden_book'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'guests': [],
    'is_event': true,
    'more_infos': 'Plus d\'informations',
  };
}

Map<String, dynamic> invitationCardModule(String womanFirstName, String manFirstName, String introduction, String conclusion, String eventType) {
  return {
    'type': 'invitation',
    'text_size': 32,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'color_filter': '99000000',
    'allow_guests': true,
    'name': 'Carte d\'invitation',
    'image': kEventModuleImages[eventType]?['invitation'],
    'guests': [],
    'is_event': false,
    'initials': '${capitalize(manFirstName[0])} ${womanFirstName != "" ? ' &${capitalize(womanFirstName[0])}' : ""}',
    'initials_style': {'fontFamily': 'Great Vibes', 'fontSize': 32, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'title': '${capitalize(manFirstName[0])} ${womanFirstName != "" ? ' &${capitalize(womanFirstName[0])}' : ""}',
    'title_style': {'fontFamily': 'Great Vibes', 'fontSize': 48, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'introduction': introduction,
    'introduction_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'conclusion': conclusion,
    'conclusion_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'contact_1': '$manFirstName : ',
    'contact_1_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'contact_2': '$womanFirstName : ',
    'contact_2_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'names_styles': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'party_date_recto_style': {'fontFamily': 'Great Vibes', 'fontSize': 30, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'party_date_verso_style': {'fontFamily': 'Great Vibes', 'fontSize': 30, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'party_place_adress_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'party_place_name_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'party_linking': 'au',
    'party_linking_style': {'fontFamily': 'Great Vibes', 'fontSize': 24, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
  };
}

Map<String, dynamic> mairieModule(String eventType) {
  return {
    'type': 'mairie',
    'text_size': 32,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'color_filter': '99000000',
    'allow_guests': true,
    'name': 'Mairie',
    'image': kEventModuleImages[eventType]?['mairie'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'guests': [],
    'is_event': true,
    'more_infos': 'Plus d\'informations',
  };
}

Map<String, dynamic> albumModule(String eventType) {
  return {'color_filter': '99000000', 'text_size': 32, 'type': 'album_photo', 'allow_guests': true, 'name': 'Album Photo', 'image': kEventModuleImages[eventType]?['album_photo'], 'is_event': false, 'text_color': 'FFFFFF', 'typographie': 'Great Vibes', 'pictures': []};
}

Map<String, dynamic> tableModule(String eventType) {
  return {'color_filter': '99000000', 'text_size': 32, 'type': 'tables', 'allow_guests': true, 'name': 'Tables', 'image': kEventModuleImages[eventType]?['tables'], 'is_event': false, 'text_color': 'FFFFFF', 'typographie': 'Great Vibes', 'tables_id': []};
}

Map<String, dynamic> mediaModule(String moduleName, String eventType) {
  return {'color_filter': '99000000', 'text_size': 32, 'type': 'media', 'allow_guests': true, 'name': moduleName, 'image': kEventModuleImages[eventType]?['media'], 'is_event': false, 'text_color': 'FFFFFF', 'typographie': 'Great Vibes', 'url': '', 'video_id': '', 'media_type': ''};
}

Map<String, dynamic> textModule(String eventType) {
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'text',
    'allow_guests': true,
    'name': 'Texte',
    'image': kEventModuleImages[eventType]?['text'],
    'is_event': false,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'content': 'Cliquez pour éditer le texte',
    'content_style': {'fontFamily': 'Inter', 'fontSize': 16, 'is_bold': false, 'align': 'left', 'color': '000000', 'is_italic': false, 'is_underlined': false},
  };
}

Map<String, dynamic> aboutModule(String eventType) {
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'about',
    'allow_guests': true,
    'name': 'A propos',
    'image': kEventModuleImages[eventType]?['about'],
    'is_event': false,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'title': '',
    'description': '',
    'adress': '',
    'phone': '',
    'email': '',
    'website': '',
  };
}

Map<String, dynamic> eventModule(String eventType, String moduleName) {
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'event',
    'allow_guests': true,
    'name': moduleName,
    'image': kEventModuleImages[eventType]?['event'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'guests': [],
    'is_event': true,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'more_infos': 'Plus d\'informations',
  };
}

Map<String, dynamic> cagnotteModule(String moduleName, String eventType) {
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'cagnotte',
    'allow_guests': true,
    'name': capitalize(moduleName),
    'image': kEventModuleImages[eventType]?['cagnotte'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'guests': [],
    'is_event': true,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'more_infos': 'Plus d\'informations',
    'cagnotte_url': '',
  };
}

Map<String, dynamic> menuModule(String womanFirstName, String manFirstName, String eventType) {
  String names = "";

  womanFirstName != "" ? names = "${capitalize(manFirstName)} & ${capitalize(womanFirstName)}" : names = capitalizeNames(manFirstName);
  return {
    'color_filter': '99000000',
    'text_size': 32,
    'type': 'menu',
    'allow_guests': true,
    'name': 'Menu',
    'image': kEventModuleImages[eventType]?['menu'],
    'date': null,
    'time': null,
    'place_name': 'Nom du lieu',
    'place_address': 'Adresse du lieu',
    'is_event': true,
    'text_color': 'FFFFFF',
    'typographie': 'Great Vibes',
    'more_infos': 'Plus d\'informations',
    'title': 'Menu',
    'title_style': {'fontFamily': 'Cormorant Upright', 'fontSize': 50, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'entry': 'Entrée',
    'entry_style': {'fontFamily': 'Cormorant Upright', 'fontSize': 32, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'main_course': 'Plat',
    'main_course_style': {'fontFamily': 'Cormorant Upright', 'fontSize': 32, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'dessert': 'Dessert',
    'dessert_style': {'fontFamily': 'Cormorant Upright', 'fontSize': 32, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'entry_content': 'Entrée',
    'entry_content_style': {'fontFamily': 'Crimson Text', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'main_course_content': 'Plat',
    'main_course_content_style': {'fontFamily': 'Crimson Text', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'dessert_content': 'Dessert',
    'dessert_content_style': {'fontFamily': 'Crimson Text', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'names': names,
    'names_styles': {'fontFamily': 'Cormorant Upright', 'fontSize': 32, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
    'date_text': '',
    'date_styles': {'fontFamily': 'Cormorant Upright', 'fontSize': 26, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
  };
}
