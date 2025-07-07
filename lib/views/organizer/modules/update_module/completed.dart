import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/modules/module.dart';

Text areInfosCompleted(Module module, BuildContext context) {
  if (module.type == "album_photo") return const Text("");
  if (module.type == "tables") return const Text("");
  if (module.type == "invitation") return const Text("");
  if (module.type == "cagnotte") return const Text("");
  if (module.type == "golden_book") return const Text("");
  if (module.type == "menu") return const Text("");

  if (module.date == null || module.placeName == "Nom du lieu" || module.placeAddress == 'Adresse du lieu' || module.moreInfos == 'Plus d\'informations') {
    return const Text("À compléter", style: TextStyle(color: kDanger, fontWeight: FontWeight.w400, fontSize: 14));
  } else {
    return const Text("Complet", style: TextStyle(color: kSuccess, fontWeight: FontWeight.w400, fontSize: 14));
  }
}
