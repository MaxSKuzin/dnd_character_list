import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

/// Черта с ttg.club (например, https://5e14.ttg.club/feats/resilient).
class Feat {
  final int id;
  final String link;
  final String name;
  final String nameEn;

  /// Требование как на сайте, например «Харизма 13 или выше».
  final String? requirementText;
  final FeatRequirement requirement;
  final String descriptionHtml;

  /// Характеристики, одну из которых черта увеличивает на 1. Пусто — не увеличивает.
  final List<StatKind> statIncreaseOptions;

  const Feat({
    required this.id,
    required this.link,
    required this.name,
    required this.nameEn,
    required this.requirementText,
    required this.requirement,
    required this.descriptionHtml,
    required this.statIncreaseOptions,
  });

  /// Английское имя из ссылки: `/feats/resilient` → `resilient`.
  String get slug => link.split('/').last;

  // Эффекты, которые нельзя вывести из текста на сайте.

  /// «Устойчивый»: владение спасбросками выбранной характеристики.
  bool get grantsSavingThrow => slug == 'resilient';

  /// «Одарённый»: три навыка на выбор.
  int get skillChoices => slug == 'skilled' ? 3 : 0;

  /// «Языковед»: три языка на выбор.
  int get languageChoices => slug == 'linguist' ? 3 : 0;

  /// «Мастер оружия»: владение четырьмя видами простого или воинского оружия.
  int get weaponChoices => slug == 'weapon_master' ? 4 : 0;

  /// «Посвящённый в магию»: два заговора и заклинание 1 уровня выбранного класса.
  bool get grantsMagicInitiate => slug == 'magic_initiate';

  int get hitPointsPerLevel => slug == 'tough' ? 2 : 0;

  int get initiativeBonus => slug == 'alert' ? 5 : 0;

  int get speedBonus => slug == 'mobile' ? 10 : 0;

  /// «Внимательный»: +5 к пассивным Мудрости (Восприятие) и Интеллекту (Расследование).
  int get passiveBonus => slug == 'observant' ? 5 : 0;

  ArmorProficiency? get armorProficiency => switch (slug) {
        'lightly_armored' => ArmorProficiency.light,
        'moderately_armored' => ArmorProficiency.medium,
        'heavily_armored' => ArmorProficiency.heavy,
        _ => null,
      };

  @override
  bool operator ==(Object other) => other is Feat && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'name': name,
        'nameEn': nameEn,
        'requirementText': requirementText,
        'requirement': requirement.toJson(),
        'descriptionHtml': descriptionHtml,
        'statIncreaseOptions': statIncreaseOptions.map((e) => e.name).toList(),
      };

  factory Feat.fromJson(Map<String, dynamic> json) => Feat(
        id: json['id'],
        link: json['link'],
        name: json['name'],
        nameEn: json['nameEn'],
        requirementText: json['requirementText'],
        requirement: FeatRequirement.fromJson(json['requirement']),
        descriptionHtml: json['descriptionHtml'],
        statIncreaseOptions: (json['statIncreaseOptions'] as List).map((e) => StatKind.values.byName(e)).toList(),
      );
}

class FeatRequirement {
  /// Достаточно значения 13 и выше хотя бы одной из характеристик.
  final List<StatKind> minimumStats;
  final bool spellcasting;
  final ArmorProficiency? armor;

  static const minimumStatValue = 13;

  const FeatRequirement({
    this.minimumStats = const [],
    this.spellcasting = false,
    this.armor,
  });

  /// Почему персонаж не может взять черту, или `null`, если требования выполнены.
  String? unmetReason(Player player) {
    if (minimumStats.isNotEmpty && minimumStats.every((e) => player.stats[e]!.value < minimumStatValue)) {
      return 'Нужно значение $minimumStatValue или выше';
    }
    if (spellcasting && !player.canCastSpells) return 'Нужно уметь накладывать заклинания';
    if (armor != null && !player.armorProficiencies.contains(armor)) return 'Нужно владение доспехами';
    return null;
  }

  Map<String, dynamic> toJson() => {
        'minimumStats': minimumStats.map((e) => e.name).toList(),
        'spellcasting': spellcasting,
        'armor': armor?.name,
      };

  factory FeatRequirement.fromJson(Map<String, dynamic> json) => FeatRequirement(
        minimumStats: (json['minimumStats'] as List).map((e) => StatKind.values.byName(e)).toList(),
        spellcasting: json['spellcasting'],
        armor: json['armor'] == null ? null : ArmorProficiency.values.byName(json['armor']),
      );
}

/// Взятая черта вместе со сделанными при этом выборами.
class ChosenFeat {
  final Feat feat;
  final StatKind? increasedStat;
  final List<Skill> skills;
  final List<Language> languages;

  /// Виды оружия «Мастера оружия» по [Weapon.proficiencyKey].
  final List<String> weapons;

  /// Класс, из списка которого взяты заклинания «Посвящённого в магию».
  final ClassKind? spellsClass;
  final List<Spell> spells;

  const ChosenFeat({
    required this.feat,
    this.increasedStat,
    this.skills = const [],
    this.languages = const [],
    this.weapons = const [],
    this.spellsClass,
    this.spells = const [],
  });

  /// Для «Устойчивого» выбранная характеристика также даёт владение спасброском.
  StatKind? get savingThrow => feat.grantsSavingThrow ? increasedStat : null;

  Map<String, dynamic> toJson() => {
        'feat': feat.toJson(),
        'increasedStat': increasedStat?.name,
        'skills': skills.map((e) => e.name).toList(),
        'languages': languages.map((e) => e.name).toList(),
        'weapons': weapons,
        'spellsClass': spellsClass?.name,
        'spells': spells.map((e) => e.toJson()).toList(),
      };

  factory ChosenFeat.fromJson(Map<String, dynamic> json) => ChosenFeat(
        feat: Feat.fromJson(json['feat']),
        increasedStat: json['increasedStat'] == null ? null : StatKind.values.byName(json['increasedStat']),
        skills: (json['skills'] as List).map((e) => Skill.values.byName(e)).toList(),
        languages: (json['languages'] as List).map((e) => Language.values.byName(e)).toList(),
        weapons: (json['weapons'] as List).cast<String>(),
        spellsClass: json['spellsClass'] == null ? null : ClassKind.values.byName(json['spellsClass']),
        spells: (json['spells'] as List).map((e) => Spell.fromJson(e)).toList(),
      );
}

/// Выбор на уровне с умением «Увеличение характеристик»: +2 к характеристикам или черта.
class AbilityScoreImprovement {
  final int level;
  final Map<StatKind, int> stats;
  final ChosenFeat? feat;

  const AbilityScoreImprovement({
    required this.level,
    this.stats = const {},
    this.feat,
  });

  Map<StatKind, int> get statBonuses => {
        ...stats,
        if (feat?.increasedStat case final stat?) stat: (stats[stat] ?? 0) + 1,
      };

  Map<String, dynamic> toJson() => {
        'level': level,
        'stats': stats.map((key, value) => MapEntry(key.name, value)),
        'feat': feat?.toJson(),
      };

  factory AbilityScoreImprovement.fromJson(Map<String, dynamic> json) => AbilityScoreImprovement(
        level: json['level'],
        stats: (json['stats'] as Map).map((key, value) => MapEntry(StatKind.values.byName(key), value as int)),
        feat: json['feat'] == null ? null : ChosenFeat.fromJson(json['feat']),
      );
}
