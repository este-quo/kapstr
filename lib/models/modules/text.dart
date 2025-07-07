import 'package:kapstr/models/modules/module.dart';

class TextModule extends Module {
  String content;
  Map<String, dynamic> contentStyle;

  TextModule({
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
    required this.content,
    required this.contentStyle,
  });

  factory TextModule.fromMap(String id, Map<String, dynamic> json) {
    return TextModule(
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
      content: json['content'] ?? "",
      contentStyle: json['content_style'] ?? {},
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {"id": id, "allow_guests": allowGuest, "color_filter": colorFilter, "image": image, "is_event": isEvent, "more_infos": moreInfos, "name": name, "text_color": textColor, "text_size": textSize, "type": type, "font_type": fontType, "content": content, "content_style": contentStyle};
  }
}
