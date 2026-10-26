import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

/// Владение инструментом из описания класса или предыстории: либо конкретный инструмент
/// («Набор для грима»), либо выбор из категории («один вид музыкального инструмента») или из нескольких
/// категорий («один вид инструментов ремесленников либо музыкального инструмента» у монаха).
class ToolProficiencyOption {
  /// Текст с сайта, например «Набор для грима» или «Транспорт (водный)».
  final String title;
  final ToolCategory? category;

  /// Другие категории, из которых можно выбирать вместо [category].
  final List<ToolCategory> alternatives;

  /// Сколько инструментов категории нужно выбрать; 0 — владение указанным инструментом.
  final int choose;

  const ToolProficiencyOption({
    required this.title,
    required this.category,
    required this.choose,
    this.alternatives = const [],
  });

  /// Все категории, из которых выбирают.
  List<ToolCategory> get categories => [if (category != null) category!, ...alternatives];

  bool get isChoice => choose > 0 && category != null;

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category?.name,
        'choose': choose,
        'alternatives': alternatives.map((e) => e.name).toList(),
      };

  factory ToolProficiencyOption.fromJson(Map<String, dynamic> json) => ToolProficiencyOption(
        title: json['title'],
        category: json['category'] == null ? null : ToolCategory.values.byName(json['category']),
        choose: json['choose'],
        alternatives: (json['alternatives'] as List).map((e) => ToolCategory.values.byName(e)).toList(),
      );
}
