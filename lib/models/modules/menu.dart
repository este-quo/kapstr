import 'package:kapstr/models/modules/module.dart';

class MenuModule extends Module {
  String title;
  Map<String, dynamic> titleStyle;

  String entry;
  Map<String, dynamic> entryStyle;

  String entryContent;
  Map<String, dynamic> entryContentStyle;

  String mainCourse;
  Map<String, dynamic> mainCourseStyle;

  String mainCourseContent;
  Map<String, dynamic> mainCourseContentStyle;

  String dessert;
  Map<String, dynamic> dessertStyle;

  String dessertContent;
  Map<String, dynamic> dessertContentStyle;

  String names;
  Map<String, dynamic> namesStyles;

  String dateText;
  Map<String, dynamic> dateStyles;

  MenuModule({
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
    required this.title,
    required this.titleStyle,
    required this.entry,
    required this.entryStyle,
    required this.mainCourse,
    required this.mainCourseStyle,
    required this.dessert,
    required this.dessertStyle,
    required this.entryContent,
    required this.entryContentStyle,
    required this.mainCourseContent,
    required this.mainCourseContentStyle,
    required this.dessertContent,
    required this.dessertContentStyle,
    required this.names,
    required this.namesStyles,
    required this.dateText,
    required this.dateStyles,
  });

  factory MenuModule.fromMap(String id, Map<String, dynamic> json) {
    return MenuModule(
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
      title: json['title'] ?? "",
      titleStyle: json['title_style'] ?? "",
      entry: json['entry'] ?? "",
      entryStyle: json['entry_style'] ?? "",
      mainCourse: json['main_course'] ?? "",
      mainCourseStyle: json['main_course_style'] ?? "",
      dessert: json['dessert'] ?? "",
      dessertStyle: json['dessert_style'] ?? "",
      entryContent: json['entry_content'] ?? "",
      entryContentStyle: json['entry_content_style'] ?? "",
      mainCourseContent: json['main_course_content'] ?? "",
      mainCourseContentStyle: json['main_course_content_style'] ?? "",
      dessertContent: json['dessert_content'] ?? "",
      dessertContentStyle: json['dessert_content_style'] ?? "",
      names: json['names'] ?? "",
      namesStyles: json['names_styles'] ?? "",
      dateText: json['date_text'] ?? "",
      dateStyles: json['date_styles'] ?? "",
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
      'title': title,
      'title_style': titleStyle,
      'entry': entry,
      'entry_style': entryStyle,
      'main_course': mainCourse,
      'main_course_style': mainCourseStyle,
      'dessert': dessert,
      'dessert_style': dessertStyle,
      'entry_content': entryContent,
      'entry_content_style': entryContentStyle,
      'main_course_content': mainCourseContent,
      'main_course_content_style': mainCourseContentStyle,
      'dessert_content': dessertContent,
      'dessert_content_style': dessertContentStyle,
      'names': names,
      'names_styles': namesStyles,
      'date_text': dateText,
      'date_styles': dateStyles,
    };
  }
}
