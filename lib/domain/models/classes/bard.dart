import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

/// Бард по правилам https://5e14.ttg.club/classes/bard.
///
/// Тексты умений берутся со страницы класса в момент получения уровня и хранятся в
/// персонаже, поэтому лист работает без сети. В коде описаны только механики выбора.
final class Bard extends Specialization {
  // Идентификаторы умений в таблице класса на ttg.club.
  static const bardicInspiration = 'c1';
  static const expertiseFeature = 'c5';
  static const abilityScoreImprovement = 'c6';
  static const magicalSecrets = 'c9';

  /// «Бардовская разносторонность» (TCE): на уровнях «Увеличения характеристик» можно заменить заговор.
  static const bardicVersatility = 'c288';

  static const valorCollege = 'valor';
  static const loreCollege = 'lore';
  static const swordsCollege = 'swords';

  /// Уровень, на котором коллегия знаний даёт «Дополнительные тайны магии».
  static const loreAdditionalSecretsLevel = 6;

  static const fontOfInspirationLevel = 5;

  /// Сколько навыков даёт коллегия знаний и сколько заклинаний — одни «Тайны магии».
  static const loreSkillsCount = 3;
  static const magicalSecretsCount = 2;
  static const expertiseCount = 2;

  @override
  ClassKind get classKind => ClassKind.bard;

  @override
  final List<Spell> knownSpells;

  /// Полученные умения класса и коллегии с описаниями с сайта.
  final List<Peculiarity> features;

  final String? collegeId;
  final String? collegeName;

  /// Боевой стиль коллегии мечей.
  @override
  final FightingStyle? fightingStyle;

  @override
  final List<Skill> expertise;

  /// Навыки коллегии знаний.
  final List<Skill> collegeSkills;

  final List<AbilityScoreImprovement> improvements;

  final Dice inspirationDice;

  Bard({
    required super.level,
    required super.isMain,
    required this.knownSpells,
    required this.features,
    required this.inspirationDice,
    this.collegeId,
    this.collegeName,
    this.fightingStyle,
    this.expertise = const [],
    this.collegeSkills = const [],
    this.improvements = const [],
  });

  /// Кость вдохновения из таблицы класса: «Вдохновение барда (к8)» → к8.
  static Dice inspirationDiceAt(ClassInfo info, int level) {
    final value = RegExp(r'к(\d+)').firstMatch(info.featureValueAt(bardicInspiration, level) ?? '')?.group(1);
    return Dice.values.firstWhereOrNull((e) => e.value == int.tryParse(value ?? '')) ?? Dice.k6;
  }

  /// Умения класса и выбранной коллегии на указанном уровне в виде особенностей персонажа.
  static List<Peculiarity> featuresAt(ClassInfo info, int level, {String? collegeId}) => [
        ...info.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
        ...?info.subclass(collegeId ?? '')?.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
      ];

  Bard copyWith({
    int? level,
    bool? isMain,
    List<Spell>? knownSpells,
    List<Peculiarity>? features,
    Dice? inspirationDice,
    String? collegeId,
    String? collegeName,
    FightingStyle? fightingStyle,
    List<Skill>? expertise,
    List<Skill>? collegeSkills,
    List<AbilityScoreImprovement>? improvements,
  }) =>
      Bard(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
        knownSpells: knownSpells ?? this.knownSpells,
        features: features ?? this.features,
        inspirationDice: inspirationDice ?? this.inspirationDice,
        collegeId: collegeId ?? this.collegeId,
        collegeName: collegeName ?? this.collegeName,
        fightingStyle: fightingStyle ?? this.fightingStyle,
        expertise: expertise ?? this.expertise,
        collegeSkills: collegeSkills ?? this.collegeSkills,
        improvements: improvements ?? this.improvements,
      );

  @override
  String get name => collegeName == null ? 'Бард' : 'Бард ($collegeName)';

  @override
  Dice get hitDice => Dice.k8;

  @override
  int get healthPerLevel => 5;

  @override
  int get startHealth => 8;

  @override
  StatKind get spellKind => StatKind.charisma;

  @override
  List<StatKind> get chosenSaveThrows => const [StatKind.dexterity, StatKind.charisma];

  @override
  List<ArmorProficiency> get armorProficiencies => [
        ArmorProficiency.light,
        if (collegeId == valorCollege || collegeId == swordsCollege) ArmorProficiency.medium,
        if (collegeId == valorCollege) ArmorProficiency.shields,
      ];

  /// Простое оружие, длинные и короткие мечи, рапиры, ручные арбалеты; коллегия доблести даёт
  /// воинское оружие, коллегия мечей — скимитары.
  @override
  WeaponProficiency get weaponProficiency => WeaponProficiency(
        simple: true,
        martial: collegeId == valorCollege,
        weapons: {
          '/weapons/longsword',
          '/weapons/shortsword',
          '/weapons/rapier',
          '/weapons/crossbow,_hand',
          if (collegeId == swordsCollege) '/weapons/scimitar',
        },
      );

  @override
  bool get hasJackOfAllTrades => level >= 2;

  @override
  List<Skill> get grantedSkills => collegeSkills;

  @override
  List<ChosenFeat> get feats => improvements.map((e) => e.feat).nonNulls.toList();

  @override
  Map<StatKind, int> get statBonuses {
    final bonuses = <StatKind, int>{};
    for (final improvement in improvements) {
      improvement.statBonuses.forEach((key, value) => bonuses[key] = (bonuses[key] ?? 0) + value);
    }
    return bonuses;
  }

  @override
  List<Peculiarity> get abilities => features;

  @override
  final List<ClassExtras> classExtras = const [ClassExtras.inspiration];

  /// Количество вдохновений равно модификатору Харизмы, но не меньше одного.
  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => max(1, player.charisma.bonus);

  /// «Источник вдохновения»: с 5 уровня вдохновение восстанавливается и коротким отдыхом.
  @override
  List<ClassExtras> get shortRestExtras => level >= fontOfInspirationLevel ? const [ClassExtras.inspiration] : const [];

  @override
  String classExtraDescription(ClassExtras extra) =>
      features.firstWhereOrNull((e) => e.name == 'ВДОХНОВЕНИЕ БАРДА')?.description ??
      'Кость бардовского вдохновения — ${inspirationDice.name}.';

  @override
  bool get canUseTwoWeapons => fightingStyle == FightingStyle.twoWeaponFighting;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'level': level,
        'isMain': isMain,
        'knownSpells': knownSpells.map((e) => e.toJson()).toList(),
        'features': features.map((e) => e.toJson()).toList(),
        'inspirationDice': inspirationDice.toJson(),
        'collegeId': collegeId,
        'collegeName': collegeName,
        'fightingStyle': fightingStyle?.name,
        'expertise': expertise.map((e) => e.name).toList(),
        'collegeSkills': collegeSkills.map((e) => e.name).toList(),
        'improvements': improvements.map((e) => e.toJson()).toList(),
      };

  static Bard fromJson(Map<String, dynamic> json) => Bard(
        level: json['level'],
        isMain: json['isMain'],
        knownSpells: (json['knownSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        features: (json['features'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        inspirationDice: Dice.fromJson(json['inspirationDice']),
        collegeId: json['collegeId'],
        collegeName: json['collegeName'],
        fightingStyle: json['fightingStyle'] == null ? null : FightingStyle.fromName(json['fightingStyle']),
        expertise: (json['expertise'] as List).map((e) => Skill.values.byName(e)).toList(),
        collegeSkills: (json['collegeSkills'] as List).map((e) => Skill.values.byName(e)).toList(),
        improvements: (json['improvements'] as List).map((e) => AbilityScoreImprovement.fromJson(e)).toList(),
      );
}
