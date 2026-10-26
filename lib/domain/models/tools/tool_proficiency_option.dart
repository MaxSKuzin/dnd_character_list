import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

/// Владение инструментом из описания класса или предыстории: либо конкретный инструмент
/// («Набор для грима»), либо выбор из категории («один вид музыкального инструмента»).
class ToolProficiencyOption {
  /// Текст с сайта, например «Набор для грима» или «Транспорт (водный)».
  final String title;
  final ToolCategory? category;

  /// Сколько инструментов категории нужно выбрать; 0 — владение указанным инструментом.
  final int choose;

  const ToolProficiencyOption({
    required this.title,
    required this.category,
    required this.choose,
  });

  bool get isChoice => choose > 0 && category != null;

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category?.name,
        'choose': choose,
      };

  factory ToolProficiencyOption.fromJson(Map<String, dynamic> json) => ToolProficiencyOption(
        title: json['title'],
        category: json['category'] == null ? null : ToolCategory.values.byName(json['category']),
        choose: json['choose'],
      );
}
