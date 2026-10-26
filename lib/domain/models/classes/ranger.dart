import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

/// Следопыт по правилам https://5e14.ttg.club/classes/ranger.
///
/// Тексты умений класса и архетипа берутся с сайта и хранятся в персонаже. У четырёх умений «Книги игрока» есть
/// замены из «Котла Таши» — игрок выбирает вариант при получении умения ([tceFeatures]). В коде — выборы
/// умений (избранные враги и местности, «Хитрец»), ресурсы, заклинания архетипа и «Изначального чутья».
final class Ranger extends Specialization {
  // Идентификаторы умений в таблице класса на ttg.club.
  static const favoredEnemy = 'c51';
  static const naturalExplorer = 'c52';
  static const fightingStyleFeature = 'c53';
  static const primevalAwareness = 'c56';
  static const abilityScoreImprovement = 'c57';
  static const hideInPlainSight = 'c60';

  // Замены из «Котла Таши».
  static const favoredFoe = 'c322';
  static const deftExplorer = 'c323';
  static const primalAwareness = 'c324';
  static const martialVersatility = 'c325';
  static const naturesVeil = 'c328';

  /// Части «Искусного исследователя»: «Хитрец» (1), «Бродяга» (6), «Неутомимый» (10).
  static const canny = 'c329';
  static const roving = 'c330';
  static const tireless = 'c332';

  /// Умение «Книги игрока» → его замена из «Котла Таши».
  static const replacements = {
    favoredEnemy: favoredFoe,
    naturalExplorer: deftExplorer,
    primevalAwareness: primalAwareness,
    hideInPlainSight: naturesVeil,
  };

  static const _deftExplorerParts = {canny, roving, tireless};

  /// Виды избранных врагов («Избранный враг»). Гуманоидов выбирают двумя расами.
  static const enemyTypes = [
    'Аберрации',
    'Великаны',
    'Драконы',
    'Звери',
    'Исчадия',
    'Конструкты',
    'Монстры',
    'Небожители',
    'Нежить',
    'Растения',
    'Слизи',
    'Феи',
    'Элементали',
    twoHumanoidRaces,
  ];

  /// Вместо вида врага можно выбрать две гуманоидные расы; запись — «Гуманоиды: орки и гноллы».
  static const twoHumanoidRaces = 'Две гуманоидные расы';
  static const _humanoidsPrefix = 'Гуманоиды: ';

  /// Гуманоидные расы «Книги игрока» и «Бестиария».
  static const humanoidRaces = [
    'люди',
    'эльфы',
    'дроу',
    'дварфы',
    'полурослики',
    'гномы',
    'тифлинги',
    'драконорождённые',
    'орки',
    'гоблины',
    'хобгоблины',
    'багбиры',
    'кобольды',
    'гноллы',
    'людоящеры',
    'сахуагины',
    'тритоны',
    'куо-тоа',
    'гитьянки',
    'гитцерай',
  ];

  static String humanoidsEnemy(String first, String second) => '$_humanoidsPrefix$first и $second';

  /// Гуманоидные расы, уже выбранные избранными врагами.
  static List<String> chosenHumanoids(List<String> enemies) => [
        for (final enemy in enemies)
          if (enemy.startsWith(_humanoidsPrefix)) ...enemy.substring(_humanoidsPrefix.length).split(' и '),
      ];

  /// Виды известной местности («Исследователь природы»).
  static const terrains = ['Арктика', 'Болота', 'Горы', 'Леса', 'Луга', 'Побережье', 'Подземье', 'Пустыня'];

  /// «Изначальное чутьё»: заклинания по уровням следопыта (на сайте — только в тексте умения).
  static const primalAwarenessSpells = {
    3: '/spells/speak_with_animals',
    5: '/spells/beast_sense',
    9: '/spells/speak_with_plants',
    13: '/spells/locate_creature',
    17: '/spells/commune_with_nature',
  };

  /// «Бродяга»: +5 футов к скорости.
  static const rovingSpeed = 5;

  @override
  ClassKind get classKind => ClassKind.ranger;

  /// Полученные умения класса и архетипа с описаниями с сайта.
  final List<Peculiarity> features;

  final String? archetypeId;
  final String? archetypeName;

  /// Выбранные замены из «Котла Таши» — идентификаторы умений ([replacements]).
  final Set<String> tceFeatures;

  /// Избранные враги и известные местности (варианты «Книги игрока»).
  final List<String> favoredEnemies;
  final List<String> favoredTerrains;

  /// Языки избранных врагов или «Хитреца».
  final List<Language> languages;

  /// Навык «Хитреца» с удвоенным бонусом мастерства.
  @override
  final List<Skill> expertise;

  @override
  final FightingStyle? fightingStyle;

  /// Заклинания, выбранные из списка следопыта.
  final List<Spell> chosenSpells;

  /// Заговоры друида от стиля «Воин-друид».
  final List<Spell> druidicCantrips;

  /// Заклинания архетипа и «Изначального чутья»: известны всегда и не входят в число известных.
  final List<Spell> grantedSpells;

  final List<AbilityScoreImprovement> improvements;

  /// Выбранные варианты умений архетипа («Добыча охотника» → «Убийца колоссов»): название умения → вариант.
  final Map<String, String> optionChoices;

  /// «Железный разум» сумрачного охотника: спасбросок Мудрости, а если он уже есть — Интеллекта или Харизмы.
  final StatKind? ironMindSave;

  Ranger({
    required super.level,
    required super.isMain,
    required this.features,
    this.archetypeId,
    this.archetypeName,
    this.tceFeatures = const {},
    this.favoredEnemies = const [],
    this.favoredTerrains = const [],
    this.languages = const [],
    this.expertise = const [],
    this.fightingStyle,
    this.chosenSpells = const [],
    this.druidicCantrips = const [],
    this.grantedSpells = const [],
    this.improvements = const [],
    this.optionChoices = const {},
    this.ironMindSave,
  });

  static const gloomStalker = 'gloom_stalker';
  static const ironMindLevel = 7;

  /// Умения класса и архетипа на указанном уровне. Из пары «Книга игрока» — «Котёл Таши» берётся выбранный
  /// вариант ([tceFeatures]); части «Искусного исследователя» — только вместе с ним.
  static List<Peculiarity> featuresAt(
    ClassInfo info,
    int level, {
    String? archetypeId,
    Set<String> tceFeatures = const {},
  }) {
    bool isChosen(String id) {
      if (replacements.containsKey(id)) return !tceFeatures.contains(replacements[id]);
      if (replacements.containsValue(id)) return tceFeatures.contains(id);
      if (_deftExplorerParts.contains(id)) return tceFeatures.contains(deftExplorer);
      return true;
    }

    return [
      ...info.featuresAt(level).where((e) => isChosen(e.id)).map(
            (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
          ),
      ...?info.subclass(archetypeId ?? '')?.featuresAt(level).map(
            (e) => Peculiarity(name: e.name.toUpperCase(), description: e.descriptionHtml, isHtml: true),
          ),
    ];
  }

  /// Ссылки на заклинания, известные всегда: таблица архетипа на сайте и «Изначальное чутьё».
  static List<String> grantedSpellLinks(ClassInfo info, int level, {String? archetypeId, required bool primal}) => {
        ...?info.subclass(archetypeId ?? '')?.spellsUpTo(level),
        if (primal) ...primalAwarenessSpells.entries.where((e) => e.key <= level).map((e) => e.value),
      }.toList();

  @override
  String get name => archetypeName == null ? 'Следопыт' : 'Следопыт ($archetypeName)';

  @override
  Dice get hitDice => Dice.k10;

  @override
  int get healthPerLevel => 6;

  @override
  int get startHealth => 10;

  @override
  StatKind get spellKind => StatKind.wisdom;

  @override
  List<StatKind> get chosenSaveThrows => const [StatKind.strength, StatKind.dexterity];

  @override
  List<StatKind> get grantedSaveThrows => [if (ironMindSave != null) ironMindSave!];

  @override
  List<ArmorProficiency> get armorProficiencies =>
      const [ArmorProficiency.light, ArmorProficiency.medium, ArmorProficiency.shields];

  @override
  WeaponProficiency get weaponProficiency => const WeaponProficiency(simple: true, martial: true);

  @override
  bool get canUseTwoWeapons => fightingStyle == FightingStyle.twoWeaponFighting;

  /// «Дополнительная атака» с 5 уровня.
  @override
  int get attacksPerAction => level >= 5 ? 2 : 1;

  bool get _hasDeftExplorer => tceFeatures.contains(deftExplorer);

  /// «Бродяга» «Искусного исследователя» с 6 уровня.
  @override
  int speedBonus(Player player) => _hasDeftExplorer && level >= 6 ? rovingSpeed : 0;

  @override
  List<Language> get grantedLanguages => languages;

  @override
  List<Spell> get knownSpells => [
        ...chosenSpells,
        ...druidicCantrips,
        ...grantedSpells.where((e) => !chosenSpells.contains(e)),
      ];

  /// Умения с боевым стилем. Остальные выборы (избранные враги, местности) показывает экран персонажа
  /// в названиях умений.
  @override
  List<Peculiarity> get abilities => withFightingStyles(features, [if (fightingStyle != null) fightingStyle!]);

  @override
  List<ChosenFeat> get feats => improvements.map((e) => e.feat).nonNulls.toList();

  /// «Предпочтительный противник»: к4, к6 с 6 уровня, к8 с 14.
  Dice get favoredFoeDice => level >= 14 ? Dice.k8 : (level >= 6 ? Dice.k6 : Dice.k4);

  @override
  List<ClassExtras> get classExtras => [
        if (tceFeatures.contains(favoredFoe)) ClassExtras.favoredFoe,
        if (_hasDeftExplorer && level >= 10) ClassExtras.tireless,
      ];

  /// Оба ресурса: использований столько, сколько бонус мастерства; восстанавливаются продолжительным отдыхом.
  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => player.proficiencyBonus;

  @override
  String classExtraDescription(ClassExtras extra) {
    String? feature(String name) => features.firstWhereOrNull((e) => e.name == name)?.description;
    return switch (extra) {
      ClassExtras.favoredFoe => [
          '<p><strong>Дополнительный урон:</strong> 1${favoredFoeDice.name}.</p>',
          feature('ПРЕДПОЧТИТЕЛЬНЫЙ ПРОТИВНИК') ?? '',
        ].join(),
      ClassExtras.tireless => feature('НЕУТОМИМЫЙ') ?? 'Действием получите 1к8 + модификатор Мудрости временных хитов.',
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

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'level': level,
        'isMain': isMain,
        'features': features.map((e) => e.toJson()).toList(),
        'archetypeId': archetypeId,
        'archetypeName': archetypeName,
        'tceFeatures': tceFeatures.toList(),
        'favoredEnemies': favoredEnemies,
        'favoredTerrains': favoredTerrains,
        'languages': languages.map((e) => e.name).toList(),
        'expertise': expertise.map((e) => e.name).toList(),
        'fightingStyle': fightingStyle?.name,
        'chosenSpells': chosenSpells.map((e) => e.toJson()).toList(),
        'druidicCantrips': druidicCantrips.map((e) => e.toJson()).toList(),
        'grantedSpells': grantedSpells.map((e) => e.toJson()).toList(),
        'improvements': improvements.map((e) => e.toJson()).toList(),
        'optionChoices': optionChoices,
        'ironMindSave': ironMindSave?.name,
      };

  static Ranger fromJson(Map<String, dynamic> json) => Ranger(
        level: json['level'],
        isMain: json['isMain'],
        features: (json['features'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
        archetypeId: json['archetypeId'],
        archetypeName: json['archetypeName'],
        tceFeatures: (json['tceFeatures'] as List).cast<String>().toSet(),
        favoredEnemies: (json['favoredEnemies'] as List).cast<String>(),
        favoredTerrains: (json['favoredTerrains'] as List).cast<String>(),
        languages: (json['languages'] as List).map((e) => Language.values.byName(e)).toList(),
        expertise: (json['expertise'] as List).map((e) => Skill.values.byName(e)).toList(),
        fightingStyle: json['fightingStyle'] == null ? null : FightingStyle.fromName(json['fightingStyle']),
        chosenSpells: (json['chosenSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        druidicCantrips: (json['druidicCantrips'] as List).map((e) => Spell.fromJson(e)).toList(),
        grantedSpells: (json['grantedSpells'] as List).map((e) => Spell.fromJson(e)).toList(),
        improvements: (json['improvements'] as List).map((e) => AbilityScoreImprovement.fromJson(e)).toList(),
        optionChoices: (json['optionChoices'] as Map).cast<String, String>(),
        ironMindSave: json['ironMindSave'] == null ? null : StatKind.values.byName(json['ironMindSave']),
      );
}
