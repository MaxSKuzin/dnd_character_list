import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

/// Воин по правилам https://5e14.ttg.club/classes/fighter.
///
/// Боевой стиль выбирается на 1 уровне, воинский архетип — на 3. Тексты умений класса и архетипа берутся
/// с сайта и хранятся в персонаже; в коде — боевые стили, ресурсы умений, «Дополнительная атака» и механики
/// чемпиона и мастера боевых искусств.
final class Fighter extends Specialization {
  // Идентификаторы умений в таблице класса на ttg.club.
  static const fightingStyleFeature = 'c84';
  static const actionSurgeFeature = 'c86';
  static const abilityScoreImprovement = 'c88';

  /// «Военная разносторонность» (TCE): на уровнях «Увеличения характеристик» можно заменить боевой стиль.
  static const martialVersatility = 'c289';
  static const indomitableFeature = 'c90';

  // Последние части ссылок на архетипы на ttg.club, у которых есть механики в коде.
  static const champion = 'champion';
  static const battleMaster = 'battle_master';

  /// Чемпион: «Выдающийся атлет» и «Дополнительный боевой стиль».
  static const remarkableAthleteLevel = 7;
  static const additionalFightingStyleLevel = 10;

  /// Мастер боевых искусств: четыре кости превосходства на 3 уровне и ещё по одной на 7 и 15
  /// («Боевое превосходство»); к10 с 10 уровня и к12 с 18 («Улучшенное боевое превосходство» PHB).
  static int superiorityDiceCountAt(int level) => level < 3 ? 0 : 4 + (level >= 7 ? 1 : 0) + (level >= 15 ? 1 : 0);

  static Dice superiorityDieAt(int level) => level >= 18 ? Dice.k12 : (level >= 10 ? Dice.k10 : Dice.k8);

  /// Приёмы мастера боевых искусств: три на 3 уровне и ещё по два на 7, 10 и 15 («Боевое превосходство»).
  static int battleMasterManeuversAt(int level) => level < 3 ? 0 : 3 + [7, 10, 15].where((e) => level >= e).length * 2;

  /// Сколько приёмов знает воин: мастера боевых искусств и один от стиля «Превосходная техника».
  static int maneuversCount({required int level, String? archetypeId, required List<FightingStyle> styles}) =>
      (archetypeId == battleMaster ? battleMasterManeuversAt(level) : 0) +
      (styles.contains(FightingStyle.superiorTechnique) ? 1 : 0);

  @override
  ClassKind get classKind => ClassKind.warrior;

  /// Полученные умения класса и архетипа с описаниями с сайта.
  final List<Peculiarity> features;

  final String? archetypeId;
  final String? archetypeName;

  @override
  final List<FightingStyle> fightingStyles;

  final List<AbilityScoreImprovement> improvements;

  /// Известные приёмы с описаниями с сайта.
  final List<Maneuver> maneuvers;

  /// Использований «Всплеска действий» и «Упорного» по таблице класса.
  final int actionSurgeUses;
  final int indomitableUses;

  Fighter({
    required super.level,
    required super.isMain,
    required this.features,
    required this.fightingStyles,
    this.archetypeId,
    this.archetypeName,
    this.improvements = const [],
    this.maneuvers = const [],
    this.actionSurgeUses = 0,
    this.indomitableUses = 0,
  });

  /// Число использований из подписи умения в таблице: «Всплеск действий(два использования)» → 2.
  static int usesAt(ClassInfo info, String featureId, int level) {
    if (!info.levels.where((e) => e.level <= level).any((e) => e.hasFeature(featureId))) return 0;
    final word = info.featureValueAt(featureId, level)?.split(' ').first.toLowerCase();
    return switch (word) {
      'два' || '2' => 2,
      'три' || '3' => 3,
      _ => 1,
    };
  }

  /// Умения класса и выбранного архетипа на указанном уровне в виде особенностей персонажа.
  static List<Peculiarity> featuresAt(ClassInfo info, int level, {String? archetypeId}) => [
        ...info.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
        ...?info.subclass(archetypeId ?? '')?.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
      ];

  @override
  String get name => archetypeName == null ? 'Воин' : 'Воин ($archetypeName)';

  @override
  Dice get hitDice => Dice.k10;

  @override
  int get healthPerLevel => 6;

  @override
  int get startHealth => 10;

  @override
  FightingStyle? get fightingStyle => fightingStyles.firstOrNull;

  @override
  bool get canUseTwoWeapons => fightingStyles.contains(FightingStyle.twoWeaponFighting);

  @override
  List<ArmorProficiency> get armorProficiencies =>
      const [ArmorProficiency.light, ArmorProficiency.medium, ArmorProficiency.heavy, ArmorProficiency.shields];

  @override
  WeaponProficiency get weaponProficiency => const WeaponProficiency(simple: true, martial: true);

  @override
  List<StatKind> get chosenSaveThrows => const [StatKind.strength, StatKind.constitution];

  /// «Дополнительная атака»: две атаки с 5 уровня, три с 11, четыре с 20.
  @override
  int get attacksPerAction => level >= 20 ? 4 : (level >= 11 ? 3 : (level >= 5 ? 2 : 1));

  /// «Выдающийся атлет»: половина бонуса мастерства, округлённая вверх, к проверкам Силы, Ловкости
  /// и Телосложения без владения.
  @override
  int unskilledCheckBonus(StatKind stat, int proficiencyBonus) {
    const athleticStats = [StatKind.strength, StatKind.dexterity, StatKind.constitution];
    if (archetypeId == champion && level >= remarkableAthleteLevel && athleticStats.contains(stat)) {
      return (proficiencyBonus + 1) ~/ 2;
    }
    return super.unskilledCheckBonus(stat, proficiencyBonus);
  }

  /// Боевые стили, умения и приёмы.
  @override
  List<Peculiarity> get abilities => [
        for (final style in fightingStyles)
          Peculiarity(name: 'БОЕВОЙ СТИЛЬ: ${style.title.toUpperCase()}', description: style.description, isHtml: true),
        ...features,
        for (final maneuver in maneuvers)
          Peculiarity(
              name: 'ПРИЁМ: ${maneuver.name.toUpperCase()}', description: maneuver.descriptionHtml, isHtml: true),
      ];

  @override
  List<ChosenFeat> get feats => improvements.map((e) => e.feat).nonNulls.toList();

  int get _superiorityDice =>
      (archetypeId == battleMaster ? superiorityDiceCountAt(level) : 0) +
      (fightingStyles.contains(FightingStyle.superiorTechnique) ? 1 : 0);

  @override
  List<ClassExtras> get classExtras => [
        ClassExtras.secondWind,
        if (actionSurgeUses > 0) ClassExtras.actionSurge,
        if (indomitableUses > 0) ClassExtras.indomitable,
        if (_superiorityDice > 0) ClassExtras.superiorityDice,
      ];

  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => switch (extra) {
        ClassExtras.secondWind => 1,
        ClassExtras.actionSurge => actionSurgeUses,
        ClassExtras.indomitable => indomitableUses,
        ClassExtras.superiorityDice => _superiorityDice,
        _ => 0,
      };

  /// «Упорный» восстанавливается только продолжительным отдыхом.
  @override
  List<ClassExtras> get shortRestExtras =>
      const [ClassExtras.secondWind, ClassExtras.actionSurge, ClassExtras.superiorityDice];

  @override
  String classExtraDescription(ClassExtras extra) {
    String? feature(String name) => features.firstWhereOrNull((e) => e.name == name)?.description;
    return switch (extra) {
      ClassExtras.secondWind => feature('ВТОРОЕ ДЫХАНИЕ') ?? 'Бонусным действием восстановите 1к10 + $level хитов.',
      ClassExtras.actionSurge => feature('ВСПЛЕСК ДЕЙСТВИЙ') ?? 'Одно дополнительное действие в свой ход.',
      ClassExtras.indomitable => feature('УПОРНЫЙ') ?? 'Переброс проваленного спасброска.',
      ClassExtras.superiorityDice => [
          '<p><strong>Кость превосходства:</strong> ${superiorityDieAt(level).name}'
              '${fightingStyles.contains(FightingStyle.superiorTechnique) ? ' (одна кость к6 — от стиля «Превосходная техника»)' : ''}.</p>',
          if (maneuvers.isNotEmpty) ...[
            '<p><strong>Известные приёмы</strong></p>',
            for (final maneuver in maneuvers) '<p><strong>${maneuver.name}.</strong></p>${maneuver.descriptionHtml}',
          ] else
            feature('БОЕВОЕ ПРЕВОСХОДСТВО') ?? '',
        ].join(),
      _ => '',
    };
  }

  @override
  Map<StatKind, int> get statBonuses {
    final bonuses = <StatKind, int>{};
    for (final improvement in improvements) {
      improvement.statBonuses.forEach((key, value) => bonuses[key] = (bonuses[key] ?? 0) + value);
    }
    return bonuses;
  }

  Fighter copyWith({
    int? level,
    bool? isMain,
    List<Peculiarity>? features,
    List<FightingStyle>? fightingStyles,
    String? archetypeId,
    String? archetypeName,
    List<AbilityScoreImprovement>? improvements,
    List<Maneuver>? maneuvers,
    int? actionSurgeUses,
    int? indomitableUses,
  }) =>
      Fighter(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
        features: features ?? this.features,
        fightingStyles: fightingStyles ?? this.fightingStyles,
        archetypeId: archetypeId ?? this.archetypeId,
        archetypeName: archetypeName ?? this.archetypeName,
        improvements: improvements ?? this.improvements,
        maneuvers: maneuvers ?? this.maneuvers,
        actionSurgeUses: actionSurgeUses ?? this.actionSurgeUses,
        indomitableUses: indomitableUses ?? this.indomitableUses,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'level': level,
        'isMain': isMain,
        'features': features.map((e) => e.toJson()).toList(),
        'fightingStyles': fightingStyles.map((e) => e.name).toList(),
        'archetypeId': archetypeId,
        'archetypeName': archetypeName,
        'improvements': improvements.map((e) => e.toJson()).toList(),
        'maneuvers': maneuvers.map((e) => e.toJson()).toList(),
        'actionSurgeUses': actionSurgeUses,
        'indomitableUses': indomitableUses,
      };

  static Fighter fromJson(Map<String, dynamic> json) => Fighter(
        level: json['level'],
        isMain: json['isMain'],
        features: (json['features'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        fightingStyles: (json['fightingStyles'] as List).map((e) => FightingStyle.fromName(e)).toList(),
        archetypeId: json['archetypeId'],
        archetypeName: json['archetypeName'],
        improvements: (json['improvements'] as List).map((e) => AbilityScoreImprovement.fromJson(e)).toList(),
        maneuvers: (json['maneuvers'] as List).map((e) => Maneuver.fromJson(e)).toList(),
        actionSurgeUses: json['actionSurgeUses'],
        indomitableUses: json['indomitableUses'],
      );
}
