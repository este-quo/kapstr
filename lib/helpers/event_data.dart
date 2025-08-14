import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/helpers/debug_helper.dart';

import 'package:kapstr/services/firebase/paid_modules/add_paid_modules.dart' as paid_modules_firestore;

Future<void> generateModulesFromEventType(String eventId, String eventType, EventDataController onboardingData) async {
  printOnDebug("Generating modules for event type: $eventType");
  printOnDebug('Man name: ${onboardingData.manFirstName}');
  printOnDebug('Woman name: ${onboardingData.womanFirstName}');

  switch (eventType) {
    case 'mariage':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, "Mariage", eventType);
      await paid_modules_firestore.addMairieToEvent(eventId, eventType);
      // Et enfin, le golden book
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Ont l'immense joie de vous faire part de leur mariage et seront très honorés de votre présence le", "À l’issue de la cérémonie suivra la réception.", eventType);
      // Puis l'invitation card
      await paid_modules_firestore.addGoldenBookToEvent(eventId, eventType);
      break;

    case 'gala':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, 'Le gala', eventType);
      await paid_modules_firestore.addAboutToEvent(eventId, eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Joignez-vous à nous pour ce gala exceptionnel le", "La soirée sera suivie d'une réception prestigieuse.", eventType);
      await paid_modules_firestore.addCagnotteToEvent(eventId, "Faire un don", eventType);
      break;

    case 'entreprise':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, "L'événement", eventType);
      await paid_modules_firestore.addAboutToEvent(eventId, eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Nous sommes ravis de vous accueillir à cet événement d'entreprise le", "Nous terminerons avec un réseautage convivial.", eventType);
      await paid_modules_firestore.addAlbumPhotoToEvent(eventId, eventType);
      break;

    case 'anniversaire':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, "Anniversaire", eventType);
      await paid_modules_firestore.addInvitationCardToEvent(
        eventId,
        onboardingData.manFirstName,
        onboardingData.womanFirstName,
        "Nous avons le plaisir de vous inviter à fêter cet anniversaire spécial avec nous le",
        "Nous partagerons ensuite un moment convivial pour célébrer cette occasion.",
        eventType,
      );
      await paid_modules_firestore.addCagnotteToEvent(eventId, "Lien externe", eventType);
      await paid_modules_firestore.addGoldenBookToEvent(eventId, eventType);
      break;

    case 'bar mitsvah':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, "La soirée", eventType);
      await paid_modules_firestore.addCustomEventToEvent(eventId, "Mise des tefilines", eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "C'est avec grande joie que nous vous invitons à célébrer cette Bar Mitzvah le", "Nous aurons ensuite une réception pour marquer ce moment.", eventType);
      await paid_modules_firestore.addGoldenBookToEvent(eventId, eventType);
      break;

    case 'soirée':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, 'La soirée', eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Préparez-vous pour une soirée inoubliable le", "La fête continuera tard dans la nuit.", eventType);
      await paid_modules_firestore.addMediaModule(eventId, "Flyer", eventType);
      await paid_modules_firestore.addAlbumPhotoToEvent(eventId, eventType);
      break;

    case 'salon':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, "Le salon", eventType);
      await paid_modules_firestore.addAlbumPhotoToEvent(eventId, eventType);
      await paid_modules_firestore.addAboutToEvent(eventId, eventType);
      await paid_modules_firestore.addCagnotteToEvent(eventId, "Billeterie", eventType);
      break;

    case 'autre':
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, 'L\'événement', eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Nous sommes heureux de vous inviter à cet événement spécial le", "Nous espérons que vous apprécierez cet événement unique.", eventType);
      await paid_modules_firestore.addAboutToEvent(eventId, eventType);
      await paid_modules_firestore.addAlbumPhotoToEvent(eventId, eventType);

      break;

    default:
      await paid_modules_firestore.addModuleWeddingToEvent(eventId, eventType, eventType);
      await paid_modules_firestore.addInvitationCardToEvent(eventId, onboardingData.manFirstName, onboardingData.womanFirstName, "Nous sommes heureux de vous inviter à cet événement spécial le", "Nous espérons que vous apprécierez cet événement unique.", eventType);
      await paid_modules_firestore.addAboutToEvent(eventId, eventType);
      await paid_modules_firestore.addMediaModule(eventId, 'Flyer', eventType);

      break;
  }
}
