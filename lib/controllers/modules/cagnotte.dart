import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/cagnotte.dart';
import 'package:kapstr/themes/constants.dart';

class CagnotteController extends ChangeNotifier {
  CagnotteModule? _cagnotteModule;

  CagnotteModule? get cagnotteModule => _cagnotteModule;

  set cagnotteModule(CagnotteModule? cagnotteModule) {
    _cagnotteModule = cagnotteModule;
    notifyListeners();
  }

  Future<void> updateCagnotteModule(CagnotteModule newCagnotteModule) async {
    _cagnotteModule = newCagnotteModule;
    notifyListeners();
  }

  Future<CagnotteModule> getCagnotteById(String id) async {
    try {
      return await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(id).get().then((doc) {
        return CagnotteModule.fromMap(id, doc.data()!);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addLinkToCagnotte(String link, String moduleId) async {
    try {
      configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'cagnotte_url': link});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> getCagnotteUrl(String moduleId) {
    try {
      return configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).get().then((doc) {
        return doc.data()!['cagnotte_url'];
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
