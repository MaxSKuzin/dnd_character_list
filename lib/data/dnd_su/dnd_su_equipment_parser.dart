import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_html.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Разбирает статьи раздела https://dnd.su/articles/inventory/.
@lazySingleton
class DndSuEquipmentParser {
  static const weaponsPath = '/articles/inventory/96-arms/';
  static const armorPath = '/articles/inventory/95-armor_and_shields/';
  static const gearPath = '/articles/inventory/98-equipment/';
  static const toolsPath = '/articles/inventory/100-tools/';

  Element _article(String body) {
    final article = html_parser.parse(DndSuHtml.cutArticle(body)).querySelector('[itemprop="articleBody"]');
    if (article == null || article.querySelector('table') == null) {
      throw const DndSuMissingContentException('Не удалось найти таблицу предметов на странице');
    }
    return article;
  }

  /// Ячейки строки таблицы с учётом colspan, например для двухколоночной таблицы инструментов.
  static List<Element?> _cells(Element row, int width) {
    final cells = <Element?>[];
    for (final cell in row.children) {
      final span = int.tryParse(cell.attributes['colspan'] ?? '') ?? 1;
      cells.add(cell);
      cells.addAll(List.filled(span - 1, null));
    }
    return [...cells, ...List.filled(width - cells.length.clamp(0, width), null)].take(width).toList();
  }

  static String _text(Element? element) => DndSuHtml.cleanText(element?.text ?? '');

  static String? _id(Element element) =>
      element.querySelector("[id^='weapon.'], [id^='armor.'], [id^='equipment.'], [id^='tool']")?.id;

  /// «1 500 зм.», «2 см», «4 мм» → стоимость; «-» → `null`.
  static Balance? parseCost(String text) {
    final match = RegExp(r'([\d\s]+)\s*(зм|см|мм|эм|пм)').firstMatch(text);
    if (match == null) return null;
    final value = int.parse(match.group(1)!.replaceAll(RegExp(r'\s'), ''));
    return switch (match.group(2)) {
      'зм' => Balance.fromGold(value),
      'см' => Balance.fromSilver(value),
      'мм' => Balance.fromCopper(value),
      'эм' => Balance.fromSilver(value * 5),
      _ => Balance.fromGold(value * 10),
    };
  }

  /// «4 фнт.», «1/4 фнт.», «1,5 фнт.», «½ фнт.» → фунты; «-» → `null`.
  static double? parseWeight(String text) {
    final normalized = text.replaceAll('½', '1/2').replaceAll('¼', '1/4').replaceAll(',', '.');
    final fraction = RegExp(r'(\d+)/(\d+)').firstMatch(normalized);
    if (fraction != null) return int.parse(fraction.group(1)!) / int.parse(fraction.group(2)!);
    return double.tryParse(RegExp(r'\d+(\.\d+)?').firstMatch(normalized)?.group(0) ?? '');
  }

  List<Weapon> parseWeapons(String body) {
    final table = _article(body).querySelector('table')!;
    final weapons = <Weapon>[];
    WeaponKind? kind;
    for (final row in table.querySelectorAll('tr').where((e) => !e.classes.contains('table_header'))) {
      if (row.children.length == 1) {
        final title = _text(row).toLowerCase();
        kind = switch (title) {
          _ when title.contains('простое') && title.contains('рукопашное') => WeaponKind.simpleMelee,
          _ when title.contains('простое') => WeaponKind.simpleRanged,
          _ when title.contains('рукопашное') => WeaponKind.martialMelee,
          _ => WeaponKind.martialRanged,
        };
        continue;
      }
      if (kind == null || row.children.length < 5) continue;
      final cells = row.children;
      final damage = RegExp(r'(\d+)к(\d+)\s+(\S+)').firstMatch(_text(cells[2]));
      final fixedDamage = RegExp(r'^(\d+)\s+(\S+)$').firstMatch(_text(cells[2]));
      final properties = _text(cells[4]).toLowerCase();
      final range = RegExp(r'дис\.\s*(\d+)/(\d+)').firstMatch(properties);
      final versatile = RegExp(r'универсальное\s*\((\d+)к(\d+)\)').firstMatch(properties);
      weapons.add(
        Weapon(
          id: _id(row),
          name: _text(cells[0]),
          cost: parseCost(_text(cells[1])),
          damage: damage == null ? null : _dice(damage.group(2)!),
          damageMultiplier: damage == null ? 0 : int.parse(damage.group(1)!),
          fixedDamage: fixedDamage == null ? null : int.parse(fixedDamage.group(1)!),
          damageType: _damageType(damage?.group(3) ?? fixedDamage?.group(2)),
          weight: parseWeight(_text(cells[3])),
          kind: kind,
          type: properties.contains('двуручное')
              ? WeaponType.twoHanded
              : versatile != null
                  ? WeaponType.universal
                  : WeaponType.oneHanded,
          twoHandedDamage: versatile == null ? null : _dice(versatile.group(2)!),
          weaponWeight: properties.contains('лёгкое') || properties.contains('легкое')
              ? WeaponWeight.light
              : properties.contains('тяжёлое') || properties.contains('тяжелое')
                  ? WeaponWeight.heavy
                  : WeaponWeight.regular,
          isFencing: properties.contains('фехтовальное'),
          isThrown: properties.contains('метательное'),
          isReach: properties.contains('досягаемость'),
          isAmmunition: properties.contains('боеприпас'),
          isLoading: properties.contains('перезарядка'),
          isSpecial: properties.contains('особое'),
          minRange: range == null ? null : int.parse(range.group(1)!),
          maxRange: range == null ? null : int.parse(range.group(2)!),
        ),
      );
    }
    return weapons;
  }

  static Dice _dice(String value) => Dice.values.firstWhere((e) => e.value == int.parse(value));

  static DamageType? _damageType(String? text) => switch (text) {
        'колющий' => DamageType.pricking,
        'дробящий' => DamageType.crushing,
        'рубящий' => DamageType.chopping,
        _ => null,
      };

  (List<Armor>, List<Shield>) parseArmor(String body) {
    final table = _article(body).querySelector('table')!;
    final armors = <Armor>[];
    final shields = <Shield>[];
    ArmorKind? kind;
    var isShield = false;
    for (final row in table.querySelectorAll('tr').where((e) => !e.classes.contains('table_header'))) {
      if (row.children.length == 1) {
        final title = _text(row).toLowerCase();
        isShield = title.contains('щит');
        kind = title.contains('лёгк') || title.contains('легк')
            ? ArmorKind.light
            : title.contains('средн')
                ? ArmorKind.medium
                : ArmorKind.heavy;
        continue;
      }
      if (row.children.length < 6 || _text(row.children.first) == 'Доспех') continue;
      final cells = row.children.map(_text).toList();
      final protection = int.parse(RegExp(r'\d+').firstMatch(cells[2])!.group(0)!);
      final weight = parseWeight(cells[5])?.round() ?? 0;
      if (isShield) {
        shields.add(Shield(name: cells[0], defense: protection, weight: weight, cost: parseCost(cells[1])));
        continue;
      }
      final dexterity = cells[2].contains('ЛОВ');
      armors.add(
        Armor(
          id: _id(row),
          name: cells[0],
          kind: kind!,
          protection: protection,
          dexterityLimit: !dexterity ? 0 : int.tryParse(RegExp(r'макс\.\s*(\d+)').firstMatch(cells[2])?.group(1) ?? ''),
          strengthRequirement: int.tryParse(cells[3]),
          stealthDisadvantage: cells[4].toLowerCase().contains('помеха'),
          weight: weight,
          cost: parseCost(cells[1]),
        ),
      );
    }
    return (armors, shields);
  }

  /// Таблицы предметов (третья таблица статьи — вместимость контейнеров) и наборы снаряжения.
  (List<Gear>, List<EquipmentPack>) parseGear(String body) {
    final article = _article(body);
    final gear = <Gear>[];
    for (final table in article.querySelectorAll('table').take(2)) {
      String? group;
      for (final row in table.querySelectorAll('tr').skip(1)) {
        if (row.children.length == 1) {
          group = _text(row);
          continue;
        }
        if (row.children.length < 3) continue;
        final cells = row.children;
        gear.add(
          Gear(
            id: _id(row),
            name: _text(cells[0]),
            group: cells[0].classes.contains('pad') ? group : null,
            cost: parseCost(_text(cells[1])),
            weight: _text(cells[2]),
          ),
        );
      }
    }
    return (gear, _parsePacks(article));
  }

  /// «<strong>Набор артиста (40 зм)</strong>. Включает рюкзак, спальник, 2 костюма… В набор также входит…»
  List<EquipmentPack> _parsePacks(Element article) => article
      .querySelectorAll('p')
      .map((paragraph) {
        final title = RegExp(r'^(Набор [^(]+?)\s*\(([^)]+)\)').firstMatch(_text(paragraph.querySelector('strong')));
        final contents = RegExp(r'Включает (.+?)\.(?:\s|$)').firstMatch(_text(paragraph));
        if (title == null || contents == null) return null;
        final extra = RegExp(r'также входит (.+?)\.').firstMatch(_text(paragraph))?.group(1);
        final items = DndSuHtml.splitTopLevel(contents.group(1)!.replaceFirst(RegExp(r' и (?!.* и )'), ', '));
        return EquipmentPack(
          name: title.group(1)!,
          cost: parseCost(title.group(2)!),
          contents: [...items, if (extra != null) extra].map(_capitalize).toList(),
        );
      })
      .nonNulls
      .toList();

  static String _capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  static const _toolKeywords = {
    'воровск': ToolCategory.thievesTool,
    'навигат': ToolCategory.navigatorTool,
    'отравит': ToolCategory.poisonerTool,
    'грим': ToolCategory.makeupKit,
    'фальсиф': ToolCategory.falsificationKit,
    'травник': ToolCategory.foldOfLawn,
  };

  /// Двухколоночная таблица: слева отдельные инструменты, игровые наборы и музыкальные
  /// инструменты, справа инструменты ремесленников. Описания берутся из разделов статьи.
  List<Tool> parseTools(String body) {
    final article = _article(body);
    final descriptions = _toolDescriptions(article);
    final tools = <Tool>[];
    final groups = <int, String?>{0: null, 1: null};
    for (final row in article.querySelector('table')!.querySelectorAll('tr').skip(1)) {
      final cells = _cells(row, 6);
      for (final side in [0, 1]) {
        final name = _text(cells[side * 3]);
        if (name.isEmpty) continue;
        if (cells[side * 3 + 1] == null && cells[side * 3]!.attributes['colspan'] != null) {
          groups[side] = name;
          continue;
        }
        final lower = name.toLowerCase();
        final group = groups[side]?.toLowerCase() ?? '';
        final category = side == 1
            ? ToolCategory.craftsmenTool
            : _toolKeywords.entries.firstWhereOrNull((e) => lower.contains(e.key))?.value ??
                (group.contains('музык')
                    ? ToolCategory.musicalInstrument
                    : group.contains('игров')
                        ? ToolCategory.playSet
                        : null);
        if (category == null) continue;
        tools.add(
          Tool(
            category: category,
            name: name,
            price: parseCost(_text(cells[side * 3 + 1])) ?? const Balance(0),
            weight: parseWeight(_text(cells[side * 3 + 2])),
            description: descriptions[lower] ?? descriptions[category.name] ?? '',
          ),
        );
      }
    }
    return tools;
  }

  /// Разделы «Музыкальный инструмент [XGE]», «Инструменты гончара [XGE]» и т.д. по названию
  /// инструмента и по категории.
  Map<String, String> _toolDescriptions(Element article) {
    final descriptions = <String, String>{};
    for (final header in article.querySelectorAll('h2')) {
      final title = _text(header).replaceAll(RegExp(r'\s*\[.*\]$'), '').toLowerCase();
      final content = <Element>[];
      for (var next = header.nextElementSibling;
          next != null && next.localName != 'h2';
          next = next.nextElementSibling) {
        if (next.localName != 'br') content.add(next);
      }
      final html = DndSuHtml.outerHtml(content);
      descriptions[title] = html;
      final category = title.contains('музык')
          ? ToolCategory.musicalInstrument
          : title.contains('игров')
              ? ToolCategory.playSet
              : _toolKeywords.entries.firstWhereOrNull((e) => title.contains(e.key))?.value;
      if (category != null) descriptions[category.name] = html;
    }
    return descriptions;
  }
}
