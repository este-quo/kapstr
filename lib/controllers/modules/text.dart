import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/text.dart';
import 'package:kapstr/themes/constants.dart';

class TextModuleController extends ChangeNotifier {
  TextModule currentText = TextModule(id: "", allowGuest: false, colorFilter: "", image: "", isEvent: false, moreInfos: "", name: "", textSize: 0, textColor: "", type: "", fontType: "", content: "", contentStyle: {});

  Future<void> getTextById() async {
    // check Event have a module with a type text
    if (Event.instance.modules.any((element) => element.type == 'text')) {
      try {
        DocumentSnapshot doc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: 'text').get().then((value) => value.docs.first);

        if (doc.exists) {
          currentText = TextModule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          printOnDebug("Text fetched: ${currentText.name}");
          notifyListeners();
        } else {
          printOnDebug("Text not found");
        }
      } catch (e) {
        printOnDebug("Error fetching Text: $e");
      }
    } else {
      printOnDebug("No Text module found");
    }
  }

  Future<void> updateText(TextModule text) async {
    printOnDebug("Trying to update : ${currentText.name}");

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(text.id).update(text.toMap());
      currentText = text; // Update the currentInvitation
      printOnDebug("text updated: ${currentText.name}");
      notifyListeners(); // Notify listeners about the update
    } catch (e) {
      printOnDebug("Error updating text: $e");
    }
  }

  Future<void> updateStyleMap(String styleKey, Map<String, dynamic> newStyle) async {
    // Check which style map to update and update it
    switch (styleKey) {
      case "contentStyle":
        currentText.contentStyle = newStyle;
        break;

      default:
        printOnDebug("Invalid style key: $styleKey");
        return;
    }
    notifyListeners();

    // Update the invitation in Firestore and notify listeners
    try {
      await updateText(currentText);
      printOnDebug("Style updated for key: $styleKey");
    } catch (e) {
      printOnDebug("Error updating style: $e");
    }
    notifyListeners();
  }
}
