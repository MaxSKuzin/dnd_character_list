import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateCharacterCubit extends Cubit<Player?> {
  final SpSource _source;

  Map<StatKind, int>? _stats;
  Race? _race;
  ClassKind? _selectedClass;
  List<Spell>? _selectedSpells;
  List<Skill>? _selectedSkills;
  List<Weapon>? _selectedWeapons;
  Armor? _armor;
  Personality? _personality;

  CreateCharacterCubit(this._source) : super(null);

  void setStats(Map<StatKind, int> stats) {
    _stats = {...stats};
  }

  void setRace(Race race) {
    _race = race;
  }

  void setClass(ClassKind classKind) {
    _selectedClass = classKind;
  }

  void setSpells(List<Spell> spells) {
    _selectedSpells = [...spells];
  }

  void setSkills(List<Skill> skills) {
    _selectedSkills = [...skills];
  }

  void setWeapons(List<Weapon> weapons) {
    _selectedWeapons = [...weapons];
  }

  void setArmor(Armor armor) {
    _armor = armor;
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

  Future<void> createCharacter() async {
    final spec = switch (_selectedClass!) {
      ClassKind.bard => Bard.level1(
          isMain: true,
          knownSpells: _selectedSpells!,
        ),
      ClassKind.barbarian => Barbarian(
          level: 1,
          isMain: true,
        ),
    };
    final player = Player(
      classes: [spec],
      personality: _personality!,
      armor: _armor,
      charisma: _stats![StatKind.charisma]!,
      constitution: _stats![StatKind.constitution]!,
      dexterity: _stats![StatKind.dexterity]!,
      intelligence: _stats![StatKind.intelligence]!,
      strength: _stats![StatKind.strength]!,
      wisdom: _stats![StatKind.wisdom]!,
      chosenSkills: _selectedSkills!,
      race: _race!,
      weapons: _selectedWeapons ?? [],
      shield: null,
    );

    await _source.savePlayer(player);

    emit(player);
  }
}
