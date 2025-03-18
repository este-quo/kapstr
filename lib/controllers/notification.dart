import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/notification.dart';
import 'package:kapstr/themes/constants.dart';

class NotificationController extends ChangeNotifier {
  bool _isNotificationEnabled = true;
  String target = 'organizer';
  List<MyNotification> organizerNotifications = [];
  List<MyNotification> guestNotifications = [];

  CollectionReference get notificationCollection => configuration.getCollectionPath('events').doc(Event.instance.id).collection('notifications');

  bool get isNotificationEnabled => _isNotificationEnabled;

  void toggleNotification() {
    _isNotificationEnabled = !_isNotificationEnabled;
    notifyListeners();
  }

  void setNotification(bool value) {
    _isNotificationEnabled = value;
    notifyListeners();
  }

  void reset() {
    _isNotificationEnabled = true;
    notifyListeners();
  }

  Future<void> fetchOrganizerNotifications() async {
    organizerNotifications.clear();
    guestNotifications.clear();
    target = 'organizer';

    QuerySnapshot querySnapshot = await notificationCollection.where('target', isEqualTo: target).get();

    organizerNotifications = querySnapshot.docs.map((doc) => MyNotification.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList();
    // sort by date
    organizerNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> fetchGuestNotifications() async {
    guestNotifications.clear();
    organizerNotifications.clear();
    target = 'guest';
    QuerySnapshot querySnapshot = await notificationCollection.where('target', isEqualTo: target).get();

    guestNotifications = querySnapshot.docs.map((doc) => MyNotification.fromMap(doc.id, doc.data()! as Map<String, dynamic>)).toList();
    // sort by date
    guestNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addOrganizerNotification({required String title, required String body, String? image, required String type}) async {
    // Create a new notification in Firestore
    DocumentReference docRef = await notificationCollection.add({'title': title, 'body': body, 'image': image ?? '', 'target': 'organizer', 'type': type, 'seen_by': [], 'createdAt': FieldValue.serverTimestamp()});

    // Retrieve the newly created notification
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      MyNotification newNotification = MyNotification.fromMap(docSnapshot.id, data);

      // Add to local list and notify listeners
      organizerNotifications.add(newNotification);
      // Sort by date
      organizerNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> addUserNotification({required String userId, required String title, required String body, String? image, required String type, String target = 'user'}) async {
    // Create a new notification in Firestore
    DocumentReference docRef = await notificationCollection.add({'userId': userId, 'title': title, 'body': body, 'image': image ?? '', 'target': target, 'type': type, 'seen_by': [], 'createdAt': FieldValue.serverTimestamp()});

    // Retrieve the newly created notification
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      MyNotification newNotification = MyNotification.fromMap(docSnapshot.id, data);

      // Add to local list and notify listeners
      organizerNotifications.add(newNotification);
      // Sort by date
      organizerNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> addGuestNotification({required String title, required String body, String? image, required String type}) async {
    // Create a new notification in Firestore
    DocumentReference docRef = await notificationCollection.add({'title': title, 'body': body, 'image': image ?? '', 'target': 'guest', 'type': type, 'seen_by': [], 'createdAt': FieldValue.serverTimestamp()});

    // Retrieve the newly created notification
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      MyNotification newNotification = MyNotification.fromMap(docSnapshot.id, data);

      // Add to local list and notify listeners
      guestNotifications.add(newNotification);
      // Sort by date
      guestNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> removeOrganizerNotification(String id) async {
    // Remove from Firestore
    await notificationCollection.doc(id).delete();

    // Remove from local list and notify listeners
    organizerNotifications.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> removeGuestNotification(String id) async {
    // Remove from Firestore
    await notificationCollection.doc(id).delete();

    // Remove from local list and notify listeners
    guestNotifications.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> addUserIdToSeenBy() async {
    String id = target == 'guest' ? AppGuest.instance.id : AppOrganizer.instance.id;

    printOnDebug('Adding user id to seenBy array$id');

    if (target == 'guest') {
      printOnDebug('guest');

      for (MyNotification notification in guestNotifications) {
        if (!notification.seenBy.contains(id)) {
          printOnDebug('for et if');

          notification.seenBy.add(id);

          // print notification.seenBy
          printOnDebug('Adding user id to seenBy array ${notification.seenBy}');
          await notificationCollection.doc(notification.id).update({'seen_by': notification.seenBy});
        }
      }
    } else if (target == 'organizer') {
      printOnDebug('organizer${organizerNotifications.length}');
      for (MyNotification notification in organizerNotifications) {
        printOnDebug('for et if');

        if (!notification.seenBy.contains(id)) {
          printOnDebug('for et if');

          notification.seenBy.add(id);
          printOnDebug('Adding user id to seenBy array ${notification.seenBy}');

          await notificationCollection.doc(notification.id).update({'seen_by': notification.seenBy});
        }
      }
    }
  }
}
