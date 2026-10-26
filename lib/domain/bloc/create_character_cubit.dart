import 'package:dnd_character_list/data/sp_source.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/paladin.dart';
import 'package:dnd_character_list/domain/models/classes/thief.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateCharacterCubit extends Cubit<Player?> {
  final SpSource _source;
  final SpellsRepository _spellsRepository;

  Race? race;
  ClassKind? classKind;

  /// Описание класса с dnd.su; пока есть только для барда.
  ClassInfo? classInfo;
  Map<StatKind, int>? stats;
  Background? background;
  List<Skill> skills = [];
  List<String> backgroundTools = [];
  List<String> classTools = [];
  List<Language> languages = [];
  List<InventoryItem> _classItems = [];
  List<Spell> _spells = [];
  Personality? _personality;

  CreateCharacterCubit(this._source, this._spellsRepository) : super(null);

  void setRace(Race value) => race = value;

  void setClass(ClassKind value, ClassInfo? info) {
    classKind = value;
    classInfo = info;
  }

  void setStats(Map<StatKind, int> value) => stats = {...value};

  void setBackground(Background value) => background = value;

  void setBackgroundProficiencies({required List<String> tools, required List<Language> languages}) {
    backgroundTools = [...tools];
    this.languages = [...languages];
  }

  void addSkills(List<Skill> value) => skills = [...skills, ...value];

  void setClassTools(List<String> value) => classTools = [...value];

  void setInventoryItems(List<InventoryItem> items) => _classItems = [...items];

  void setSpells(List<Spell> value) => _spells = [...value];

  void setPersonality(Personality value) => _personality = value;

  /// Навыки, которыми персонаж уже владеет: от предыстории и выбранные ранее.
  List<Skill> get knownSkills => {...?background?.skills, ...skills}.toList();

  Future<void> createCharacter() async {
    final inventory = Inventory(
      items: [
        ..._classItems,
        ...?background?.equipment.map((e) => InventoryItem(quantity: 1, item: e)),
      ],
      balance: Balance.fromGold(background!.gold),
    );

    final spec = switch (classKind!) {
      ClassKind.bard => Bard(
          level: 1,
          isMain: true,
          knownSpells: _spells,
          features: Bard.featuresAt(classInfo!, 1),
          inspirationDice: Bard.inspirationDiceAt(classInfo!, 1),
        ),
      ClassKind.barbarian => Barbarian(
          level: 1,
          isMain: true,
        ),
      ClassKind.paladin => Paladin.level1(
          isMain: true,
        ),
      ClassKind.thief => Thief.level1(
          isMain: true,
        ),
      _ => throw UnimplementedError(),
    };
    final player = Player(
      raceSpells: await _spellsRepository.resolve(race!.spellForLevel(1)),
      knownLanguages: languages,
      background: background!,
      toolProficiencies: {...backgroundTools, ...classTools}.toList(),
      classes: [spec],
      personality: _personality!,
      armor: null,
      charisma: stats![StatKind.charisma]!,
      constitution: stats![StatKind.constitution]!,
      dexterity: stats![StatKind.dexterity]!,
      intelligence: stats![StatKind.intelligence]!,
      strength: stats![StatKind.strength]!,
      wisdom: stats![StatKind.wisdom]!,
      chosenSkills: skills,
      race: race!,
      mainWeapon: null,
      secondWeapon: null,
      mainRangeWeapon: null,
      secondRangeWeapon: null,
      inventory: inventory,
      shield: null,
    );

    final equipped = _equipStartingItems(player);
    await _source.savePlayer(equipped);

    emit(equipped);
  }

  /// Надевает стартовое снаряжение: доспех, которым персонаж владеет, оружие в руки
  /// (предпочтительно то, которым владеет) и щит, если руки позволяют.
  Player _equipStartingItems(Player player) {
    final items = player.inventory.items.map((e) => e.item);
    var result = player;

    final armor = items.whereType<Armor>().where((e) => result.armorProficiencies.contains(e.kind.proficiency)).firstOrNull;
    if (armor != null) result = result.equipArmor(armor);

    final weapons = items.whereType<Weapon>().sortedBy<num>((e) => result.isProficientWith(e) ? 0 : 1);
    final melee = weapons.where((e) => e.kind.isMelee).firstOrNull;
    if (melee != null) result = result.equipMainWeapon(melee);
    final ranged = weapons.where((e) => e.kind.isRanged).firstOrNull;
    if (ranged != null) result = result.equipMainWeapon(ranged);

    final shield = items.whereType<Shield>().firstOrNull;
    if (shield != null && result.canUseShield) result = result.equipShield(shield);
    return result;
  }
}
