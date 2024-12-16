// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:dnd_character_list/domain/models/classes/class_kind.dart'
    as _i18;
import 'package:dnd_character_list/domain/models/player.dart' as _i17;
import 'package:dnd_character_list/domain/models/skill.dart' as _i19;
import 'package:dnd_character_list/domain/models/spell/spell.dart' as _i20;
import 'package:dnd_character_list/domain/models/start_equipment.dart' as _i21;
import 'package:dnd_character_list/domain/models/stat_kind.dart' as _i16;
import 'package:dnd_character_list/presentation/battle_screen/battle_screen.dart'
    as _i1;
import 'package:dnd_character_list/presentation/create_character_flow/create_character_flow.dart'
    as _i2;
import 'package:dnd_character_list/presentation/create_character_flow/screens/fill_stats_screen/fill_stats_screen.dart'
    as _i3;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_class_screen/select_class_screen.dart'
    as _i7;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_race_screen/select_race_screen.dart'
    as _i8;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_skills_screen/select_skills_screen.dart'
    as _i9;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_spells_screen/select_spells_screen.dart'
    as _i10;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_weapons_screen/select_weapons_screen.dart'
    as _i11;
import 'package:dnd_character_list/presentation/create_character_flow/screens/set_personality_screen/set_personality_screen.dart'
    as _i12;
import 'package:dnd_character_list/presentation/main_flow/main_flow.dart'
    as _i4;
import 'package:dnd_character_list/presentation/main_screen/main_screen.dart'
    as _i5;
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart'
    as _i6;
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart'
    as _i13;
import 'package:flutter/material.dart' as _i15;

/// generated route for
/// [_i1.BattleScreen]
class BattleRoute extends _i14.PageRouteInfo<void> {
  const BattleRoute({List<_i14.PageRouteInfo>? children})
      : super(
          BattleRoute.name,
          initialChildren: children,
        );

  static const String name = 'BattleRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i1.BattleScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateCharacterFlow]
class CreateCharacterRoute extends _i14.PageRouteInfo<void> {
  const CreateCharacterRoute({List<_i14.PageRouteInfo>? children})
      : super(
          CreateCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateCharacterRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateCharacterFlow();
    },
  );
}

/// generated route for
/// [_i3.FillStatsScreen]
class FillStatsRoute extends _i14.PageRouteInfo<FillStatsRouteArgs> {
  FillStatsRoute({
    _i15.Key? key,
    bool isInitial = true,
    int maxPoints = 27,
    Map<_i16.StatKind, int> initialStats = const {},
    Map<_i16.StatKind, int> Function()? onStatsFilled,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          FillStatsRoute.name,
          args: FillStatsRouteArgs(
            key: key,
            isInitial: isInitial,
            maxPoints: maxPoints,
            initialStats: initialStats,
            onStatsFilled: onStatsFilled,
          ),
          initialChildren: children,
        );

  static const String name = 'FillStatsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FillStatsRouteArgs>(
          orElse: () => const FillStatsRouteArgs());
      return _i3.FillStatsScreen(
        key: args.key,
        isInitial: args.isInitial,
        maxPoints: args.maxPoints,
        initialStats: args.initialStats,
        onStatsFilled: args.onStatsFilled,
      );
    },
  );
}

class FillStatsRouteArgs {
  const FillStatsRouteArgs({
    this.key,
    this.isInitial = true,
    this.maxPoints = 27,
    this.initialStats = const {},
    this.onStatsFilled,
  });

  final _i15.Key? key;

  final bool isInitial;

  final int maxPoints;

  final Map<_i16.StatKind, int> initialStats;

  final Map<_i16.StatKind, int> Function()? onStatsFilled;

  @override
  String toString() {
    return 'FillStatsRouteArgs{key: $key, isInitial: $isInitial, maxPoints: $maxPoints, initialStats: $initialStats, onStatsFilled: $onStatsFilled}';
  }
}

/// generated route for
/// [_i4.MainFlow]
class MainFlowRoute extends _i14.PageRouteInfo<MainFlowRouteArgs> {
  MainFlowRoute({
    _i15.Key? key,
    required _i17.Player player,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          MainFlowRoute.name,
          args: MainFlowRouteArgs(
            key: key,
            player: player,
          ),
          initialChildren: children,
        );

  static const String name = 'MainFlowRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainFlowRouteArgs>();
      return _i4.MainFlow(
        key: args.key,
        player: args.player,
      );
    },
  );
}

class MainFlowRouteArgs {
  const MainFlowRouteArgs({
    this.key,
    required this.player,
  });

  final _i15.Key? key;

  final _i17.Player player;

  @override
  String toString() {
    return 'MainFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i5.MainScreen]
class MainRoute extends _i14.PageRouteInfo<void> {
  const MainRoute({List<_i14.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i5.MainScreen();
    },
  );
}

/// generated route for
/// [_i6.PersonalityScreen]
class PersonalityRoute extends _i14.PageRouteInfo<void> {
  const PersonalityRoute({List<_i14.PageRouteInfo>? children})
      : super(
          PersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalityRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i6.PersonalityScreen();
    },
  );
}

/// generated route for
/// [_i7.SelectClassScreen]
class SelectClassRoute extends _i14.PageRouteInfo<void> {
  const SelectClassRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SelectClassRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectClassRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.SelectClassScreen();
    },
  );
}

/// generated route for
/// [_i8.SelectRaceScreen]
class SelectRaceRoute extends _i14.PageRouteInfo<void> {
  const SelectRaceRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SelectRaceRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectRaceRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i8.SelectRaceScreen();
    },
  );
}

/// generated route for
/// [_i9.SelectSkillsScreen]
class SelectSkillsRoute extends _i14.PageRouteInfo<SelectSkillsRouteArgs> {
  SelectSkillsRoute({
    _i15.Key? key,
    required _i18.ClassKind classKind,
    required List<_i19.Skill> availableSkills,
    required int maxSkills,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          SelectSkillsRoute.name,
          args: SelectSkillsRouteArgs(
            key: key,
            classKind: classKind,
            availableSkills: availableSkills,
            maxSkills: maxSkills,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectSkillsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSkillsRouteArgs>();
      return _i9.SelectSkillsScreen(
        key: args.key,
        classKind: args.classKind,
        availableSkills: args.availableSkills,
        maxSkills: args.maxSkills,
      );
    },
  );
}

class SelectSkillsRouteArgs {
  const SelectSkillsRouteArgs({
    this.key,
    required this.classKind,
    required this.availableSkills,
    required this.maxSkills,
  });

  final _i15.Key? key;

  final _i18.ClassKind classKind;

  final List<_i19.Skill> availableSkills;

  final int maxSkills;

  @override
  String toString() {
    return 'SelectSkillsRouteArgs{key: $key, classKind: $classKind, availableSkills: $availableSkills, maxSkills: $maxSkills}';
  }
}

/// generated route for
/// [_i10.SelectSpellsScreen]
class SelectSpellsRoute extends _i14.PageRouteInfo<SelectSpellsRouteArgs> {
  SelectSpellsRoute({
    _i15.Key? key,
    List<_i20.Spell> knownSpells = const [],
    dynamic Function(List<_i20.Spell>)? onSpellsSelected,
    required int maxSpells,
    required int maxConspiracies,
    required _i18.ClassKind classKind,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          SelectSpellsRoute.name,
          args: SelectSpellsRouteArgs(
            key: key,
            knownSpells: knownSpells,
            onSpellsSelected: onSpellsSelected,
            maxSpells: maxSpells,
            maxConspiracies: maxConspiracies,
            classKind: classKind,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectSpellsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSpellsRouteArgs>();
      return _i10.SelectSpellsScreen(
        key: args.key,
        knownSpells: args.knownSpells,
        onSpellsSelected: args.onSpellsSelected,
        maxSpells: args.maxSpells,
        maxConspiracies: args.maxConspiracies,
        classKind: args.classKind,
      );
    },
  );
}

class SelectSpellsRouteArgs {
  const SelectSpellsRouteArgs({
    this.key,
    this.knownSpells = const [],
    this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  });

  final _i15.Key? key;

  final List<_i20.Spell> knownSpells;

  final dynamic Function(List<_i20.Spell>)? onSpellsSelected;

  final int maxSpells;

  final int maxConspiracies;

  final _i18.ClassKind classKind;

  @override
  String toString() {
    return 'SelectSpellsRouteArgs{key: $key, knownSpells: $knownSpells, onSpellsSelected: $onSpellsSelected, maxSpells: $maxSpells, maxConspiracies: $maxConspiracies, classKind: $classKind}';
  }
}

/// generated route for
/// [_i11.SelectWeaponsScreen]
class SelectWeaponsRoute extends _i14.PageRouteInfo<SelectWeaponsRouteArgs> {
  SelectWeaponsRoute({
    _i15.Key? key,
    required _i21.StartEquipment equipment,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          SelectWeaponsRoute.name,
          args: SelectWeaponsRouteArgs(
            key: key,
            equipment: equipment,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectWeaponsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectWeaponsRouteArgs>();
      return _i11.SelectWeaponsScreen(
        key: args.key,
        equipment: args.equipment,
      );
    },
  );
}

class SelectWeaponsRouteArgs {
  const SelectWeaponsRouteArgs({
    this.key,
    required this.equipment,
  });

  final _i15.Key? key;

  final _i21.StartEquipment equipment;

  @override
  String toString() {
    return 'SelectWeaponsRouteArgs{key: $key, equipment: $equipment}';
  }
}

/// generated route for
/// [_i12.SetPersonalityScreen]
class SetPersonalityRoute extends _i14.PageRouteInfo<void> {
  const SetPersonalityRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SetPersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetPersonalityRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.SetPersonalityScreen();
    },
  );
}

/// generated route for
/// [_i13.SpellsScreen]
class SpellsRoute extends _i14.PageRouteInfo<void> {
  const SpellsRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SpellsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SpellsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.SpellsScreen();
    },
  );
}
