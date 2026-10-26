import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

/// Драконий предок чародея «Наследия драконьей крови» и связанный с ним вид урона.
enum DragonAncestor {
  black(ElementalType.acid),
  blue(ElementalType.lightning),
  brass(ElementalType.fire),
  bronze(ElementalType.lightning),
  copper(ElementalType.acid),
  gold(ElementalType.fire),
  green(ElementalType.poison),
  red(ElementalType.fire),
  silver(ElementalType.cold),
  white(ElementalType.cold);

  const DragonAncestor(this.damageType);

  final ElementalType damageType;
}

/// Склонность «Божественной души» и заклинание, которое она даёт.
enum DivineAffinity {
  good('/spells/cure_wounds'),
  evil('/spells/inflict_wounds'),
  law('/spells/bless'),
  chaos('/spells/bane'),
  neutrality('/spells/protection_from_evil_and_good');

  const DivineAffinity(this.spellLink);

  final String spellLink;
}

/// Чародей по правилам https://5e14.ttg.club/classes/sorcerer.
///
/// Происхождение выбирается на 1 уровне. Тексты умений класса, происхождения и метамагии берутся с сайта
/// и хранятся в персонаже; в коде — только механики происхождений, которые нельзя вывести из текста.
final class Sorcerer extends Specialization {
  // Идентификаторы умений в таблице класса на ttg.club.
  static const fontOfMagic = 'c66';
  static const metamagicFeature = 'c67';
  static const abilityScoreImprovement = 'c68';

  /// «Чародейская разносторонность» (TCE): на уровнях «Увеличения характеристик» можно заменить
  /// вариант метамагии или заговор.
  static const sorcerousVersatility = 'c301';

  /// Столбец таблицы класса с числом единиц чародейства.
  static const sorceryPointsColumn = 'Единицы чародейства';

  /// «Источник магии»: стоимость создания ячейки в единицах чародейства; ячейки выше 5 уровня не создаются.
  static const spellSlotCost = {
    SpellSlot.level1: 2,
    SpellSlot.level2: 3,
    SpellSlot.level3: 5,
    SpellSlot.level4: 6,
    SpellSlot.level5: 7,
  };

  /// Стоимость вариантов метамагии в единицах чародейства (на сайте — только в тексте).
  /// У «Удвоенного заклинания» стоимость равна уровню заклинания (у заговора — 1), поэтому его нет в списке.
  static const metamagicCost = {
    '/options/careful_spell': 1,
    '/options/distant_spell': 1,
    '/options/empowered_spell': 1,
    '/options/extended_spell': 1,
    '/options/heightened_spell': 3,
    '/options/quickened_spell': 2,
    '/options/subtle_spell': 1,
    '/options/seeking_spell': 2,
    '/options/transmuted_spell': 1,
  };

  static const twinnedSpell = '/options/twinned_spell';

  // Последние части ссылок на происхождения на ttg.club.
  static const draconicBloodline = 'draconic';
  static const divineSoul = 'divine_soul';
  static const stormSorcery = 'storm';
  static const lunarSorcery = 'lunar';
  static const shadowMagic = 'shadow';

  /// «Драконья устойчивость»: КД без доспеха.
  static const draconicArmorClass = 13;

  /// Заклинания происхождений, которые на сайте перечислены только в тексте умений (у остальных есть
  /// таблица подкласса): «Лунное воплощение» — заклинания трёх фаз, «Лунный огонь» — заговор,
  /// «Глаза тьмы» теневой магии — «Тьма» на 3 уровне.
  static const _originSpellsInText = {
    lunarSorcery: {
      1: ['/spells/shield', '/spells/ray_of_sickness', '/spells/color_spray', '/spells/sacred_flame'],
      3: ['/spells/lesser_restoration', '/spells/blindness_or_deafness', '/spells/alter_self'],
      5: ['/spells/dispel_magic', '/spells/vampiric_touch', '/spells/phantom_steed'],
      7: ['/spells/death_ward', '/spells/confusion', '/spells/hallucinatory_terrain'],
      9: ["/spells/rary's_telepathic_bond", '/spells/hold_monster', '/spells/mislead'],
    },
    shadowMagic: {
      3: ['/spells/darkness'],
    },
  };

  static const _weapons = {
    '/weapons/dagger',
    '/weapons/dart',
    '/weapons/sling',
    '/weapons/quarterstaff',
    '/weapons/crossbow,_light',
  };

  @override
  ClassKind get classKind => ClassKind.sorcerer;

  /// Заклинания, выбранные из списка класса.
  final List<Spell> chosenSpells;

  /// Заклинания происхождения: известны всегда и не учитываются в числе известных заклинаний.
  final List<Spell> originSpells;

  /// Полученные умения класса и происхождения с описаниями с сайта.
  final List<Peculiarity> features;

  final String? originId;
  final String? originName;
  final DragonAncestor? dragonAncestor;
  final DivineAffinity? divineAffinity;

  /// Выбранные варианты метамагии (с 3 уровня).
  final List<Metamagic> metamagic;

  final List<AbilityScoreImprovement> improvements;

  /// Единицы чародейства из таблицы класса (с 2 уровня).
  final int sorceryPoints;

  Sorcerer({
    required super.level,
    required super.isMain,
    required this.chosenSpells,
    required this.features,
    this.originSpells = const [],
    this.originId,
    this.originName,
    this.dragonAncestor,
    this.divineAffinity,
    this.metamagic = const [],
    this.improvements = const [],
    this.sorceryPoints = 0,
  });

  /// Единицы чародейства на указанном уровне по таблице класса.
  static int sorceryPointsAt(ClassInfo info, int level) => info.level(level).number(sorceryPointsColumn) ?? 0;

  /// Сколько вариантов метамагии известно на указанном уровне: «Метамагия(3)» в таблице класса → 3.
  static int metamagicCountAt(ClassInfo info, int level) =>
      int.tryParse(info.featureValueAt(metamagicFeature, level) ?? '') ?? 0;

  /// Умения класса и выбранного происхождения на указанном уровне в виде особенностей персонажа.
  static List<Peculiarity> featuresAt(ClassInfo info, int level, {String? originId}) => [
        ...info.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
        ...?info.subclass(originId ?? '')?.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
      ];

  /// Ссылки на заклинания происхождения, известные к [level] уровню: из таблицы подкласса на сайте
  /// и из механик в коде.
  static List<String> originSpellLinks(
    ClassInfo info,
    int level, {
    required String? originId,
    DivineAffinity? divineAffinity,
  }) =>
      {
        ...?info.subclass(originId ?? '')?.spellsUpTo(level),
        ...?_originSpellsInText[originId]?.entries.where((e) => e.key <= level).expand((e) => e.value),
        if (originId == divineSoul && divineAffinity != null) divineAffinity.spellLink,
      }.toList();

  /// Классы, из списков которых чародей выбирает заклинания: «Божественная магия» добавляет список жреца.
  static List<ClassKind> spellListsFor(String? originId) => [
        ClassKind.sorcerer,
        if (originId == divineSoul) ClassKind.cliric,
      ];

  @override
  String get name => originName == null ? 'Чародей' : 'Чародей ($originName)';

  @override
  Dice get hitDice => Dice.k6;

  @override
  int get healthPerLevel => 4;

  @override
  int get startHealth => 6;

  bool get _isDraconic => originId == draconicBloodline;

  /// «Драконья устойчивость»: +1 хит за каждый уровень чародея.
  @override
  int hitPoints(Player player) => super.hitPoints(player) + (_isDraconic ? level : 0);

  /// «Драконья устойчивость»: без доспеха КД равен 13 + модификатор Ловкости.
  @override
  ArmorClass armorClass(Player player) {
    if (!_isDraconic || player.armor != null) return super.armorClass(player);
    return ArmorClass.of([('Драконья чешуя', draconicArmorClass), ('Ловкость', player.dexterity.bonus)]);
  }

  @override
  WeaponProficiency get weaponProficiency => const WeaponProficiency(weapons: _weapons);

  @override
  StatKind get spellKind => StatKind.charisma;

  @override
  List<StatKind> get chosenSaveThrows => const [StatKind.constitution, StatKind.charisma];

  @override
  List<Spell> get knownSpells => [...chosenSpells, ...originSpells.where((e) => !chosenSpells.contains(e))];

  /// Умения и выбранные варианты метамагии.
  @override
  List<Peculiarity> get abilities => [
        ...features,
        for (final option in metamagic)
          Peculiarity(
              name: 'МЕТАМАГИЯ: ${option.name.toUpperCase()}', description: option.descriptionHtml, isHtml: true),
      ];

  @override
  List<ChosenFeat> get feats => improvements.map((e) => e.feat).nonNulls.toList();

  @override
  List<ClassExtras> get classExtras => sorceryPoints > 0 ? const [ClassExtras.sorceryPoints] : const [];

  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => sorceryPoints;

  @override
  String classExtraDescription(ClassExtras extra) =>
      features.firstWhereOrNull((e) => e.name == 'ИСТОЧНИК МАГИИ')?.description ??
      'Единиц чародейства: $sorceryPoints. Восстанавливаются после продолжительного отдыха.';

  @override
  List<Language> get grantedLanguages => languagesFor(originId);

  /// Языки происхождения: драконий у «Наследия драконьей крови», Первичный у «Штормового колдовства».
  static List<Language> languagesFor(String? originId) => [
        if (originId == draconicBloodline) Language.draconic,
        if (originId == stormSorcery) Language.primordial,
      ];

  @override
  Map<StatKind, int> get statBonuses {
    final bonuses = <StatKind, int>{};
    for (final improvement in improvements) {
      improvement.statBonuses.forEach((key, value) => bonuses[key] = (bonuses[key] ?? 0) + value);
    }
    return bonuses;
  }

  Sorcerer copyWith({
    int? level,
    bool? isMain,
    List<Spell>? chosenSpells,
    List<Spell>? originSpells,
    List<Peculiarity>? features,
    List<Metamagic>? metamagic,
    List<AbilityScoreImprovement>? improvements,
    int? sorceryPoints,
  }) =>
      Sorcerer(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
        chosenSpells: chosenSpells ?? this.chosenSpells,
        originSpells: originSpells ?? this.originSpells,
        features: features ?? this.features,
        originId: originId,
        originName: originName,
        dragonAncestor: dragonAncestor,
        divineAffinity: divineAffinity,
        metamagic: metamagic ?? this.metamagic,
        improvements: improvements ?? this.improvements,
        sorceryPoints: sorceryPoints ?? this.sorceryPoints,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'level': level,
        'isMain': isMain,
        'chosenSpells': chosenSpells.map((e) => e.toJson()).toList(),
        'originSpells': originSpells.map((e) => e.toJson()).toList(),
        'features': features.map((e) => e.toJson()).toList(),
        'originId': originId,
        'originName': originName,
        'dragonAncestor': dragonAncestor?.name,
        'divineAffinity': divineAffinity?.name,
        'metamagic': metamagic.map((e) => e.toJson()).toList(),
        'improvements': improvements.map((e) => e.toJson()).toList(),
        'sorceryPoints': sorceryPoints,
      };

  static Sorcerer fromJson(Map<String, dynamic> json) => Sorcerer(
        level: json['level'],
        isMain: json['isMain'],
        chosenSpells: (json['chosenSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        originSpells: (json['originSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        features: (json['features'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        originId: json['originId'],
        originName: json['originName'],
        dragonAncestor: DragonAncestor.values.firstWhereOrNull((e) => e.name == json['dragonAncestor']),
        divineAffinity: DivineAffinity.values.firstWhereOrNull((e) => e.name == json['divineAffinity']),
        metamagic: (json['metamagic'] as List).map((e) => Metamagic.fromJson(e)).toList(),
        improvements: (json['improvements'] as List).map((e) => AbilityScoreImprovement.fromJson(e)).toList(),
        sorceryPoints: json['sorceryPoints'],
      );
}
