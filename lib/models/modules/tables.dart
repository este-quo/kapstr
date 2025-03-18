import 'package:kapstr/models/modules/module.dart';

class TableModule extends Module {
  final List<String> tablesId;

  TableModule({
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
    required this.tablesId,
  });

  factory TableModule.fromMap(String id, Map<String, dynamic> json) {
    return TableModule(
      id: id,
      allowGuest: json['allow_guests'] ?? false,
      colorFilter: json['color_filter'] ?? '',
      image: json['image'] ?? '',
      isEvent: json['is_event'] ?? false,
      moreInfos: json['more_infos'] ?? '',
      name: json['name'] ?? '',
      textColor: json['text_color'] ?? '',
      textSize: json['text_size'] is int ? json['text_size'] : 32,
      type: json['type'] ?? '',
      fontType: json['typographie'] ?? '',
      tablesId: List<String>.from(json['tables_id'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'allow_guests': allowGuest, 'color_filter': colorFilter, 'image': image, 'is_event': isEvent, 'more_infos': moreInfos, 'name': name, 'text_color': textColor, 'text_size': textSize, 'type': type, 'typographie': fontType, 'tables_id': tablesId};
  }
}
