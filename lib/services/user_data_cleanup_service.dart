import 'package:flutter/material.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:provider/provider.dart';

/// Service centralisé pour nettoyer les données utilisateur
class UserDataCleanupService {
  /// Nettoie toutes les données utilisateur des contrôleurs
  static void clearAllUserData(BuildContext context) {
    try {
      // Nettoyage des contrôleurs liés à l'utilisateur
      context.read<UsersController>().clear();
      context.read<RSVPController>().clear();
      context.read<PlacesController>().clear();
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des données utilisateur: $e');
    }
  }

  /// Nettoie un contrôleur spécifique
  static void clearController<T extends ChangeNotifier>(BuildContext context, T controller) {
    try {
      if (controller is UsersController) {
        controller.clear();
      } else if (controller is RSVPController) {
        controller.clear();
      } else if (controller is PlacesController) {
        controller.clear();
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage du contrôleur $T: $e');
    }
  }
}
