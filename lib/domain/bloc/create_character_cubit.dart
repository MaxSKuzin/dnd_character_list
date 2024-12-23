import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
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
  Weapon? _mainWeapon;
  Weapon? _secondWeapon;
  Weapon? _mainRangeWeapon;
  Weapon? _secondRangeWeapon;
  Armor? _armor;
  Personality? _personality;
  Inventory? _inventory;

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

  void setWeapons(Weapon firstWeapon, Weapon? secondWeapon) {
    if (firstWeapon.kind.isMelee) {
      _mainWeapon = firstWeapon;
    } else {
      _mainRangeWeapon = firstWeapon;
    }
    if (secondWeapon?.kind.isMelee ?? false) {
      _secondWeapon = secondWeapon;
    } else {
      _secondRangeWeapon = secondWeapon;
    }
    if (firstWeapon != secondWeapon) {
      _inventory = Inventory(
        balance: Balance.fromGold(15),
        items: [
          InventoryItem(quantity: 1, item: firstWeapon),
          if (secondWeapon != null) InventoryItem(quantity: 1, item: secondWeapon),
        ],
      );
    } else {
      _inventory = Inventory(
        balance: Balance.fromGold(15),
        items: [
          InventoryItem(quantity: 2, item: firstWeapon),
        ],
      );
    }
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
      _ => throw UnimplementedError(),
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
      mainWeapon: _mainWeapon,
      secondWeapon: _secondWeapon,
      mainRangeWeapon: _mainRangeWeapon,
      secondRangeWeapon: _secondRangeWeapon,
      inventory: _inventory!,
      shield: null,
    );

    await _source.savePlayer(player);

    emit(player);
  }
}
