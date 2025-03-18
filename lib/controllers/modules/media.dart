import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/media.dart';
import 'package:kapstr/themes/constants.dart';

class MediaController extends ChangeNotifier {
  Future<MediaModule> getMediaById(String id) async {
    try {
      return await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(id).get().then((doc) {
        return MediaModule.fromMap(id, doc.data()!);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateMediaModule(MediaModule newMediaModule) async {
    try {
      configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(newMediaModule.id).update(newMediaModule.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
