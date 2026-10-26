import 'dart:convert';

import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Разбирает страницы раздела https://dnd.su/spells/.
@lazySingleton
class DndSuSpellsParser {
  /// Фрагмент со списком всех заклинаний, который подгружает страница /spells/.
  static const indexPath = '/piece/spells/index-list/';

  /// Идентификаторы классов в фильтрах dnd.su.
  static const _classIds = {
    12: ClassKind.bard,
    13: ClassKind.cliric,
    16: ClassKind.paladin,
    17: ClassKind.ranger,
    19: ClassKind.sorcerer,
    20: ClassKind.witch,
    21: ClassKind.wizard,
    22: ClassKind.driud,
    23: ClassKind.inventor,
  };

  /// В фильтрах концентрации и ритуала «2» означает «да», «1» — «нет».
  static const _yes = '2';

  /// Ответ [indexPath] — это `<script>window.LIST = {...};</script>`.
  List<Spell> parseIndex(String body) {
    final match = RegExp(r'window\.LIST\s*=\s*(\{.*?\});\s*</script>', dotAll: true).firstMatch(body);
    if (match == null) {
      throw const DndSuException('Не удалось найти список заклинаний на странице');
    }
    final json = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    return (json['cards'] as List).cast<Map<String, dynamic>>().map(_parseCard).toList();
  }

  Spell _parseCard(Map<String, dynamic> card) {
    final link = card['link'] as String;
    final components = (card['filter_components'] as String).split('|');
    final castTime = card['filter_casttime'] as List;
    return Spell(
      id: Spell.idFromLink(link),
      link: link,
      name: card['title'],
      nameEn: card['title_en'],
      slot: SpellSlot.fromLevel((card['filter_level'] as List).first),
      school: card['school'],
      isConcentration: (card['filter_concentration'] as List).contains(_yes),
      isRitual: (card['filter_ritual'] as List).contains(_yes),
      components: [
        if (components[0] == '1') SpellComponent.verbal,
        if (components[1] == '1') SpellComponent.somatic,
        if (components[2] == '1') SpellComponent.material,
      ],
      castTimeType: castTime.isEmpty ? null : SpellTime.fromDndSu(castTime.first),
      allowedSpecializations: _parseClasses(card['filter_class']),
      tceSpecializations: _parseClasses(card['filter_class_tce']),
    );
  }

  List<ClassKind> _parseClasses(List ids) => ids.map((e) => _classIds[e]).nonNulls.toList();

  /// Разбирает страницу заклинания вида https://dnd.su/spells/204-fire-bolt/.
  SpellDetails parseDetails(String body) {
    final document = html_parser.parse(_cutCard(body));
    final article = document.querySelector('[itemprop="articleBody"]');
    if (article == null) {
      // Иногда сайт отдаёт страницу с пустым блоком карточки, повторный запрос обычно помогает.
      throw const DndSuMissingContentException('Не удалось найти описание заклинания на странице');
    }

    String? levelAndSchool;
    String? descriptionHtml;
    final params = <String, String>{};
    for (final item in article.querySelectorAll('ul.params > li')) {
      if (item.classes.contains('size-type-alignment')) {
        levelAndSchool = _cleanText(item.text);
      } else if (item.classes.contains('desc')) {
        descriptionHtml = (item.querySelector('[itemprop="description"]') ?? item).innerHtml.trim();
      } else {
        final label = item.querySelector('strong');
        if (label == null) continue;
        final key = _cleanText(label.text).replaceAll(':', '');
        label.remove();
        params[key] = _cleanText(item.text);
      }
    }

    return SpellDetails(
      levelAndSchool: levelAndSchool ?? '',
      castTime: params['Время накладывания'] ?? '',
      distance: params['Дистанция'] ?? '',
      components: params['Компоненты'] ?? '',
      duration: params['Длительность'] ?? '',
      classes: params['Классы'],
      subclasses: params['Подклассы'],
      source: document.querySelector('.card-title .source-plaque')?.attributes['title'],
      descriptionHtml: descriptionHtml ?? '',
    );
  }

  /// Большая часть страницы — комментарии (до сотен килобайт), разбираем только карточку.
  String _cutCard(String body) {
    final start = body.indexOf('<div class="cards-wrapper"');
    if (start == -1) return body;
    final end = body.indexOf('<section class="comments-block', start);
    if (end == -1) return body;
    return body.substring(start, end);
  }

  String _cleanText(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
}
