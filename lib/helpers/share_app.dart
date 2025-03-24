import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/organizer/message_editor_dialog.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> shareApp() async {
  Share.share('Découvrez Kapstr l’application qui vous génère le faire-part de votre événement, en quelques clics. 🎉\n\n Essayez la gratuitement \n\n Kapstr.com/download', subject: 'Planifiez Votre Jour J à la Perfection!');
}

Future<void> shareEvent(BuildContext context) async {
  String eventType = Event.instance.eventType;
  String eventMessage = getEventMessage(eventType);

  // Afficher la boîte de dialogue pour éditer le message
  final editedMessage = await showDialog<String>(context: context, builder: (context) => MessageEditorDialog(initialMessage: eventMessage));
  if (editedMessage != null && editedMessage.isNotEmpty) {
    Share.share(editedMessage, subject: 'Rejoignez mon événement sur Kapstr grâce au code ${Event.instance.code}.');
  } else {
    // L'utilisateur a annulé ou laissé le message vide
    printOnDebug('L\'envoi du message a été annulé.');
  }
}

Future<void> sendSMS(List<String> recipients, String message) async {
  // Combine les numéros de téléphone avec des virgules
  final String recipientsString = recipients.join(';');

  String formattedMessage = message.replaceAll('\n', '%0A');

  final Uri uri = Uri(scheme: 'sms', path: recipientsString, query: 'body=$formattedMessage');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<void> sendSMSToGuests(BuildContext context, List<String> recipients) async {
  String eventType = Event.instance.eventType;
  String eventMessage = getEventMessage(eventType);

  // Afficher la boîte de dialogue pour éditer le message
  final editedMessage = await showDialog<String>(context: context, builder: (context) => MessageEditorDialog(initialMessage: eventMessage));

  if (editedMessage != null && editedMessage.isNotEmpty) {
    // Envoyer le message modifié
    await sendSMS(recipients, editedMessage);
  } else {
    // L'utilisateur a annulé ou laissé le message vide
    printOnDebug('L\'envoi du message a été annulé.');
  }
}

String getEventMessage(String eventType) {
  String code = Event.instance.code;
  String downloadLink = "https://kapstr.fr/download";
  DateTime date = Event.instance.date!;

  var formatter = DateFormat('d MMMM y', 'fr_FR');
  String formattedDate = formatter.format(date);
  String brideName = Event.instance.womanFirstName; // Remplacez par le vrai nom de la mariée
  String groomName = Event.instance.manFirstName; // Remplacez par le vrai nom du marié
  String partyName = Event.instance.modules.where((module) => module.type == 'wedding').first.name; // Remplacez par le vrai nom de la soirée
  String birthdayPersonName = Event.instance.manFirstName; // Remplacez par le vrai nom de la personne
  String barMitsvahName = Event.instance.manFirstName;

  switch (eventType.toLowerCase()) {
    case 'mariage':
      return "Chère famille, chers amis,\n\n"
          "C’est avec une immense joie que nous vous convions au mariage de $brideName et $groomName, qui aura lieu le $formattedDate.\n\n"
          "Nous serions profondément heureux de partager ce moment unique avec vous !\n\n"
          "Merci de confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    case 'gala':
      return "Chers invités,\n\n"
          "C’est avec une immense joie que nous vous convions au Gala qui se tiendra le $formattedDate.\n\n"
          "Cette soirée promet d’être inoubliable, et nous serions honorés de vous compter parmi nous !\n\n"
          "Merci de bien vouloir confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    case 'soirée':
      return "Chers invités,\n\n"
          "Nous avons l’immense joie de vous inviter à la soirée $partyName, le $formattedDate.\n\n"
          "Nous espérons de tout cœur avoir le plaisir de vous compter parmi nous!\n\n"
          "Merci de bien vouloir confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    case 'anniversaire':
      return "Chère famille, chers amis,\n\n"
          "Vous êtes chaleureusement conviés à célébrer l’anniversaire de  $birthdayPersonName, le $formattedDate.\n\n"
          "Ce moment promet d’être mémorable, et votre présence sera un honneur pour lui et pour tous ceux qui partageront cet événement.\n\n"
          "Merci de bien vouloir confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    case 'bar mitsvah':
      return "Chère famille, chers amis,\n\n"
          "C’est avec une grande joie que nous vous invitons à célébrer la Bar Mitsva de $barMitsvahName, qui aura lieu le $formattedDate.\n\n"
          "Ce moment marquant sera encore plus précieux en votre présence.\n\n"
          "Merci de bien vouloir confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    case 'entreprise':
      return "Chers invités,\n\n"
          "Nous avons le plaisir de vous convier à notre événement qui aura lieu le $formattedDate.\n\n"
          "Rejoignez-nous pour partager des idées, découvrir de nouvelles perspectives et renforcer nos liens dans un cadre convivial.\n\n"
          "Nous serions ravis de vous compter parmi nous pour faire de cet événement un succès.\n\n"
          "Merci de bien vouloir confirmer votre présence via notre application Kapstr en utilisant le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
    default:
      return "Chers invités,\n\n"
          "Nous avons l’immense joie de vous convier à notre événement : $partyName, le $formattedDate.\n\n"
          "Nous espérons de tout cœur avoir le plaisir de vous compter parmi nous!\n\n"
          "Veuillez nous confirmer votre présence, via notre application avec le code : $code\n"
          "Pour télécharger l’application : $downloadLink";
  }
}

String getCoOrganizerMessage(String eventType) {
  String code = Event.instance.code;
  String iOSAppLink = kIOSAppLink; // Lien de téléchargement pour iOS
  String androidAppLink = kAndroidAppLink; // Lien de téléchargement pour Android
  DateTime date = Event.instance.date!;

  var formatter = DateFormat('d MMMM y', 'fr_FR');
  String formattedDate = formatter.format(date);
  String brideName = Event.instance.womanFirstName; // Nom de la mariée
  String groomName = Event.instance.manFirstName; // Nom du marié
  String galaName = Event.instance.eventName; // Nom du gala
  String partyName = Event.instance.modules.where((module) => module.type == 'wedding').first.name; // Nom de la soirée
  String birthdayPersonName = Event.instance.manFirstName; // Nom de la personne dont c'est l'anniversaire
  String barMitsvahName = Event.instance.manFirstName; // Nom de la personne pour la Bar Mitsvah
  String companyName = Event.instance.eventName; // Nom de l'entreprise

  switch (eventType.toLowerCase()) {
    case 'mariage':
      return "Bonjour ! $brideName et $groomName sont ravis de vous inviter à leur mariage en tant que co-organisateurs le $formattedDate. "
          "Pour suivre tous les détails et participer aux festivités, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    case 'gala':
      return "Bonjour ! Vous êtes invités à co-organiser le Gala $galaName qui se tiendra le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    case 'soirée':
      return "Bonjour ! Vous êtes invités à co-organiser la soirée $partyName qui se déroulera le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    case 'anniversaire':
      return "Bonjour ! $birthdayPersonName est ravi de vous inviter à son anniversaire en tant que co-organisateur le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    case 'bar mitsvah':
      return "Bonjour ! $barMitsvahName est ravi de vous inviter à sa Bar Mitsvah en tant que co-organisateur le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    case 'entreprise':
      return "Bonjour ! $companyName est ravi de vous inviter à son événement d'entreprise en tant que co-organisateur le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
    default:
      return "Bonjour ! Vous êtes invités à co-organiser notre événement spécial qui se tiendra le $formattedDate. "
          "Pour suivre tous les détails et participer à l'organisation, téléchargez notre application spéciale ! 🎉\n\n"
          "Pour iOS: $iOSAppLink\nPour Android: $androidAppLink\n\n"
          "Une fois installée, saisissez le code d'invitation: $code. Au plaisir de vous y voir !";
  }
}
