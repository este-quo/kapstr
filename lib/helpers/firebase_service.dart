import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kapstr/configuration/firebase_options.dart';
import 'package:kapstr/helpers/debug_helper.dart';

class FirebaseHelper {
  static Future<void> setupFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    printOnDebug('onBackgroundMessage: $message');
  }

  static Future<bool> sendNotification({required String title, required String body, required String token, String? image}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');

    try {
      final response = await callable.call(<String, dynamic>{'title': title, 'body': body, 'image': image, 'token': token});

      if (response.data == null) return false;
      return false;
    } catch (e) {
      printOnDebug('Error while sending notification: $e');
      return false;
    }
  }
}
