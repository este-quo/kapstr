import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/menu.dart';
import 'package:kapstr/themes/constants.dart';

class MenuModuleController extends ChangeNotifier {
  MenuModule currentMenu = MenuModule(
    id: "",
    allowGuest: false,
    colorFilter: "",
    image: "",
    isEvent: false,
    moreInfos: "",
    name: "",
    textSize: 0,
    textColor: "",
    type: "",
    fontType: "",
    title: "",
    titleStyle: {},
    entry: "",
    entryStyle: {},
    mainCourse: "",
    mainCourseStyle: {},
    dessert: "",
    dessertStyle: {},
    entryContent: "",
    entryContentStyle: {},
    mainCourseContent: "",
    mainCourseContentStyle: {},
    dessertContent: "",
    dessertContentStyle: {},
    names: "",
    namesStyles: {},
    dateText: "",
    dateStyles: {},
  );

  Future<void> getMenuById() async {
    // check Event have a module with a type menu
    if (Event.instance.modules.any((element) => element.type == 'menu')) {
      try {
        DocumentSnapshot doc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: 'menu').get().then((value) => value.docs.first);

        if (doc.exists) {
          currentMenu = MenuModule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          printOnDebug("Menu fetched: ${currentMenu.name}");
          notifyListeners();
        } else {
          printOnDebug("Menu not found");
        }
      } catch (e) {
        printOnDebug("Error fetching Menu: $e");
      }
    } else {
      printOnDebug("No menu module found");
    }
  }

  Future<void> updateMenu(MenuModule menu) async {
    printOnDebug("Trying to update : ${currentMenu.name}");

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(menu.id).update(menu.toMap());
      currentMenu = menu; // Update the currentInvitation
      printOnDebug("menu updated: ${currentMenu.name}");
      notifyListeners(); // Notify listeners about the update
    } catch (e) {
      printOnDebug("Error updating menu: $e");
    }
  }

  Future<void> updateStyleMap(String styleKey, Map<String, dynamic> newStyle) async {
    // Check which style map to update and update it
    switch (styleKey) {
      case 'titleStyle':
        currentMenu.titleStyle = newStyle;
        break;
      case 'entryStyle':
        currentMenu.entryStyle = newStyle;
        break;
      case 'mainCourseStyle':
        currentMenu.mainCourseStyle = newStyle;
        break;
      case 'dessertStyle':
        currentMenu.dessertStyle = newStyle;
        break;
      case 'entryContentStyle':
        currentMenu.entryContentStyle = newStyle;
        break;
      case 'mainCourseContentStyle':
        currentMenu.mainCourseContentStyle = newStyle;
        break;
      case 'dessertContentStyle':
        currentMenu.dessertContentStyle = newStyle;
        break;
      case 'namesStyles':
        currentMenu.namesStyles = newStyle;
        break;
      case 'dateStyles':
        currentMenu.dateStyles = newStyle;
        break;

      default:
        printOnDebug("Invalid style key: $styleKey");
        return;
    }
    notifyListeners();

    // Update the invitation in Firestore and notify listeners
    try {
      await updateMenu(currentMenu);
      printOnDebug("Style updated for key: $styleKey");
    } catch (e) {
      printOnDebug("Error updating style: $e");
    }
    notifyListeners();
  }

  Future<void> resetMenu() async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(currentMenu.id).update({
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
        'names': '${capitalize(Event.instance.manFirstName)} & ${capitalize(Event.instance.womanFirstName)}',
        'names_styles': {'fontFamily': 'Great Vibes', 'fontSize': 32, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'date_text': '',
        'date_styles': {'fontFamily': 'Cormorant Upright', 'fontSize': 26, 'is_bold': true, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
      });
      await getMenuById();
      printOnDebug("Menu reset");
      notifyListeners();
    } catch (e) {
      printOnDebug("Error resetting menu: $e");
    }
  }
}
