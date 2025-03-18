import 'package:kapstr/models/modules/about_service.dart';
import 'package:kapstr/models/modules/module.dart';

class AboutModule extends Module {
  String title;
  String description;
  String adress;
  String email;
  String phone;
  String website;
  String logoUrl;
  List<AboutService> services;

  AboutModule({
    required super.id,
    required super.name,
    required super.allowGuest,
    required super.colorFilter,
    required super.image,
    required super.isEvent,
    required super.moreInfos,
    required super.textColor,
    required super.textSize,
    required super.type,
    required super.fontType,
    required this.title,
    required this.description,
    required this.adress,
    required this.email,
    required this.phone,
    required this.website,
    required this.logoUrl,
    this.services = const [],
  });

  static AboutModule fromMap(String id, Map<String, dynamic> json) {
    return AboutModule(
      id: id,
      name: json['name'] ?? "",
      allowGuest: json['allow_guests'] ?? true,
      colorFilter: json['color_filter'] ?? "",
      image: json['image'] ?? "",
      isEvent: json['is_event'] ?? true,
      moreInfos: json['more_infos'] ?? "",
      textColor: json['text_color'] ?? "",
      textSize: json['text_size'] is int ? json['text_size'] : 32,
      type: json['type'] ?? "",
      fontType: json['typographie'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      adress: json['adress'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      logoUrl: json['logo_url'] ?? "",
      website: json['website'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'allow_guests': allowGuest,
      'color_filter': colorFilter,
      'image': image,
      'is_event': isEvent,
      'more_infos': moreInfos,
      'description': description,
      'title': title,
      'text_color': textColor,
      'text_size': textSize,
      'type': type,
      'typographie': fontType,
      'adress': adress,
      'email': email,
      'phone': phone,
      'website': website,
      'logo_url': logoUrl,
      'services': services.map((service) => service.toMap()).toList(),
    };
  }

  setServices(List<AboutService> services) {
    this.services = services;
  }

  addService(AboutService service) {
    this.services.add(service);
  }

  removeService(AboutService service) {
    this.services.remove(service);
  }
}
