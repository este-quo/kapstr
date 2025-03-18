import 'package:kapstr/models/modules/module.dart';

class MediaModule extends Module {
  String url;
  String videoId;
  String mediaType;

  MediaModule({
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
    required this.url,
    required this.videoId,
    required this.mediaType,
  });

  factory MediaModule.fromMap(String id, Map<String, dynamic> json) {
    return MediaModule(
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
      url: json['url'] ?? "",
      videoId: json['video_id'] ?? "",
      mediaType: json['media_type'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'allow_guests': allowGuest, 'color_filter': colorFilter, 'image': image, 'is_event': isEvent, 'more_infos': moreInfos, 'name': name, 'text_color': textColor, 'text_size': textSize, 'type': type, 'typographie': fontType, 'url': url, 'video_id': videoId, 'media_type': mediaType};
  }
}
