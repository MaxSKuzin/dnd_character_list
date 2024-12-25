import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LevelUpCubit extends Cubit<Player?> {
  final Player player;

  final SpSource _spSource;

  ClassKind? _classToUpdate;
  bool? _isClassMain;
  List<Spell>? _newSpells;

  List<Skill>? _newSkills;

  BardCollegium? _collegium;

  Map<StatKind, int>? _statsBonus;

  LevelUpCubit(
    this._spSource,
    @factoryParam this.player,
  ) : super(null);

  void setClass(ClassKind classKind, bool isMain) {
    _classToUpdate = classKind;
    _isClassMain = isMain;
  }

  void setSpells(List<Spell> spells) {
    _newSpells = spells;
  }

  void setSkills(List<Skill> skills) {
    _newSkills = skills;
  }

  void setCollegium(BardCollegium collegium) {
    _collegium = collegium;
  }

  void setStatsBonus(Map<StatKind, int> statsBonus) {
    _statsBonus = statsBonus;
  }

  void levelUp() async {
    if (_classToUpdate == null || _isClassMain == null) return;

    final spec = player.classes.firstWhereOrNull((e) => e.classKind == _classToUpdate);

    final Specialization newClass;
    final statsBonuses = spec?.statBonuses ?? {};
    switch (_classToUpdate!) {
      case ClassKind.bard:
        spec as Bard?;
        final collegium = spec?.collegium;
        final abilities = spec?.baseAbilities ?? [];
        switch (spec != null ? spec.level + 1 : 1) {
          case 1:
            newClass = Bard.level1(
              isMain: _isClassMain!,
              knownSpells: _newSpells!,
            );
            break;
          case 2:
            newClass = Bard.level2(
              isMain: _isClassMain!,
              knownSpells: _newSpells!,
            );
          case 3:
            newClass = Bard.level3(
              isMain: _isClassMain!,
              knownSpells: _newSpells!,
              abilities: abilities,
              collegium: _collegium!,
            );
          case 4:
            newClass = Bard.level4(
              statBonuses: _statsBonus!,
              isMain: _isClassMain!,
              knownSpells: _newSpells!,
              abilities: abilities,
              collegium: collegium!,
            );
          case 5:
            newClass = Bard.level5(
              statBonuses: statsBonuses,
              isMain: _isClassMain!,
              knownSpells: _newSpells!,
              abilities: abilities,
              collegium: collegium!,
            );
          default:
            throw UnimplementedError();
        }
        break;
      case ClassKind.barbarian:
        {
          newClass = Barbarian(
            level: spec != null ? spec.level + 1 : 1,
            isMain: _isClassMain!,
          );
        }
      case ClassKind.warrior:
      case ClassKind.wizard:
      case ClassKind.driud:
      case ClassKind.cliric:
      case ClassKind.inventor:
      case ClassKind.witch:
      case ClassKind.monk:
      case ClassKind.paladin:
      case ClassKind.thief:
      case ClassKind.ranger:
      case ClassKind.sorcerer:
        throw UnimplementedError();
    }
    Player newPlayer = spec == null ? player.addClass(newClass) : player.levelUp(newClass);
    if (_newSkills != null) {
      newPlayer = newPlayer.copyWith(chosenSkills: _newSkills!);
    }
    await _spSource.savePlayer(newPlayer);
    emit(newPlayer);
  }
}
