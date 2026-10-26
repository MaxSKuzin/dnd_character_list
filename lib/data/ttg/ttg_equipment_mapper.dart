import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Переводит ответы разделов `/weapons`, `/armors` и `/items` в предметы каталога.
@lazySingleton
class TtgEquipmentMapper {
  /// Категории `/items`, которые относятся к инструментам; остальное — снаряжение.
  static const toolCategories = {
    'TOOL': null,
    'ARTISANS_TOOLS': ToolCategory.craftsmenTool,
    'GAME_SET': ToolCategory.playSet,
    'MUSICAL_INSTRUMENTS': ToolCategory.musicalInstrument,
  };

  /// Категория `/items` с наборами снаряжения и наборами вроде «Набора для грима».
  static const setsCategory = 'SET';

  /// Категории снаряжения, которые показываются группами в каталоге. Порядок важен: у предмета может быть
  /// несколько категорий (амулет — и священный символ, и фокусировка), берётся первая — более узкая.
  static const gearGroups = {
    'AMMUNITION': 'Боеприпасы',
    'HOLY_SYMBOL': 'Священный символ',
    'DRUID_FOCUS': 'Фокусировка друидов',
    'FOCUSING': 'Магическая фокусировка',
    'CONTAINER': 'Контейнеры',
    'CLOTHES': 'Одежда',
    'EAT_DRINK': 'Еда и напитки',
    'LIGHT': 'Освещение',
  };

  /// [link] — ссылка из списка: в ответах по отдельным предметам её нет.
  Weapon weapon(String link, Map<String, dynamic> json) {
    final properties = (json['properties'] as List? ?? const [])
        .map((e) => ((e as Map)['name'] as String).toLowerCase().replaceAll('ё', 'е'))
        .toSet();
    bool has(String property) => properties.contains(property);
    final type = '${(json['type'] as Map?)?['name']}'.toLowerCase();
    final dice = _dice(json['damageDice']);
    final fixed = dice == null ? int.tryParse('${(json['damage'] as Map?)?['dice']}') : null;
    final twoHanded = _dice(json['twoHandDamageDice']);
    final isRanged = type.contains('дальнобойн');
    return Weapon(
      id: TtgText.normalizeLink(link),
      name: TtgText.names(json['name']).$1,
      damage: dice,
      damageMultiplier: dice == null ? 0 : json['numberDice'] ?? 1,
      fixedDamage: fixed,
      damageType: switch (json['damageType']) {
        'PIERCING' => DamageType.pricking,
        'BLUDGEONING' => DamageType.crushing,
        'SLASHING' => DamageType.chopping,
        _ => null,
      },
      kind: type.contains('прост')
          ? (isRanged ? WeaponKind.simpleRanged : WeaponKind.simpleMelee)
          : (isRanged ? WeaponKind.martialRanged : WeaponKind.martialMelee),
      type: has('двуручное')
          ? WeaponType.twoHanded
          : twoHanded != null
              ? WeaponType.universal
              : WeaponType.oneHanded,
      twoHandedDamage: twoHanded,
      weaponWeight: has('легкое')
          ? WeaponWeight.light
          : has('тяжелое')
              ? WeaponWeight.heavy
              : WeaponWeight.regular,
      isFencing: has('фехтовальное'),
      isThrown: has('метательное'),
      isReach: has('досягаемость'),
      isAmmunition: has('боеприпас'),
      isLoading: has('перезарядка'),
      isSpecial: has('особое') || json['special'] != null,
      minRange: json['minDistance'],
      maxRange: json['maxDistance'],
      cost: TtgText.parseCost(json['price']),
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  /// `d8` → к8.
  static Dice? _dice(Object? value) {
    final number = int.tryParse('$value'.replaceFirst('d', ''));
    return Dice.values.firstWhereOrNull((e) => e.value == number);
  }

  /// Доспех или щит.
  Object armor(String link, Map<String, dynamic> json) {
    final name = TtgText.names(json['name']).$1;
    final weight = (json['weight'] as num?)?.round() ?? 0;
    final cost = TtgText.parseCost(json['price']);
    if (json['typeRaw'] == 'SHIELD') {
      return Shield(name: name, defense: json['armorClassRaw'] ?? 2, weight: weight, cost: cost);
    }
    final armorClass = '${json['armorClass']}';
    return Armor(
      id: TtgText.normalizeLink(link),
      name: name,
      kind: switch (json['typeRaw']) {
        'LIGHT' => ArmorKind.light,
        'MEDIUM' => ArmorKind.medium,
        _ => ArmorKind.heavy,
      },
      protection: json['armorClassRaw'],
      dexterityLimit: !armorClass.contains('Лов')
          ? 0
          : int.tryParse(RegExp(r'макс\.\s*(\d+)').firstMatch(armorClass)?.group(1) ?? ''),
      strengthRequirement: json['requirement'],
      stealthDisadvantage: json['disadvantage'] == true,
      weight: weight,
      cost: cost,
    );
  }

  static const _toolsByLink = {
    "/items/thieves'_tools": ToolCategory.thievesTool,
    "/items/navigator's_tools": ToolCategory.navigatorTool,
    "/items/poisoner's_kit": ToolCategory.poisonerTool,
    '/items/disguise_kit': ToolCategory.makeupKit,
    '/items/forgery_kit': ToolCategory.falsificationKit,
    '/items/herbalism_kit': ToolCategory.foldOfLawn,
  };

  /// Категория инструмента по ссылке и категории `/items`; `null` — это не инструмент.
  static ToolCategory? toolCategory(String link, String? itemsCategory) =>
      _toolsByLink[TtgText.normalizeLink(link)] ?? toolCategories[itemsCategory];

  Tool tool(Map<String, dynamic> json, ToolCategory category) => Tool(
        category: category,
        name: TtgText.names(json['name']).$1,
        description: json['description'] ?? '',
        price: TtgText.parseCost(json['price']) ?? const Balance(0),
        weight: (json['weight'] as num?)?.toDouble(),
      );

  /// Наборы снаряжения («Набор путешественника»), в отличие от наборов-инструментов, называются «pack».
  static bool isPack(Map<String, dynamic> listItem) =>
      TtgText.names(listItem['name']).$2.toLowerCase().endsWith('pack');

  /// «Набор путешественника включает в себя: рюкзак, спальник… и бурдюк. В набор также входит…»
  /// Каждая вещь — ссылка на предмет и количество: «10 факелов» → 10 × `/items/torch`,
  /// «рационы на 10 дней» → 10 × `/items/rations_(1_day)`.
  EquipmentPack pack(String link, Map<String, dynamic> json) {
    final paragraphs = html_parser
        .parseFragment(json['description'] ?? '')
        .querySelectorAll('p')
        .map((e) => e.innerHtml.trim())
        .where((e) => TtgText.plainText(e).isNotEmpty && !TtgText.plainText(e).endsWith(':'))
        .toList();
    final contents = <EquipmentRef>[];
    for (final paragraph in paragraphs) {
      final extra = RegExp(r'также входит (.+?)\.?$').firstMatch(paragraph)?.group(1);
      final html = extra ?? paragraph.replaceFirst(RegExp(r'\.$'), '');
      final parts = extra != null ? [html] : TtgText.splitTopLevel(html.replaceFirst(RegExp(r' и (?!.* и )'), ', '));
      contents.addAll(parts.map(_packContent).where((e) => e.text.isNotEmpty));
    }
    return EquipmentPack(
      id: TtgText.normalizeLink(link),
      name: TtgText.names(json['name']).$1,
      cost: TtgText.parseCost(json['price']),
      contents: contents,
    );
  }

  /// Вещь из набора. Число в начале — количество, кроме мер длины («10 футов лески»).
  EquipmentRef _packContent(String html) {
    final text = TtgText.capitalize(TtgText.plainText(html));
    final href = html_parser.parseFragment(html).querySelector('a[href]')?.attributes['href'];
    final days = RegExp(r'на (\d+) (?:день|дня|дней)').firstMatch(text)?.group(1);
    final isLength = RegExp(r'^\d+\s+фут').hasMatch(text);
    return EquipmentRef(
      id: href == null ? null : TtgText.normalizeLink(href),
      text: text,
      quantity: int.tryParse(days ?? '') ?? (isLength ? null : TtgText.leadingNumber(text)) ?? 1,
    );
  }

  /// Предмет снаряжения из списка: стоимость и вес есть только в ответах по отдельным предметам,
  /// поэтому в каталоге их нет.
  Gear gear(Map<String, dynamic> listItem, {String? group}) => Gear(
        id: TtgText.normalizeLink(listItem['url']),
        name: TtgText.names(listItem['name']).$1,
        group: group,
      );
}
