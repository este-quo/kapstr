String descriptionAccordingToEventType(String moduleType) {
  if (moduleType == "album_photo") {
    return "Créez votre album photos, visible pour les invités. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }
  if (moduleType == "invitation") {
    return "Créez votre carte d’invitation facilement. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  if (moduleType == "about") {
    return "Présentez-vous et votre événement. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }
  if (moduleType == "tables") {
    return "Créez vos listes de tables facilement. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }
  if (moduleType == "menu") {
    return "Créez votre menu facilement. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  if (moduleType == "golden_book") {
    return "Consultez ici les mots que les invités vous ont écris. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  if (moduleType == "media") {
    return "Ajoutez un document (carte pdf, fichier png, jpeg...). Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  if (moduleType == "cagnotte") {
    return "Créez un lien externe, en y ajoutant un url. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  if (moduleType == 'wedding' || moduleType == 'mairie' || moduleType == 'event') {
    return "Créez un nouvel évènement facilement. Personnalisez également le design du module (typo, couleurs, tailles...)";
  }

  return "Personnaliser votre module, en ajoutant les informations relatives à l’évènement. Personnalisez également le design du module (typo, couleurs, tailles...)";
}
