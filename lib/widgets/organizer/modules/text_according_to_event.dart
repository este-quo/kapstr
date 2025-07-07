String optionsAccordingToEventType(String moduleType) {
  if (moduleType == "album_photo") {
    return "Voir l'album photo";
  }
  if (moduleType == "invitation") {
    return "Modifier la carte";
  }
  if (moduleType == "about") {
    return "Modifier à propos";
  }
  if (moduleType == "tables") {
    return "Modifier mes tables";
  }
  if (moduleType == "menu") {
    return "Modifier le menu";
  }
  if (moduleType == "golden_book") {
    return "Ouvrir le livre d'or";
  }
  if (moduleType == "media") {
    return "Modifier le média";
  }
  if (moduleType == "cagnotte") {
    return "Modifier le lien";
  }
  if (moduleType == "text") {
    return "Modifier le texte";
  }

  return "Voir en tant qu'invité";
}
