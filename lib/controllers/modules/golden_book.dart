import 'package:flutter/material.dart';
import 'package:kapstr/models/modules/golden_book_message.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/user.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';

class GoldenBookController extends ChangeNotifier {
  Future<void> sendMessage(String moduleId, String message, String guestId) async {
    try {
      var collection = configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('messages');

      var existingMessage = await collection.where('guest_id', isEqualTo: guestId).get();

      if (existingMessage.docs.isNotEmpty) {
        // Mise à jour du message existant
        var docId = existingMessage.docs.first.id;
        await collection.doc(docId).update({'message': message, 'date': DateTime.now()});
      } else {
        // Ajout d'un nouveau message
        await collection.add({'guest_id': guestId, 'message': message, 'date': DateTime.now()});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<GoldenBookMessage>> getMessages(String moduleId) async {
    List<GoldenBookMessage> messages = [];
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('messages').get().then((value) {
        for (var element in value.docs) {
          messages.add(GoldenBookMessage.fromMap(element.data()));
        }
      });

      return messages;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Guest> getGuestFromMessages(String moduleId, GoldenBookMessage message) async {
    Guest guest = Guest(userId: '', id: '', name: '', hasJoined: false, imageUrl: "", phone: "", postedPictures: [], tableId: "", isSelected: false, allowedModules: []);

    try {
      // Fetch the guest document
      var guestDoc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(message.guestId).get();
      if (guestDoc.exists) {
        guest = Guest.fromMap(guestDoc.data()!, guestDoc.id);

        // If the guest has joined, fetch their user details
        if (guest.hasJoined && guest.userId.isNotEmpty) {
          // Assuming getUserDetails is a function that fetches user details by userId
          var user = await getUserDetails(guest.userId);
          if (user != null) {
            // Update guest object with user details
            guest.name = user.name;
            guest.imageUrl = user.imageUrl;
            guest.phone = user.phone;
            // Additional user fields can be updated here if needed
          }
        }
      }

      return guest;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'invité : $e');
    }
  }

  // This assumes you have a similar function as described previously
  Future<User?> getUserDetails(String userId) async {
    // Fetch user details by userId
    var userDoc = await configuration.getCollectionPath('users').doc(userId).get();
    if (userDoc.exists) {
      return User.fromMap(userDoc.data()! as Map<String, dynamic>, userDoc.id);
    }
    return null;
  }

  Future<GoldenBookMessage> getGuestMessage(String moduleId, String guestId) async {
    try {
      var querySnapshot = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).collection('messages').where('guest_id', isEqualTo: guestId).get();

      // Vérifiez si la requête a retourné des documents
      if (querySnapshot.docs.isNotEmpty) {
        // Il y a des documents, donc récupérez le premier
        return GoldenBookMessage.fromMap(querySnapshot.docs.first.data());
      } else {
        // Aucun document trouvé, retournez un message par défaut ou vide
        return GoldenBookMessage("", "", DateTime.now());
      }
    } catch (e) {
      // Gérez ou propagez l'exception comme vous le jugez nécessaire
      throw Exception(e);
    }
  }
}
