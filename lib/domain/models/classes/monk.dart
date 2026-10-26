import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';

/// Монах по правилам https://5e14.ttg.club/classes/monk.
///
/// Монастырская традиция выбирается на 3 уровне. Тексты умений класса и традиции берутся с сайта и хранятся
/// в персонаже; в коде — защита и движение без доспехов, боевые искусства, очки ци и «Алмазная душа».
final class Monk extends Specialization {
  // Идентификаторы умений в таблице класса на ttg.club.
  static const martialArts = 'c92';
  static const ki = 'c93';
  static const abilityScoreImprovement = 'c97';

  /// «Алмазная душа»: владение всеми спасбросками.
  static const diamondSoulLevel = 14;

  // Столбцы таблицы класса.
  static const martialArtsColumn = 'Боевые искусства';
  static const kiPointsColumn = 'Очки ци';
  static const unarmoredMovementColumn = 'Скорость без доспехов';

  // Последние части ссылок на традиции на ttg.club, у которых есть механики в коде.
  static const drunkenMaster = 'drunken_master';
  static const mercy = 'mercy';

  static const _shortsword = '/weapons/shortsword';

  @override
  ClassKind get classKind => ClassKind.monk;

  /// Полученные умения класса и традиции с описаниями с сайта.
  final List<Peculiarity> features;

  final String? traditionId;
  final String? traditionName;

  final List<AbilityScoreImprovement> improvements;

  /// Кость боевых искусств из таблицы класса.
  final Dice martialArtsDice;

  /// Очки ци из таблицы класса (с 2 уровня).
  final int kiPoints;

  /// Прибавка к скорости без доспехов и щита, в футах (с 2 уровня).
  final int unarmoredMovement;

  Monk({
    required super.level,
    required super.isMain,
    required this.features,
    required this.martialArtsDice,
    this.traditionId,
    this.traditionName,
    this.improvements = const [],
    this.kiPoints = 0,
    this.unarmoredMovement = 0,
  });

  /// Кость боевых искусств на указанном уровне: «1к6» в таблице → к6.
  static Dice martialArtsDiceAt(ClassInfo info, int level) {
    final value = RegExp(r'к(\d+)').firstMatch(info.level(level).columns[martialArtsColumn] ?? '')?.group(1);
    return Dice.values.firstWhereOrNull((e) => e.value == int.tryParse(value ?? '')) ?? Dice.k4;
  }

  static int kiPointsAt(ClassInfo info, int level) => info.level(level).number(kiPointsColumn) ?? 0;

  /// Прибавка к скорости на указанном уровне: «+15 фт.» в таблице → 15, «—» → 0.
  static int unarmoredMovementAt(ClassInfo info, int level) =>
      int.tryParse(
          RegExp(r'\d+').firstMatch(info.level(level).columns[unarmoredMovementColumn] ?? '')?.group(0) ?? '') ??
      0;

  /// Умения класса и выбранной традиции на указанном уровне в виде особенностей персонажа.
  static List<Peculiarity> featuresAt(ClassInfo info, int level, {String? traditionId}) => [
        ...info.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
        ...?info.subclass(traditionId ?? '')?.featuresAt(level).map(
              (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
            ),
      ];

  /// Монашеское оружие: короткий меч и простое рукопашное оружие без свойств «двуручное» и «тяжёлое».
  static bool isMonkWeapon(Weapon weapon) =>
      weapon.proficiencyKey == _shortsword ||
      (weapon.kind == WeaponKind.simpleMelee && weapon.type != WeaponType.twoHanded && !weapon.isHeavy);

  /// Боевые искусства и движение без доспехов работают без доспеха и щита.
  static bool isUnarmored(Player player) => player.armor == null && player.shield == null;

  @override
  String get name => traditionName == null ? 'Монах' : 'Монах ($traditionName)';

  @override
  Dice get hitDice => Dice.k8;

  @override
  int get healthPerLevel => 5;

  @override
  int get startHealth => 8;

  /// «Защита без доспехов»: без доспеха и щита КД равен 10 + Ловкость + Мудрость.
  @override
  ArmorClass armorClass(Player player) {
    if (!isUnarmored(player)) return super.armorClass(player);
    return ArmorClass.of([
      ('Защита без доспехов', 10),
      ('Ловкость', player.dexterity.bonus),
      ('Мудрость', player.wisdom.bonus),
    ]);
  }

  @override
  int speedBonus(Player player) => isUnarmored(player) ? unarmoredMovement : 0;

  @override
  WeaponProficiency get weaponProficiency => const WeaponProficiency(simple: true, weapons: {_shortsword});

  @override
  List<StatKind> get chosenSaveThrows => const [StatKind.strength, StatKind.dexterity];

  @override
  List<StatKind> get grantedSaveThrows => level >= diamondSoulLevel ? StatKind.values : const [];

  /// Навыки традиций: «Пьяная техника» — Выступление, «Наставления милосердия» — Проницательность и Медицина.
  @override
  List<Skill> get grantedSkills => switch (traditionId) {
        drunkenMaster => const [Skill.performance],
        mercy => const [Skill.insight, Skill.medicine],
        _ => const [],
      };

  @override
  List<Peculiarity> get abilities => features;

  @override
  List<ChosenFeat> get feats => improvements.map((e) => e.feat).nonNulls.toList();

  @override
  List<ClassExtras> get classExtras => kiPoints > 0 ? const [ClassExtras.ci] : const [];

  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => kiPoints;

  @override
  List<ClassExtras> get shortRestExtras => const [ClassExtras.ci];

  @override
  String classExtraDescription(ClassExtras extra) =>
      features.firstWhereOrNull((e) => e.name == 'ЦИ')?.description ??
      'Очков ци: $kiPoints. Восстанавливаются после короткого или продолжительного отдыха.';

  @override
  Map<StatKind, int> get statBonuses {
    final bonuses = <StatKind, int>{};
    for (final improvement in improvements) {
      improvement.statBonuses.forEach((key, value) => bonuses[key] = (bonuses[key] ?? 0) + value);
    }
    return bonuses;
  }

  Monk copyWith({
    int? level,
    bool? isMain,
    List<Peculiarity>? features,
    String? traditionId,
    String? traditionName,
    List<AbilityScoreImprovement>? improvements,
    Dice? martialArtsDice,
    int? kiPoints,
    int? unarmoredMovement,
  }) =>
      Monk(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
        features: features ?? this.features,
        traditionId: traditionId ?? this.traditionId,
        traditionName: traditionName ?? this.traditionName,
        improvements: improvements ?? this.improvements,
        martialArtsDice: martialArtsDice ?? this.martialArtsDice,
        kiPoints: kiPoints ?? this.kiPoints,
        unarmoredMovement: unarmoredMovement ?? this.unarmoredMovement,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'level': level,
        'isMain': isMain,
        'features': features.map((e) => e.toJson()).toList(),
        'traditionId': traditionId,
        'traditionName': traditionName,
        'improvements': improvements.map((e) => e.toJson()).toList(),
        'martialArtsDice': martialArtsDice.toJson(),
        'kiPoints': kiPoints,
        'unarmoredMovement': unarmoredMovement,
      };

  static Monk fromJson(Map<String, dynamic> json) => Monk(
        level: json['level'],
        isMain: json['isMain'],
        features: (json['features'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        traditionId: json['traditionId'],
        traditionName: json['traditionName'],
        improvements: (json['improvements'] as List).map((e) => AbilityScoreImprovement.fromJson(e)).toList(),
        martialArtsDice: Dice.fromJson(json['martialArtsDice']),
        kiPoints: json['kiPoints'],
        unarmoredMovement: json['unarmoredMovement'],
      );
}
