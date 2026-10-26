import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:injectable/injectable.dart';

/// Переводит ответ `POST /feats/<slug>` в [Feat].
@lazySingleton
class TtgFeatsMapper {
  /// [link] — ссылка из списка (`/feats/resilient`).
  Feat map(String link, Map<String, dynamic> json) {
    final (name, nameEn) = TtgText.names(json['name']);
    final requirement = json['requirements'] as String?;
    final requirementText = requirement == null || requirement == 'Нет' ? null : TtgText.cleanText(requirement);
    final description = TtgText.html(json['description']);
    final abilities = (json['abilities'] as List? ?? const []).map(TtgText.stat).nonNulls.toList();
    return Feat(
      id: json['id'],
      link: TtgText.normalizeLink(link),
      name: name,
      nameEn: nameEn,
      requirementText: requirementText,
      requirement: _parseRequirement(requirementText),
      descriptionHtml: description,
      statIncreaseOptions: abilities.isNotEmpty ? abilities : _parseStatIncrease(TtgText.plainText(description)),
    );
  }

  /// «Увеличьте значение Силы или Ловкости на 1» → [Сила, Ловкость];
  /// «Увеличьте значение выбранной характеристики на 1» → любая.
  List<StatKind> _parseStatIncrease(String text) {
    final match = RegExp(r'Увеличьте значение (.+?) на 1').firstMatch(text);
    if (match == null) return [];
    if (match.group(1)!.contains('выбранной')) return StatKind.values;
    return TtgText.statsIn(match.group(1)!);
  }

  FeatRequirement _parseRequirement(String? text) {
    if (text == null) return const FeatRequirement();
    final stats = RegExp(r'(.+?)\s+13 или выше').firstMatch(text);
    final lower = text.toLowerCase().replaceAll('ё', 'е');
    return FeatRequirement(
      minimumStats: stats == null ? const [] : TtgText.statsIn(stats.group(1)!),
      spellcasting: lower.contains('накладывать') || lower.contains('заклинани'),
      armor: switch (lower) {
        _ when lower.contains('легкими доспехами') || lower.contains('легкие доспехи') => ArmorProficiency.light,
        _ when lower.contains('средними доспехами') || lower.contains('средние доспехи') => ArmorProficiency.medium,
        _ when lower.contains('тяжелыми доспехами') || lower.contains('тяжелые доспехи') => ArmorProficiency.heavy,
        _ => null,
      },
    );
  }
}
