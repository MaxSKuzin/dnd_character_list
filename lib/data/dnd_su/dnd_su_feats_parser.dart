import 'package:dnd_character_list/data/dnd_su/dnd_su_backgrounds_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_html.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Разбирает раздел https://dnd.su/feats/.
@lazySingleton
class DndSuFeatsParser {
  static const indexPath = '/feats/';

  List<DndSuListItem> parseIndex(String body) =>
      DndSuBackgroundsParser.parseList(body, source: DndSuBackgroundsParser.playersHandbookSource);

  Feat parseFeat(String link, String body) {
    final article = DndSuHtml.parseArticle(body);
    final description = article?.querySelector('[itemprop="description"]');
    final title = html_parser.parse(DndSuHtml.cutArticle(body)).querySelector('.card-title span[data-copy]')?.text;
    if (article == null || description == null || title == null) {
      throw const DndSuMissingContentException('Не удалось найти описание черты на странице');
    }
    final (name, nameEn) = DndSuHtml.splitTitle(title);
    final requirement = article.querySelector('li.size-type-alignment')?.text;
    final requirementText =
        requirement == null ? null : DndSuHtml.cleanText(requirement).replaceFirst(RegExp(r'^Требование:\s*'), '');

    return Feat(
      id: int.parse(RegExp(r'/feats/(\d+)').firstMatch(link)!.group(1)!),
      link: link,
      name: name,
      nameEn: nameEn,
      requirementText: requirementText,
      requirement: _parseRequirement(requirementText),
      descriptionHtml: description.innerHtml.trim(),
      statIncreaseOptions: _parseStatIncrease(DndSuHtml.cleanText(description.text)),
    );
  }

  /// «Увеличьте значение Силы или Ловкости на 1» → [Сила, Ловкость];
  /// «Увеличьте значение выбранной характеристики на 1» → любая.
  List<StatKind> _parseStatIncrease(String text) {
    final match = RegExp(r'Увеличьте значение (.+?) на 1').firstMatch(text);
    if (match == null) return [];
    if (match.group(1)!.contains('выбранной')) return StatKind.values;
    return DndSuHtml.statsIn(match.group(1)!);
  }

  FeatRequirement _parseRequirement(String? text) {
    if (text == null) return const FeatRequirement();
    final stats = RegExp(r'(.+?)\s+13 или выше').firstMatch(text);
    return FeatRequirement(
      minimumStats: stats == null ? const [] : DndSuHtml.statsIn(stats.group(1)!),
      spellcasting: text.contains('накладывать'),
      armor: switch (text) {
        _ when text.contains('лёгкими доспехами') || text.contains('легкими доспехами') => ArmorProficiency.light,
        _ when text.contains('средними доспехами') => ArmorProficiency.medium,
        _ when text.contains('тяжёлыми доспехами') || text.contains('тяжелыми доспехами') => ArmorProficiency.heavy,
        _ => null,
      },
    );
  }
}
