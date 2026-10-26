import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/paladin.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/classes/thief.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LevelUpCubit extends Cubit<Player?> {
  final Player player;

  final SpSource _spSource;
  final SpellsRepository _spellsRepository;

  ClassKind? _classToUpdate;
  bool? _isClassMain;
  List<Spell>? _newSpells;
  Map<SpellSlot, String>? _raceSpells;

  List<Skill>? _newSkills;

  /// Готовая специализация нового уровня (бард и чародей собираются по таблице класса с ttg.club).
  Specialization? _specialization;

  List<String> _newTools = [];

  FightingStyle? _fightingStyle;

  LevelUpCubit(
    this._spSource,
    this._spellsRepository,
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

  void setSpecialization(Specialization specialization) {
    _specialization = specialization;
  }

  void setTools(List<String> tools) {
    _newTools = [...tools];
  }

  void setFightingStyle(FightingStyle fightingStyle) {
    _fightingStyle = fightingStyle;
  }

  void setRaceSpells(Map<SpellSlot, String> spells) {
    _raceSpells = spells;
  }

  void levelUp() async {
    if (_classToUpdate == null || _isClassMain == null) return;

    final spec = player.classes.firstWhereOrNull((e) => e.classKind == _classToUpdate);

    final Specialization newClass;
    switch (_classToUpdate!) {
      case ClassKind.bard:
      case ClassKind.sorcerer:
        newClass = _specialization!;
      case ClassKind.paladin:
        {
          spec as Paladin?;
          final abilities = spec?.baseAbilities ?? [];
          switch (spec != null ? spec.level + 1 : 1) {
            case 1:
              newClass = Paladin.level1(
                isMain: _isClassMain!,
              );
              break;
            case 2:
              newClass = Paladin.level2(
                isMain: _isClassMain!,
                abilities: abilities,
                fightingStyle: _fightingStyle!,
                knownSpells: _newSpells!,
              );
            default:
              throw UnimplementedError();
          }
          break;
        }
      case ClassKind.barbarian:
        {
          newClass = Barbarian(
            level: spec != null ? spec.level + 1 : 1,
            isMain: _isClassMain!,
          );
        }
      case ClassKind.thief:
        {
          spec as Thief?;
          final abilities = spec?.baseAbilities ?? [];
          switch (spec != null ? spec.level + 1 : 1) {
            case 1:
              newClass = Thief.level1(
                isMain: _isClassMain!,
              );
              break;
            case 2:
              newClass = Thief.level2(
                isMain: _isClassMain!,
                abilities: abilities,
              );
            default:
              throw UnimplementedError();
          }
          break;
        }
      case ClassKind.warrior:
      case ClassKind.wizard:
      case ClassKind.driud:
      case ClassKind.cliric:
      case ClassKind.inventor:
      case ClassKind.witch:
      case ClassKind.monk:
      case ClassKind.ranger:
        throw UnimplementedError();
    }
    Player newPlayer = spec == null ? player.addClass(newClass) : player.levelUp(newClass);
    if (_newSkills != null) {
      newPlayer = newPlayer.copyWith(chosenSkills: _newSkills!);
    }
    if (_newTools.isNotEmpty) {
      newPlayer = newPlayer.copyWith(toolProficiencies: [...player.toolProficiencies, ..._newTools]);
    }
    if (_raceSpells != null) {
      newPlayer = newPlayer.copyWith(raceSpells: await _spellsRepository.resolve(_raceSpells!));
    }
    await _spSource.savePlayer(newPlayer);
    emit(newPlayer);
  }
}
