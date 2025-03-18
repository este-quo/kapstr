import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/capitalize.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/modules/invitation.dart';
import 'package:kapstr/themes/constants.dart';

class InvitationsController extends ChangeNotifier {
  InvitationModule currentInvitation = InvitationModule(
    id: "",
    allowGuest: false,
    colorFilter: "",
    image: "",
    isEvent: false,
    moreInfos: "",
    name: "",
    textSize: 0,
    textColor: "",
    type: "",
    fontType: "",
    title: "",
    titleStyle: {},
    initials: "",
    initialsStyle: {},
    introduction: "",
    introductionStyle: {},
    conclusion: "",
    conclusionStyle: {},
    contact1: "",
    contact1Style: {},
    contact2: "",
    contact2Style: {},
    names: "",
    namesStyles: {},
    partyDateRecto: "",
    partyDateRectoStyle: {},
    partyDateVerso: "",
    partyDateVersoStyle: {},
    partyPlaceAdress: "",
    partyPlaceAdressStyle: {},
    partyPlaceName: "",
    partyPlaceNameStyle: {},
    partyLinking: "",
    partyLinkingStyle: {},
  );

  Future<void> getInvitationById() async {
    try {
      DocumentSnapshot doc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').where('type', isEqualTo: 'invitation').get().then((value) => value.docs.first);

      if (doc.exists) {
        currentInvitation = InvitationModule.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        printOnDebug("Invitation fetched: ${currentInvitation.name}");
        notifyListeners();
      } else {
        printOnDebug("Invitation not found");
      }
    } catch (e) {
      printOnDebug("Error fetching invitation: $e");
    }
  }

  Future<void> updateInvitation(InvitationModule invitation) async {
    printOnDebug("Trying to update : ${currentInvitation.name}");

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(invitation.id).update(invitation.toMap());
      currentInvitation = invitation; // Update the currentInvitation
      printOnDebug("Invitation updated: ${currentInvitation.name}");
      notifyListeners(); // Notify listeners about the update
    } catch (e) {
      printOnDebug("Error updating invitation: $e");
    }
  }

  Future<void> updateStyleMap(String styleKey, Map<String, dynamic> newStyle) async {
    // Check which style map to update and update it
    switch (styleKey) {
      case 'initialsStyle':
        currentInvitation.initialsStyle = newStyle;
        break;
      case 'titleStyle':
        currentInvitation.titleStyle = newStyle;
        break;
      case 'introductionStyle':
        currentInvitation.introductionStyle = newStyle;
        break;
      case 'conclusionStyle':
        currentInvitation.conclusionStyle = newStyle;
        break;
      case 'contact1Style':
        currentInvitation.contact1Style = newStyle;
        break;
      case 'contact2Style':
        currentInvitation.contact2Style = newStyle;
        break;
      case 'namesStyles':
        currentInvitation.namesStyles = newStyle;
        break;
      case 'partyDateRectoStyle':
        currentInvitation.partyDateRectoStyle = newStyle;
        break;
      case 'partyDateVersoStyle':
        currentInvitation.partyDateVersoStyle = newStyle;
        break;
      case 'partyPlaceAdressStyle':
        currentInvitation.partyPlaceAdressStyle = newStyle;
        break;
      case 'partyPlaceNameStyle':
        currentInvitation.partyPlaceNameStyle = newStyle;
        break;
      case 'partyLinkingStyle':
        currentInvitation.partyLinkingStyle = newStyle;
        break;
      default:
        printOnDebug("Invalid style key: $styleKey");
        return;
    }
    notifyListeners();

    // Update the invitation in Firestore and notify listeners
    try {
      await updateInvitation(currentInvitation);
      printOnDebug("Style updated for key: $styleKey");
    } catch (e) {
      printOnDebug("Error updating style: $e");
    }
    notifyListeners();
  }

  Future<void> resetInvitation() async {
    String getIntroduction() {
      switch (Event.instance.eventType) {
        case 'mariage':
          return "Ont l'immense joie de vous faire part de leur mariage et seront très honorés de votre présence le";
        case 'anniversaire':
          return "Nous avons le plaisir de vous inviter à fêter cet anniversaire spécial avec nous le";
        case 'gala':
          return "Joignez-vous à nous pour ce gala exceptionnel le";
        case 'entreprise':
          return "Nous sommes ravis de vous accueillir à cet événement d'entreprise le";
        case 'bar mitsvah':
          return "C'est avec grande joie que nous vous invitons à célébrer cette Bar Mitzvah le";
        case 'salon':
          return "Soyez les bienvenus à ce salon professionnel le";
        case 'soirée':
          return "Préparez-vous pour une soirée inoubliable le";
        default:
          return "Nous sommes heureux de vous inviter à cet événement spécial le";
      }
    }

    String getConclusion() {
      switch (Event.instance.eventType) {
        case 'mariage':
          return "À l’issue de la cérémonie suivra la réception.";
        case 'anniversaire':
          return "Nous partagerons ensuite un moment convivial pour célébrer cette occasion.";
        case 'gala':
          return "La soirée sera suivie d'une réception prestigieuse.";
        case 'entreprise':
          return "Nous terminerons avec un réseautage convivial.";
        case 'bar mitsvah':
          return "Nous aurons ensuite une réception pour marquer ce moment.";
        case 'salon':
          return "Nous conclurons par un échange ouvert entre les participants.";
        case 'soirée':
          return "La fête continuera tard dans la nuit.";
        default:
          return "Nous espérons que vous apprécierez cet événement unique.";
      }
    }

    print("wowow ?");

    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(currentInvitation.id).update({
        'initials': Event.instance.womanFirstName == '' ? capitalize(Event.instance.manFirstName[0]) : "${capitalize(Event.instance.manFirstName[0])} & ${capitalize(Event.instance.womanFirstName[0])}",
        'initials_style': {'fontFamily': 'Great Vibes', 'fontSize': 24, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'title': Event.instance.womanFirstName == '' ? capitalize(Event.instance.manFirstName) : "${capitalize(Event.instance.manFirstName)} & ${capitalize(Event.instance.womanFirstName)}",
        'title_style': {'fontFamily': 'Great Vibes', 'fontSize': 48, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'names': Event.instance.womanFirstName == '' ? capitalize(Event.instance.manFirstName) : "${capitalize(Event.instance.manFirstName)} & ${capitalize(Event.instance.womanFirstName)}",
        'party_date_recto': '',
        'party_date_verso': '',
        'party_place_adresse': '',
        'party_place_name': '',
        'introduction': getIntroduction(),
        'introduction_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'conclusion': getConclusion(),
        'conclusion_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'contact_1': '${capitalize(Event.instance.manFirstName)} : ${capitalize(AppOrganizer.instance.phone)}',
        'contact_1_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'contact_2': '${capitalize(Event.instance.womanFirstName)} : ${capitalize(AppOrganizer.instance.phone)}',
        'contact_2_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'names_styles': {'fontFamily': 'Great Vibes', 'fontSize': 32, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'party_date_recto_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'party_date_verso_style': {'fontFamily': 'Great Vibes', 'fontSize': 30, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'party_place_adress_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'party_place_name_style': {'fontFamily': 'Great Vibes', 'fontSize': 26, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
        'party_linking': 'au',
        'party_linking_style': {'fontFamily': 'Great Vibes', 'fontSize': 24, 'is_bold': false, 'align': 'center', 'color': '000000', 'is_italic': false, 'is_underlined': false},
      });

      await getInvitationById();

      printOnDebug("Invitation reset");
      notifyListeners();
    } catch (e) {
      printOnDebug("Error resetting invitation: $e");
    }
  }
}
