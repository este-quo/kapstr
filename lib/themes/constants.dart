import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kapstr/models/app_event.dart';

import '../services/firebase/cloud_firestore/firestore_configuration.dart';

//colorskBlack
const kBlack = Color.fromARGB(255, 3, 3, 3);
const kWhite = Color(0xFFFFFFFF);
const Color kPrimary = Color(0XFF448AF7);
const Color kYellow = Color.fromARGB(255, 3, 3, 3);

Color kBorderColor = Colors.black.withOpacity(0.15);

BoxShadow kBoxShadow = BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, offset: const Offset(0, 0), blurRadius: 10);

const kYellowWithOpacity = Color.fromARGB(150, 178, 149, 0);

const kBackgroundNavBar = Color.fromRGBO(246, 246, 246, 1);

const kDarkGrey = Color(0xFF696969); // #696969
const kSemiDarkGrey = Color(0xFF979797); // #979797
const kGrey = Color.fromRGBO(175, 175, 175, 1); // #8C8D91
const kMediumGrey = Color(0xFFDBDBDB); // #DBDBDB
const kLightGrey = Color.fromARGB(255, 171, 172, 177); //#F0F0F0
const kSemiLightGrey = Color(0xFFF6F6F6); //#F6F6F6
const kLighterGrey = Color.fromARGB(255, 242, 242, 242); //#D8D8D8

const kGoogleApiKey = 'AIzaSyAzoX8noIbqvPyayw-DLO47kGNETanbi1c';

const kLightWhite = Color(0xFFF7F7F7); // #F7F7F7
const kLightWhiteTransparent2 = Color.fromARGB(70, 247, 247, 247); // #F7F7F7
const kLightWhiteTransparent1 = Color.fromARGB(36, 247, 247, 247); // #F7F7F7

const kDanger = Color(0xFFD90D1E); //#D90D1E
const kDangerSmooth = Color(0xFFF04760); //#F04760
const kSuccess = Color(0xFF73D388); // #73D388

const kBlueLink = Color(0xFF2D9EE5); // #2D9EE5

const kFacebook = Color(0xff3d599b); // #166DE2
const kGoogle = Color(0xFFE4E4E4); // #E4E4E4
const kWaze = Color(0xFF34CCFD); // #34CCFD

const kProgressIndicatorBgDark = Color(0xFF16140C); // #16140C
const kProgressIndicatorBgLight = Color(0xFFF9F7EF); // #F9F7EF

//color filters invitation answer
const kReceived = Color(0xFF56B6C2); // #56B6C2
const kPresent = Color(0xFF56C28E); // #56C28E
const kAbsent = Color(0xFFF44145); // #F44145
const kWaiting = Color(0xFFFF7E39); // #FF7E39

//modules color filters
const kModuleFilterTransparent = Color(0xFFFFFFFF); // Blanc
const kModuleFilterBlue = Color(0xFF2036A0); // Bleu
const kModuleFilterOrange = Color(0xFFE78F40); // Orange
const kModuleFilterPurple = Color(0xFF6172C2); // Violet
const kModuleFilterDarkGreen = Color(0xFF095A6A); // Vert foncé
const kModuleFilterRed = Color(0xFFD3705C); // Rouge
const kModuleFilterCyan = Color(0xFF53B9CD); // Cyan
const kModuleFilterDarkPurple = Color(0xFF3D104E); // Violet foncé
const kModuleFilterYellow = Color(0xFFD3B81A); // Jaune
const kModuleFilterGold = Color(0xFFB29500); // Doré
const kModuleFilterGrey = Color(0xFFB2B2B2); // Gris

//pre define colors for app custom
List<Color> kColors = [kModuleFilterBlue, kModuleFilterOrange, kModuleFilterPurple, kModuleFilterDarkGreen, kModuleFilterRed, kModuleFilterCyan, kModuleFilterDarkPurple, kModuleFilterYellow, kModuleFilterGold, kBlack, kModuleFilterGrey, kWhite];

final List<String> kNonEventModules = ['budget', 'cagnotte', 'invitation', 'album_photo', 'tables', 'golden_book', 'menu', 'media', 'about', 'text'];

List<String> kGoogleFonts = [
  'Roboto',
  'Open Sans',
  'Montserrat',
  'Lato',
  'Poppins',
  'Noto Sans',
  'Raleway',
  'Playfair Display',
  'Nunito Sans',
  'Ubuntu',
  'Rubik',
  'Merriweather',
  'Lora',
  'Quicksand',
  'Inconsolata',
  'Bebas Neue',
  'Dancing Script',
  'EB Garamond',
  'Lobster',
  'Meie Script',
  'Indie Flower',
  'Courgette',
  'Prata',
  'Old Standard TT',
  'Pathway Gothic One',
  'Nanum Pen Script',
  'Marck Script',
  'Volkhov',
  'Playball',
  'Lusitana',
  'Unica One',
  'Whisper',
  'Italianno',
  'Quintessential',
  'Amita',
  'Darker Grotesque',
  'Just Another Hand',
  'Big Shoulders Text',
  'Pompiere',
  'Mountains of Christmas',
  'Ms Madi',
  'Mouse Memoirs',
  'Hurricane',
  'Great Vibes',
  'Pacifico',
  'Saira',
  'Cairo',
  'Anton',
  'Titillium Web',
  'Source Sans Pro',
  'Abril Fatface',
  'Fjalla One',
  'Josefin Sans',
  'Oxygen',
  'Asap',
  'Bangers',
  'Maven Pro',
  'Overpass',
  'Heebo',
  'Alfa Slab One',
  'Cabin',
  'Righteous',
];

List<Color> kModulesColors = [Colors.transparent, kModuleFilterOrange, kModuleFilterPurple, kModuleFilterDarkGreen, kModuleFilterRed, kModuleFilterCyan, kModuleFilterDarkPurple, kModuleFilterYellow, kModuleFilterGold];

Map<String, Color> dropdownColors = {'Tous': kBlack, 'Accepté': kPresent, 'En attente': kWaiting, 'Absent': kAbsent};

Map<String, dynamic> dropdownGuestStatus = {'Tous': 'all', 'Accepté': 'present', 'En attente': 'waiting', 'Absent': 'absent'};

List<String> invitationAnswers = ['Accepté', 'En attente', 'Absent'];
List<String> allTypeOfGuests = ['Mr', 'Mme', 'Enfants'];

//text
const List<String> dateAnswers = ['Je connais la date', 'Je ne sais pas encore'];

//logos
const kLogoWhite = Text('IC EVENT', style: TextStyle(color: kWhite, fontFamily: 'Impact', fontSize: 40.0));

const kLogoBlack = Text('IC EVENT', style: TextStyle(color: kBlack, fontFamily: 'Impact', fontSize: 40.0));

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirestoreConfiguration configuration = FirestoreConfiguration();
final Reference storageRef = FirebaseStorage.instance.ref();

const kIOSAppLink = "https://apps.apple.com/us/app/kapstr/id6503693192";
const kAndroidAppLink = "https://kapstr.fr/download";

const kDefaultDate = "2000-01-01 18:00:00.000";

Map<String, Map<String, String>> kEventModuleImages = {
  'mariage': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712191198055.jpg?alt=media&token=a0a3d30c-d60a-4980-8081-1f65bf5921ce',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fnew_event.jpeg?alt=media&token=b961b349-fcb4-4d66-b454-53ca1a278aae'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fmariage.jpg?alt=media&token=b231c6de-76e5-411a-95ec-6058f8438e43',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ad',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'mairie': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712178541968.jpg?alt=media&token=30daaf56-7d46-49d5-9c75-8c50d098a133',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fmariage.jpg?alt=media&token=b231c6de-76e5-411a-95ec-6058f8438e43',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'salon': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719322384906.jpg?alt=media&token=1cbb4c01-26f2-480c-b968-9142088db1d7',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719322296176.jpg?alt=media&token=2af2bec0-bad3-45b7-92ed-9405f1467521'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719322296176.jpg?alt=media&token=2af2bec0-bad3-45b7-92ed-9405f1467521',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ad',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719322296176.jpg?alt=media&token=2af2bec0-bad3-45b7-92ed-9405f1467521',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'gala': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712191198055.jpg?alt=media&token=a0a3d30c-d60a-4980-8081-1f65bf5921ce',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ad',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'anniversaire': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Falbum%20photo.jpg?alt=media&token=b1d51834-e031-472b-b340-e8f288219967',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fanniversaire.jpg?alt=media&token=4abbda9e-0458-45ab-a2e6-95e9cdc03156'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fanniversaire.jpg?alt=media&token=4abbda9e-0458-45ab-a2e6-95e9cdc03156',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ade',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fanniversaire.jpg?alt=media&token=4abbda9e-0458-45ab-a2e6-95e9cdc03156',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'soirée': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717430146886.jpg?alt=media&token=c62fa528-4641-4f73-9315-77deaef0bc64',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fsoir%C3%A9e.jpg?alt=media&token=c155115a-3464-4fe1-9d9a-458b72138301'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717519259798.jpg?alt=media&token=09068367-6d9c-43f4-bbf6-5fc6138a915f',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719316097276.jpg?alt=media&token=c8f4befb-d65c-4f8d-90df-7437cf8b7b9a',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ade',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fsoir%C3%A9e.jpg?alt=media&token=c155115a-3464-4fe1-9d9a-458b72138301',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'entreprise': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2FIMG_0810.JPG?alt=media&token=c88d61dc-4dff-40b0-8b09-28f29b92edc7',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fsoir%C3%A9e.jpg?alt=media&token=c155115a-3464-4fe1-9d9a-458b72138301'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fsoir%C3%A9e.jpg?alt=media&token=c155115a-3464-4fe1-9d9a-458b72138301',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ade',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fsoir%C3%A9e.jpg?alt=media&token=c155115a-3464-4fe1-9d9a-458b72138301',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719317887840.jpg?alt=media&token=8db90ac2-8930-4ad6-b3f2-0d3f97661057',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'bar mitsvah': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1714131485112.jpg?alt=media&token=80f9d6b0-358e-4a4c-b72f-a90af7b85124',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719316097276.jpg?alt=media&token=c8f4befb-d65c-4f8d-90df-7437cf8b7b9a'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2FIMG_0815.JPG?alt=media&token=764b6df2-fb67-4ef9-8b24-baea10391cf7',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ade',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1719316097276.jpg?alt=media&token=c8f4befb-d65c-4f8d-90df-7437cf8b7b9a',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fa%20propos.jpg?alt=media&token=ce96cc67-4ba4-4e7a-a8ea-47d70e23caab',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
  'autre': {
    'album_photo': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717430146886.jpg?alt=media&token=c62fa528-4641-4f73-9315-77deaef0bc64',
    'event':
        Event.instance.modules.any((module) => module.type == 'event')
            ? 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a'
            : 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a',
    'tables': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftable.jpg?alt=media&token=e17f5f23-0aa2-4c63-85d1-f70a6fb9e494',
    'invitation': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fwedding_carte_invitation.jpg?alt=media&token=4bd5fadb-7f19-418a-81b7-9055087d54ade',
    'media': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fdocument.jpg?alt=media&token=5fc1545f-8444-40c6-9402-50010afde189',
    'wedding': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1717518825572.jpg?alt=media&token=f52aea89-b2c7-49f1-beb8-528625270b4a',
    'cagnotte': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Fcagnotte.jpg?alt=media&token=88b6c0c1-42e4-4887-99dc-6a9b08d61c4a',
    'golden_book': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712180171397.jpg?alt=media&token=84cb8e69-de77-4db5-bacd-bfb6cd2593a9',
    'menu': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2F1712179982770.jpg?alt=media&token=91784d54-ce50-4795-a9f1-9122228905ff',
    'about': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2FIMG_0622.JPG?alt=media&token=e5169de8-4151-4842-8dcb-662340887e00',
    'text': 'https://firebasestorage.googleapis.com/v0/b/ic-event-v2.appspot.com/o/default%2Fimages%2Ftext.jpeg?alt=media&token=3a83a1d5-70ef-4bb2-9e36-104126789e0d',
  },
};

final bool kAutoConsume = Platform.isIOS || true;
const String kBasicId = 'kapstr_basic_plan';
const String kPremiumId = 'kapstr_premium_plan';
const String kPremiumPlusId = 'kapstr_premium_plus_plan';
const String kUnlimitedId = 'kapstr_unlimited_plan';
const List<String> kProductIds = <String>[kBasicId, kPremiumId, kPremiumPlusId, kUnlimitedId];
