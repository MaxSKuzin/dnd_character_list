import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/paladin.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateCharacterCubit extends Cubit<Player?> {
  final SpSource _source;

  Map<StatKind, int>? _stats;
  Race? race;
  ClassKind? _selectedClass;
  List<Spell>? _selectedSpells;
  List<Skill>? selectedSkills;
  Personality? _personality;
  Background? background;
  List<Tool>? _tools;
  List<InventoryItem>? _backgroundItems;
  List<Language>? _languages;
  List<InventoryItem>? _inventoryItems;

  CreateCharacterCubit(this._source) : super(null);

  void setStats(Map<StatKind, int> stats) {
    _stats = {...stats};
  }

  void setRace(Race newRace) {
    race = newRace;
  }

  void setClass(ClassKind classKind) {
    _selectedClass = classKind;
  }

  void setSpells(List<Spell> spells) {
    _selectedSpells = [...spells];
  }

  void setSkills(List<Skill> skills) {
    selectedSkills = [...skills];
  }

  void setInventoryItems(List<InventoryItem> items) {
    _inventoryItems = [...items];
  }

  void setPersonality({
    required String name,
    required String hairColor,
    required String eyesColor,
    required String skinColor,
    required String story,
    required int age,
    required int height,
    required int weight,
  }) {
    _personality = Personality(
      eyesColor: eyesColor,
      hairColor: hairColor,
      skinColor: skinColor,
      name: name,
      age: age,
      height: height,
      weight: weight,
      story: story,
    );
  }

  void setBackground(Background newBackground) {
    background = newBackground;
  }

  void setTools(List<Tool> tools) {
    _tools = [...tools];
  }

  void setBackgroundItems(List<InventoryItem> items) {
    _backgroundItems = [...items];
  }

  void setLanguages(List<Language> languages) {
    _languages = [...languages];
  }

  Future<void> createCharacter() async {
    final inventoryItems = [
      ..._inventoryItems!,
      ..._backgroundItems!,
      if (_tools != null) ..._tools!.map((e) => InventoryItem(quantity: 1, item: e)),
    ];

    final Inventory inventory = Inventory(
      items: inventoryItems,
      balance: background!.balance,
    );

    final spec = switch (_selectedClass!) {
      ClassKind.bard => Bard.level1(
          isMain: true,
          knownSpells: _selectedSpells!,
        ),
      ClassKind.barbarian => Barbarian(
          level: 1,
          isMain: true,
        ),
      ClassKind.paladin => Paladin.level1(
          isMain: true,
        ),
      _ => throw UnimplementedError(),
    };
    final player = Player(
      knownLanguages: _languages ?? [],
      background: background!,
      classes: [spec],
      personality: _personality!,
      armor: null,
      charisma: _stats![StatKind.charisma]!,
      constitution: _stats![StatKind.constitution]!,
      dexterity: _stats![StatKind.dexterity]!,
      intelligence: _stats![StatKind.intelligence]!,
      strength: _stats![StatKind.strength]!,
      wisdom: _stats![StatKind.wisdom]!,
      chosenSkills: selectedSkills!,
      race: race!,
      mainWeapon: null,
      secondWeapon: null,
      mainRangeWeapon: null,
      secondRangeWeapon: null,
      inventory: inventory,
      shield: null,
    );

    await _source.savePlayer(player);

    emit(player);
  }
}
