import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
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
/// Происхождение выбирается на 1 уровне. Тексты умений класса и происхождения берутся с сайта
/// и хранятся в персонаже; в коде — только механики происхождений, которые нельзя вывести из текста.
final class Sorcerer extends Specialization {
  // Последние части ссылок на происхождения на ttg.club.
  static const draconicBloodline = 'draconic';
  static const divineSoul = 'divine_soul';
  static const stormSorcery = 'storm';
  static const lunarSorcery = 'lunar';

  /// «Драконья устойчивость»: КД без доспеха.
  static const draconicArmorClass = 13;

  /// «Лунное воплощение» и «Лунный огонь» на 1 уровне: заклинания всех трёх фаз и заговор.
  /// На сайте они перечислены только в тексте умений.
  static const _lunarSpells = {
    1: ['/spells/shield', '/spells/ray_of_sickness', '/spells/color_spray', '/spells/sacred_flame'],
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
  });

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
        if (originId == lunarSorcery) ..._lunarSpells.entries.where((e) => e.key <= level).expand((e) => e.value),
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

  @override
  List<Peculiarity> get abilities => features;

  @override
  List<Language> get grantedLanguages => languagesFor(originId);

  /// Языки происхождения: драконий у «Наследия драконьей крови», Первичный у «Штормового колдовства».
  static List<Language> languagesFor(String? originId) => [
        if (originId == draconicBloodline) Language.draconic,
        if (originId == stormSorcery) Language.primordial,
      ];

  @override
  Map<StatKind, int> get statBonuses => const {};

  Sorcerer copyWith({
    int? level,
    bool? isMain,
    List<Spell>? chosenSpells,
    List<Spell>? originSpells,
    List<Peculiarity>? features,
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
      );
}
