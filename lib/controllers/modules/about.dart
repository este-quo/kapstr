import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/about.dart';
import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/themes/constants.dart';

class AboutController extends ChangeNotifier {
  Future<AboutModule?> getAboutById(String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> aboutModuleDoc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(id).get();

      if (aboutModuleDoc.exists && aboutModuleDoc.data() != null) {
        // Convert the document to an AboutModule object
        AboutModule aboutModule = AboutModule.fromMap(aboutModuleDoc.id, aboutModuleDoc.data()!);

        // Fetch services subcollection for this AboutModule
        final servicesSnapshot = await aboutModuleDoc.reference.collection('services').get();
        List<AboutService> services = servicesSnapshot.docs.map((doc) => AboutService.fromMap(doc.id, doc.data())).toList();

        aboutModule.setServices(services);

        printOnDebug("About module fetched: $aboutModule");

        return aboutModule;
      }
      return null;
    } catch (e) {
      print("Error fetching about module: $e"); // It's better to handle exceptions or log them accordingly
      throw Exception("Failed to fetch about module");
    }
  }

  Future<AboutService?> createAboutService(String moduleId) async {
    String getNameOfCategory() {
      switch (Event.instance.eventType) {
        case 'soirée':
          return 'Nouvelle offre';
        case 'gala':
          return 'Nouvelle action';
        default:
          return 'Nouveau service';
      }
    }

    try {
      final DocumentReference<Map<String, dynamic>> newServiceRef = configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('services').doc();

      final AboutService newService = AboutService(
        id: newServiceRef.id,
        name: "${getNameOfCategory()}",
        imageUrl: "https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        description: "",
        imageUrls: [],
      );

      await newServiceRef.set(newService.toMap());

      return newService;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateModuleLogo({required String newLogo, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({'logo_url': newLogo});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateAboutServiceFields({required Map<String, dynamic> fields, required String serviceId, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('services').doc(serviceId).update(fields);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateAboutServiceImage({required String newImage, required String serviceId, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('services').doc(serviceId).update({'image_url': newImage});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateAboutServiceImagesList({required String newImage, required String serviceId, required String moduleId}) async {
    try {
      final DocumentReference<Map<String, dynamic>> serviceRef = configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('services').doc(serviceId);

      final DocumentSnapshot<Map<String, dynamic>> serviceDoc = await serviceRef.get();

      if (serviceDoc.exists && serviceDoc.data() != null) {
        final List<String> imageUrls = List<String>.from(serviceDoc.data()!['image_urls'] ?? []);
        imageUrls.add(newImage);

        await serviceRef.update({'image_urls': imageUrls});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateAboutField({required String key, required String value, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update({key: value});
    } catch (e) {
      throw Exception(e);
    }
  }

  // update fields from a field map
  Future<void> updateAboutFields({required Map<String, dynamic> fields, required String moduleId}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).update(fields);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteAboutService(String serviceId, String moduleId) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('services').doc(serviceId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateAboutModuleInfos(AboutModule newAboutModule) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(newAboutModule.id).update(newAboutModule.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }
}
