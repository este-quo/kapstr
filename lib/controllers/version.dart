import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/services/api/api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionProvider with ChangeNotifier {
  String? currentVersion;
  String? minVersion;
  String? optionalVersion;
  bool isUpdateMandatory = false;
  bool isOptionalUpdateAvailable = false;

  // Méthode pour initialiser la version
  Future<void> initVersion() async {
    try {
      // Récupérer la version installée
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      currentVersion = Api().version;

      // Récupérer les informations depuis Firestore
      DocumentSnapshot configSnapshot = await FirebaseFirestore.instance.collection('configurations').doc('config').get();

      minVersion = configSnapshot['min_version'];

      // Comparer les versions
      isUpdateMandatory = _isVersionOutdated(currentVersion!, minVersion!);
      isOptionalUpdateAvailable = optionalVersion != null && _isVersionOutdated(currentVersion!, optionalVersion!);

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation des versions : $e");
    }
  }

  // Comparer deux versions
  bool _isVersionOutdated(String currentVersion, String targetVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> targetParts = targetVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < targetParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < targetParts[i]) {
        return true;
      } else if (currentParts[i] > targetParts[i]) {
        return false;
      }
    }
    return false;
  }

  // Afficher un dialog si une mise à jour est nécessaire
  Future<void> showUpdateDialogIfNeeded(BuildContext context) async {
    if (isUpdateMandatory) {
      _showUpdateDialog(context, true);
    } else if (isOptionalUpdateAvailable) {
      _showUpdateDialog(context, false);
    }
  }

  // Afficher le dialog de mise à jour
  void _showUpdateDialog(BuildContext context, bool isMandatory) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory, // Non dismissible si obligatoire
      builder: (context) {
        return AlertDialog(
          title: Text(isMandatory ? "Mise à jour requise" : "Mise à jour disponible"),
          content: Text(isMandatory ? "Une nouvelle version de l'application est disponible. Veuillez la mettre à jour pour continuer." : "Une nouvelle version est disponible avec des améliorations. Souhaitez-vous mettre à jour maintenant ?"),
          actions: [
            if (!isMandatory)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Plus tard"),
              ),
            TextButton(
              onPressed: () {
                _openAppStore();
              },
              child: const Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }

  // Ouvrir le store
  void _openAppStore() {
    const appStoreUrl = "https://play.google.com/store/apps/details?id=com.example.app"; // Remplacez par votre URL
    launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
  }
}
