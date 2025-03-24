import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/helpers/string_to_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kapstr/helpers/module_data.dart' as module_data;

class ModulesController extends ChangeNotifier {
  final Event _event;
  Module? _currentModule;

  Module? get currentModule => _currentModule;

  set currentModule(Module? module) {
    _currentModule = module;
    notifyListeners();
  }

  ModulesController(Event event) : _event = event;

  Module getModuleById(String moduleId) {
    return _event.modules.firstWhere((element) => element.id == moduleId);
  }

  List<Guest> getModuleGuests(String moduleId) {
    return _event.guests.where((element) => element.allowedModules.contains(moduleId)).toList();
  }

  Future<List<Module>> getModules(String eventId) async {
    return await configuration.getCollectionPath('events').doc(eventId).collection('modules').get().then((value) => value.docs.map((e) => Module.fromMap(e.id, e.data(), stringToType(e['type']))).toList());
  }

  Future<void> updateAllModulesWithChoosenCustom({required String colorFilter, required String font, required String textColor, required int textSize}) async {
    try {
      var modules = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').get();
      for (var module in modules.docs) {
        await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(module.id).update({'color_filter': colorFilter, 'typographie': font, 'text_color': textColor, 'text_size': textSize});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> getModuleIdByNameOrganiser({required String moduleName, required String eventId}) async {
    try {
      String moduleId = '';
      await configuration.getCollectionPath('events').doc(eventId).collection('modules').where('name', isEqualTo: moduleName).get().then((value) {
        moduleId = value.docs.first.id;
      });
      return moduleId;
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updateImage({required String newImage, required String moduleId}) async {
    Event.instance.modules.firstWhere((element) => element.id == moduleId).image = newImage;

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'image': newImage});
    } catch (e) {
      throw Exception(e);
    }

    if (Event.instance.modules.firstWhere((element) => element.id == moduleId).type == 'wedding') {
      Event.instance.saveTheDateThumbnail = newImage;

      try {
        await configuration.getCollectionPath('events').doc(Event.instance.id).update({'save_the_date_thumbnail': newImage});
      } catch (e) {
        throw Exception(e);
      }
    }

    notifyListeners();
  }

  //update module name
  Future<void> updatePlaceName({required String placeName, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'place_name': capitalize(placeName)});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateColorFilter({required String color, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'color_filter': color});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateTextColor({required String color, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'text_color': color});
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updateTypoModule({required String selectedFont, required String moduleId}) async {
    if (!Event.instance.favoriteFonts.contains(selectedFont)) {
      Event.instance.favoriteFonts.add(selectedFont);
    }

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'typographie': selectedFont});

      await configuration.getCollectionPath('events').doc(Event.instance.id).update({
        'favorite_fonts': FieldValue.arrayUnion([selectedFont]),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updateFontSize({required int textSize, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'text_size': textSize});
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updatePlaceAddress({required String placeAddress, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'place_address': placeAddress});
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updateDate({required DateTime newDateTime, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'date': newDateTime});
    } catch (e) {
      throw Exception(e);
    }
  }

  //update module name
  Future<void> updateMoreInfos({required String moreInfos, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'more_infos': moreInfos});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> clearDesign({required String moduleId}) async {
    try {
      var image = '';
      var module = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).get();
      switch (module['type']) {
        case "tables":
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_tables.jpg?alt=media&token=4bc970ed-1c47-4eec-a2fc-2bc57c678419';
          break;
        case 'album_photo':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_album_photo.jpg?alt=media&token=e21b7a26-5bd2-4c6a-934f-eeb6416a1d35';
          break;
        case 'event':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_nouvel_evenement.jpg?alt=media&token=56e04d8e-3555-4832-9687-c6ab891f726d';
          break;
        case 'mairie':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_mairie.jpg?alt=media&token=63bf3523-56ef-4f70-8655-2fa5e601845d';
          break;
        case 'invitation':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_carte_invitation.jpg?alt=media&token=dca4bb7c-76f8-4cf5-8018-41249400ad5d';
          break;
        case 'golden_book':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_golden_book.jpg?alt=media&token=77eb6ad0-7829-4abf-ab78-4f37dc792d6a';
          break;
        case 'wedding':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_wedding.jpg?alt=media&token=33db7eca-40b6-42d0-b394-3e9e6e964ca0';
          break;
        case 'menu':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_menu.jpg?alt=media&token=ba443dea-d963-4139-a375-ce16cab5c5d7';
          break;
        case 'cagnotte':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_cagnotte.jpg?alt=media&token=bb54f6f1-beef-416a-95cb-6a8539b4d441';
          break;
        case 'media':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_media.jpg?alt=media&token=cf99d167-9c0d-4c76-b342-0a5b893e7a18';
          break;
        case 'about':
          image = 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding%2Fwedding_about.jpg?alt=media&token=c1b6fcf1-5e09-41f3-8857-014c340d180d';
          break;
      }

      if (Event.instance.fullResThemeUrl.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final int? darkColor1Value = prefs.getInt('${Event.instance.id}_darkColor1');
        final int? darkColor2Value = prefs.getInt('${Event.instance.id}_darkColor2');

        if (darkColor1Value != null && darkColor2Value != null) {
          final Color darkColor1 = Color(darkColor1Value);
          final Color darkColor2 = Color(darkColor2Value);

          // Nombre de modules
          final numModules = Event.instance.modules.length - 1;

          Color selectedColor = darkColor1;

          int numRow = numModules ~/ 2;

          if (numModules % 2 == 0) {
            selectedColor = numRow % 2 == 0 ? darkColor1 : darkColor2;
          } else {
            selectedColor = numRow % 2 == 0 ? darkColor2 : darkColor1;
          }

          await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({
            'text_size': 32,
            'text_color': 'FFFFFF',
            'typographie': 'Great Vibes',
            'color_filter': selectedColor.withValues(alpha: 0.6).toARGB32().toRadixString(16).padLeft(8, '0'),
            'image': image,
          });
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteModule({required String moduleId}) async {
    try {
      Event.instance.modulesOrder.remove(moduleId);
      Event.instance.modules.removeWhere((element) => element.id == moduleId);

      // Delete RSVPs for this module
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('rsvps').where('module_id', isEqualTo: moduleId).get().then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });

      // Delete module from modules order
      await configuration.getCollectionPath('events').doc(Event.instance.id).update({'modules_order': Event.instance.modulesOrder});

      // Delete module from modules collection
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteGuests({required List<dynamic> guestsToDelete, required String moduleId}) async {
    try {
      for (var guest in guestsToDelete) {
        await configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').where('phone', isEqualTo: guest).get().then((value) {
          for (var element in value.docs) {
            element.reference.update({
              'allowed_modules': FieldValue.arrayRemove([moduleId]),
            });
          }
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateInvitationCardDateTime(String eventPlace, DateTime eventTime) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: "invitation").get().then((value) {
        for (var element in value.docs) {
          element.reference.update({'event_place': eventPlace, 'event_time': eventTime});
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateInvitationCardAddress(String eventAddress) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: "invitation").get().then((value) {
        for (var element in value.docs) {
          element.reference.update({'event_address': eventAddress});
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateInvitationCard({required InvitationModule updatedInvitation}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: "invitation").get().then((value) {
        for (var element in value.docs) {
          element.reference.update({});
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addPicturesInsideAlbumModule(String pictureName) async {
    try {
      var albumPhotoModule = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: 'album_photo').get();
      for (var element in albumPhotoModule.docs) {
        element.reference.update({
          'pictures': FieldValue.arrayUnion([pictureName]),
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAlbum(moduleId, eventId) {
    return configuration.getCollectionPath('events').doc(eventId).collection('modules').doc(moduleId).snapshots();
  }

  Future<void> deletePictureInsideAlbumModule(String pictureName) async {
    try {
      var albumPhotoModule = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: 'album_photo').get();
      for (var element in albumPhotoModule.docs) {
        element.reference.update({
          'pictures': FieldValue.arrayRemove([pictureName]),
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createModule(String type, BuildContext context, String eventId) async {
    final excludedModules = kNonEventModules;

    final docRef =
        await (() async {
          switch (type) {
            case 'album_photo':
              return createAlbumPhoto(eventId);
            case 'event':
              return createCustom(eventId, "Nouvel événement");

            case 'tables':
              return createTable(eventId);

            case 'invitation':
              return createInvitation(eventId);
            case 'media':
              return createMedia(eventId);
            case 'wedding':
              return createWedding(eventId);
            case 'cagnotte':
              return createCagnotte("Lien externe", eventId);
            case 'golden_book':
              return createGoldenBook(eventId);
            case 'menu':
              return createMenu(eventId);
            case 'about':
              return createAbout(eventId);
            case 'text':
              return createText(eventId);
            default:
              return null;
          }
        })();

    if (docRef == null) return;

    final moduleId = docRef.id;

    if (Event.instance.fullResThemeUrl.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final int? darkColor1Value = prefs.getInt('${Event.instance.id}_darkColor1');
      final int? darkColor2Value = prefs.getInt('${Event.instance.id}_darkColor2');

      if (darkColor1Value != null && darkColor2Value != null) {
        final Color darkColor1 = Color(darkColor1Value);
        final Color darkColor2 = Color(darkColor2Value);

        // Nombre de modules
        final numModules = Event.instance.modules.length;

        Color selectedColor = darkColor1;

        int numRow = numModules ~/ 2;

        if (numModules % 2 == 0) {
          selectedColor = numRow % 2 == 0 ? darkColor1 : darkColor2;
        } else {
          selectedColor = numRow % 2 == 0 ? darkColor2 : darkColor1;
        }

        // Mettre à jour le champ colorFilter du module créé
        await context.read<ModulesController>().updateModuleField(key: 'color_filter', value: selectedColor.withValues(alpha: 0.6).toARGB32().toRadixString(16).padLeft(8, '0'), moduleId: moduleId);
      }
    }

    final guests = Event.instance.guests;

    final tasks = <Future<void>>[];

    for (final guest in guests) {
      context.read<GuestsController>().allowModule(guest.id, moduleId);
      Event.instance.guests.firstWhere((element) => element.id == guest.id).allowedModules.add(moduleId);
    }

    if (!excludedModules.contains(type)) {
      for (final guest in guests) {
        final newRsvp = RSVP(guestId: guest.id, moduleId: moduleId, adults: [AddedGuest(id: generateRandomId(), name: guest.name)], children: [], isAllowed: true, response: 'En attente', createdAt: DateTime.now(), isAnswered: false);

        tasks.add(context.read<RSVPController>().addRSVP(newRsvp));
      }
    }

    Event.instance.modulesOrder.add(moduleId);
    tasks.add(
      configuration.getCollectionPath('events').doc(eventId).update({
        'modules_order': FieldValue.arrayUnion([moduleId]),
      }),
    );

    await Future.wait(tasks).then((value) => notifyListeners());
  }

  Future<DocumentReference<Map<String, dynamic>>> _addModule(Map<String, dynamic> moduleData, String eventId) async {
    return await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(moduleData);
  }

  Future<DocumentReference<Map<String, dynamic>>> createMenu(String eventId) async {
    return await _addModule(module_data.menuModule(Event.instance.womanFirstName, Event.instance.manFirstName, Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createWedding(String eventId) async {
    return await _addModule(module_data.weddingModule(Event.instance.eventType, Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createGoldenBook(String eventId) async {
    return await _addModule(module_data.goldenBookModule(Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createCagnotte(String moduleName, String eventId) async {
    return await _addModule(module_data.cagnotteModule(moduleName, Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createInvitation(String eventId) async {
    String getIntroduction() {
      switch (Event.instance.eventType) {
        case 'mariage':
          return "Ont l'immense joie de vous faire part de leur mariage et seront très honorés de votre présence le";
        case 'anniversaire':
          return "Nous avons le plaisir de vous inviter à fêter cet anniversaire spécial avec nous le";
        case 'gala':
          return "Joignez-vous à nous pour ce gala exceptionnel le";
        case 'entreprise':
          return "Nous sommes ravis de vous accueillir à cet événement d'entreprise le";
        case 'bar mitsvah':
          return "C'est avec grande joie que nous vous invitons à célébrer cette Bar Mitzvah le";
        case 'salon':
          return "Soyez les bienvenus à ce salon professionnel le";
        case 'soirée':
          return "Préparez-vous pour une soirée inoubliable le";
        default:
          return "Nous sommes heureux de vous inviter à cet événement spécial le";
      }
    }

    String getConclusion() {
      switch (Event.instance.eventType) {
        case 'mariage':
          return "À l’issue de la cérémonie suivra la réception.";
        case 'anniversaire':
          return "Nous partagerons ensuite un moment convivial pour célébrer cette occasion.";
        case 'gala':
          return "La soirée sera suivie d'une réception prestigieuse.";
        case 'entreprise':
          return "Nous terminerons avec un réseautage convivial.";
        case 'bar mitsvah':
          return "Nous aurons ensuite une réception pour marquer ce moment.";
        case 'salon':
          return "Nous conclurons par un échange ouvert entre les participants.";
        case 'soirée':
          return "La fête continuera tard dans la nuit.";
        default:
          return "Nous espérons que vous apprécierez cet événement unique.";
      }
    }

    return await _addModule(module_data.invitationCardModule(Event.instance.womanFirstName, Event.instance.manFirstName, getIntroduction(), getConclusion(), Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createCustom(String eventId, String moduleName) async {
    return await _addModule(module_data.eventModule(Event.instance.eventType, moduleName), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createAlbumPhoto(String eventId) async {
    return await _addModule(module_data.albumModule(Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createText(String eventId) async {
    return await _addModule(module_data.textModule(Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createMairie(String eventId) async {
    return await _addModule(module_data.mairieModule(Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createTable(String eventId) async {
    return await _addModule(module_data.tableModule(Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createMedia(String eventId) async {
    return await _addModule(module_data.mediaModule("Document", Event.instance.eventType), eventId);
  }

  Future<DocumentReference<Map<String, dynamic>>> createAbout(String eventId) async {
    return await _addModule(module_data.aboutModule(Event.instance.eventType), eventId);
  }

  Future<void> updateModuleField({required String key, required String value, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({key: value});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateFieldForAllModules({required String key, required String value}) async {
    try {
      var modules = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').get();

      for (var module in modules.docs) {
        await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(module.id).update({key: value});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> isEventTypeMatching(String moduleId, String eventType) async {
    try {
      // Récupérer le module à partir de l'ID
      DocumentSnapshot moduleSnapshot = await FirebaseFirestore.instance.collection("events").doc(Event.instance.id).collection('modules').doc(moduleId).get();

      if (moduleSnapshot.exists) {
        // Vérifier si le champ 'event_type' correspond
        final data = moduleSnapshot.data() as Map<String, dynamic>;
        return data['event_type'] == eventType;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
