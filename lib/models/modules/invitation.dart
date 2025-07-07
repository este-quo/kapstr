import 'package:kapstr/models/modules/module.dart';

class InvitationModule extends Module {
  // new

  String initials = "";
  Map<String, dynamic> initialsStyle = {};

  String title = "";
  Map<String, dynamic> titleStyle = {};

  String introduction = "";
  Map<String, dynamic> introductionStyle = {};

  String conclusion = "";
  Map<String, dynamic> conclusionStyle = {};

  String contact1 = "";
  Map<String, dynamic> contact1Style = {};

  String contact2 = "";
  Map<String, dynamic> contact2Style = {};

  String names = "";
  Map<String, dynamic> namesStyles = {};
  bool namesStylesOverride = false;

  String partyDateRecto = "";
  Map<String, dynamic> partyDateRectoStyle = {};
  bool partyDateRectoOverride = false;

  String partyDateVerso = "";
  Map<String, dynamic> partyDateVersoStyle = {};
  bool partyDateVersoOverride = false;

  String partyPlaceAdress = "";
  Map<String, dynamic> partyPlaceAdressStyle = {};
  bool partyPlaceAdressOverride = false;

  String partyPlaceName = "";
  Map<String, dynamic> partyPlaceNameStyle = {};
  bool partyPlaceNameOverride = false;

  String partyLinking = "";
  Map<String, dynamic> partyLinkingStyle = {};

  InvitationModule({
    required super.id,
    required super.allowGuest,
    required super.colorFilter,
    required super.image,
    required super.isEvent,
    required super.moreInfos,
    required super.name,
    required super.textColor,
    required super.textSize,
    required super.type,
    required super.fontType,
    required this.initials,
    required this.initialsStyle,
    required this.title,
    required this.titleStyle,
    required this.introduction,
    required this.introductionStyle,
    required this.conclusion,
    required this.conclusionStyle,
    required this.contact1,
    required this.contact1Style,
    required this.contact2,
    required this.contact2Style,
    required this.names,
    required this.namesStyles,
    required this.partyDateRecto,
    required this.partyDateRectoStyle,
    required this.partyDateVerso,
    required this.partyDateVersoStyle,
    required this.partyPlaceAdress,
    required this.partyPlaceAdressStyle,
    required this.partyPlaceName,
    required this.partyPlaceNameStyle,
    required this.partyLinking,
    required this.partyLinkingStyle,
  });

  factory InvitationModule.fromMap(String id, Map<String, dynamic> json) {
    return InvitationModule(
      id: id,
      allowGuest: json['allow_guests'] ?? true,
      colorFilter: json['color_filter'] ?? "",
      image: json['image'] ?? "",
      moreInfos: json['more_infos'] ?? "",
      isEvent: json['is_event'] ?? true,
      name: json['name'] ?? "",
      textColor: json['text_color'] ?? "",
      textSize: json['text_size'] is int ? json['text_size'] : 32,
      type: json['type'] ?? "",
      fontType: json['typographie'] ?? "",
      initials: json['initials'] ?? "",
      initialsStyle: json['initials_style'] ?? "",
      title: json['title'] ?? "",
      titleStyle: json['title_style'] ?? "",
      introduction: json['introduction'] ?? "",
      introductionStyle: json['introduction_style'] ?? "",
      conclusion: json['conclusion'] ?? "",
      conclusionStyle: json['conclusion_style'] ?? "",
      contact1: json['contact_1'] ?? "",
      contact1Style: json['contact_1_style'] ?? "",
      contact2: json['contact_2'] ?? "",
      contact2Style: json['contact_2_style'] ?? "",
      names: json['names'] ?? "",
      namesStyles: json['names_styles'] ?? "",
      partyDateRecto: json['party_date_recto'] ?? "",
      partyDateRectoStyle: json['party_date_recto_style'] ?? "",
      partyDateVerso: json['party_date_verso'] ?? "",
      partyDateVersoStyle: json['party_date_verso_style'] ?? "",
      partyPlaceAdress: json['party_place_adress'] ?? "",
      partyPlaceAdressStyle: json['party_place_adress_style'] ?? "",
      partyPlaceName: json['party_place_name'] ?? "",
      partyPlaceNameStyle: json['party_place_name_style'] ?? "",
      partyLinking: json['party_linking'] ?? "",
      partyLinkingStyle: json['party_linking_style'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "allow_guests": allowGuest,
      "color_filter": colorFilter,
      "image": image,
      "is_event": isEvent,
      "more_infos": moreInfos,
      "name": name,
      "text_color": textColor,
      "text_size": textSize,
      "type": type,
      "font_type": fontType,
      'introduction': introduction,
      'introduction_style': introductionStyle,
      'conclusion': conclusion,
      'conclusion_style': conclusionStyle,
      'contact_1': contact1,
      'contact_1_style': contact1Style,
      'contact_2': contact2,
      'contact_2_style': contact2Style,
      'initials': initials,
      'initials_style': initialsStyle,
      'title': title,
      'title_style': titleStyle,
      'names': names,
      'names_styles': namesStyles,
      'party_date_recto': partyDateRecto,
      'party_date_recto_style': partyDateRectoStyle,
      'party_date_verso': partyDateVerso,
      'party_date_verso_style': partyDateVersoStyle,
      'party_place_adress': partyPlaceAdress,
      'party_place_adress_style': partyPlaceAdressStyle,
      'party_place_name': partyPlaceName,
      'party_place_name_style': partyPlaceNameStyle,
      'party_linking': partyLinking,
      'party_linking_style': partyLinkingStyle,
    };
  }
}
