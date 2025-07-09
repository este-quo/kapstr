import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/services/firebase/cloud_firestore/firestore_configuration.dart';

const _chars = 'ABCDEFGHIJKLMNOPQRSTUVXYZ1234567890';
Random _rnd = Random();

final FirestoreConfiguration _configuration = FirestoreConfiguration();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

/// Génère un code unique qui n'existe pas déjà en base de données
/// [length] - La longueur du code à générer (par défaut 5)
/// [maxAttempts] - Nombre maximum de tentatives (par défaut 10)
/// Retourne un code unique ou lance une exception si impossible à générer
Future<String> generateUniqueEventCode({int length = 5, int maxAttempts = 10}) async {
  printOnDebug('Début de génération d\'un code unique de $length caractères');
  
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    // Générer un nouveau code
    String newCode = getRandomString(length);
    printOnDebug('Tentative $attempt/$maxAttempts - Code généré: $newCode');
    
    try {
      // Vérifier si le code existe déjà en base de données
      QuerySnapshot existingEvents = await _configuration.getCollectionPath('events')
          .where('code', isEqualTo: newCode)
          .get();
      
      if (existingEvents.docs.isEmpty) {
        printOnDebug('Code unique trouvé: $newCode (après $attempt tentative(s))');
        return newCode;
      } else {
        printOnDebug('Code $newCode déjà existant (trouvé ${existingEvents.docs.length} occurrence(s))');
        // Continue la boucle pour générer un nouveau code
      }
    } catch (e) {
      printOnDebug('Erreur lors de la vérification du code $newCode: $e');
      // Continue la boucle pour réessayer
    }
  }
  
  // Si on arrive ici, on n'a pas réussi à générer un code unique
  String errorMessage = 'Impossible de générer un code unique après $maxAttempts tentatives';
  printOnDebug(errorMessage);
  throw Exception(errorMessage);
}
