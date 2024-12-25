// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart'
    as _i25;
import 'package:dnd_character_list/domain/models/classes/class_kind.dart'
    as _i26;
import 'package:dnd_character_list/domain/models/player.dart' as _i24;
import 'package:dnd_character_list/domain/models/skill.dart' as _i27;
import 'package:dnd_character_list/domain/models/spell/spell.dart' as _i28;
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart' as _i29;
import 'package:dnd_character_list/domain/models/start_equipment.dart' as _i31;
import 'package:dnd_character_list/domain/models/stat_kind.dart' as _i23;
import 'package:dnd_character_list/domain/models/tools/tool.dart' as _i30;
import 'package:dnd_character_list/presentation/battle_screen/battle_screen.dart'
    as _i1;
import 'package:dnd_character_list/presentation/create_character_flow/create_character_flow.dart'
    as _i2;
import 'package:dnd_character_list/presentation/create_character_flow/screens/fill_stats_screen/fill_stats_screen.dart'
    as _i3;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_background_screen/select_background_screen.dart'
    as _i10;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_class_screen/select_class_screen.dart'
    as _i12;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_race_screen/select_race_screen.dart'
    as _i14;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_skills_screen/select_skills_screen.dart'
    as _i15;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_spells_screen/select_spells_screen.dart'
    as _i16;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_tools_screen/select_tools_screen.dart'
    as _i17;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_weapons_screen/select_weapons_screen.dart'
    as _i18;
import 'package:dnd_character_list/presentation/create_character_flow/screens/set_personality_screen/set_personality_screen.dart'
    as _i19;
import 'package:dnd_character_list/presentation/inventory_screen/inventory_screen.dart'
    as _i4;
import 'package:dnd_character_list/presentation/level_up_flow/bard/select_collegium_screen.dart'
    as _i13;
import 'package:dnd_character_list/presentation/level_up_flow/level_up_class_screen.dart'
    as _i5;
import 'package:dnd_character_list/presentation/level_up_flow/level_up_flow.dart'
    as _i6;
import 'package:dnd_character_list/presentation/main_flow/main_flow.dart'
    as _i7;
import 'package:dnd_character_list/presentation/main_screen/main_screen.dart'
    as _i8;
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart'
    as _i9;
import 'package:dnd_character_list/presentation/select_character_screen/select_character_screen.dart'
    as _i11;
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart'
    as _i20;
import 'package:flutter/material.dart' as _i22;

/// generated route for
/// [_i1.BattleScreen]
class BattleRoute extends _i21.PageRouteInfo<void> {
  const BattleRoute({List<_i21.PageRouteInfo>? children})
      : super(
          BattleRoute.name,
          initialChildren: children,
        );

  static const String name = 'BattleRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i1.BattleScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateCharacterFlow]
class CreateCharacterRoute extends _i21.PageRouteInfo<void> {
  const CreateCharacterRoute({List<_i21.PageRouteInfo>? children})
      : super(
          CreateCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateCharacterRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateCharacterFlow();
    },
  );
}

/// generated route for
/// [_i3.FillStatsScreen]
class FillStatsRoute extends _i21.PageRouteInfo<FillStatsRouteArgs> {
  FillStatsRoute({
    _i22.Key? key,
    bool isInitial = true,
    int maxPoints = 27,
    Map<_i23.StatKind, int> initialStats = const {},
    dynamic Function(Map<_i23.StatKind, int>)? onStatsFilled,
    List<_i21.PageRouteInfo>? children,
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

  static _i21.PageInfo page = _i21.PageInfo(
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

  final _i22.Key? key;

  final bool isInitial;

  final int maxPoints;

  final Map<_i23.StatKind, int> initialStats;

  final dynamic Function(Map<_i23.StatKind, int>)? onStatsFilled;

  @override
  String toString() {
    return 'FillStatsRouteArgs{key: $key, isInitial: $isInitial, maxPoints: $maxPoints, initialStats: $initialStats, onStatsFilled: $onStatsFilled}';
  }
}

/// generated route for
/// [_i4.InventoryScreen]
class InventoryRoute extends _i21.PageRouteInfo<void> {
  const InventoryRoute({List<_i21.PageRouteInfo>? children})
      : super(
          InventoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'InventoryRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i4.InventoryScreen();
    },
  );
}

/// generated route for
/// [_i5.LevelUpClassScreen]
class LevelUpClassRoute extends _i21.PageRouteInfo<void> {
  const LevelUpClassRoute({List<_i21.PageRouteInfo>? children})
      : super(
          LevelUpClassRoute.name,
          initialChildren: children,
        );

  static const String name = 'LevelUpClassRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i5.LevelUpClassScreen();
    },
  );
}

/// generated route for
/// [_i6.LevelUpFlow]
class LevelUpFlowRoute extends _i21.PageRouteInfo<LevelUpFlowRouteArgs> {
  LevelUpFlowRoute({
    _i22.Key? key,
    required _i24.Player player,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          LevelUpFlowRoute.name,
          args: LevelUpFlowRouteArgs(
            key: key,
            player: player,
          ),
          initialChildren: children,
        );

  static const String name = 'LevelUpFlowRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LevelUpFlowRouteArgs>();
      return _i6.LevelUpFlow(
        key: args.key,
        player: args.player,
      );
    },
  );
}

class LevelUpFlowRouteArgs {
  const LevelUpFlowRouteArgs({
    this.key,
    required this.player,
  });

  final _i22.Key? key;

  final _i24.Player player;

  @override
  String toString() {
    return 'LevelUpFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i7.MainFlow]
class MainFlowRoute extends _i21.PageRouteInfo<MainFlowRouteArgs> {
  MainFlowRoute({
    _i22.Key? key,
    required _i24.Player player,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          MainFlowRoute.name,
          args: MainFlowRouteArgs(
            key: key,
            player: player,
          ),
          initialChildren: children,
        );

  static const String name = 'MainFlowRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainFlowRouteArgs>();
      return _i7.MainFlow(
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

  final _i22.Key? key;

  final _i24.Player player;

  @override
  String toString() {
    return 'MainFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i8.MainScreen]
class MainRoute extends _i21.PageRouteInfo<void> {
  const MainRoute({List<_i21.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i8.MainScreen();
    },
  );
}

/// generated route for
/// [_i9.PersonalityScreen]
class PersonalityRoute extends _i21.PageRouteInfo<void> {
  const PersonalityRoute({List<_i21.PageRouteInfo>? children})
      : super(
          PersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalityRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i9.PersonalityScreen();
    },
  );
}

/// generated route for
/// [_i10.SelectBackgroundScreen]
class SelectBackgroundRoute
    extends _i21.PageRouteInfo<SelectBackgroundRouteArgs> {
  SelectBackgroundRoute({
    _i22.Key? key,
    required void Function() onContinue,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectBackgroundRoute.name,
          args: SelectBackgroundRouteArgs(
            key: key,
            onContinue: onContinue,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectBackgroundRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectBackgroundRouteArgs>();
      return _i10.SelectBackgroundScreen(
        key: args.key,
        onContinue: args.onContinue,
      );
    },
  );
}

class SelectBackgroundRouteArgs {
  const SelectBackgroundRouteArgs({
    this.key,
    required this.onContinue,
  });

  final _i22.Key? key;

  final void Function() onContinue;

  @override
  String toString() {
    return 'SelectBackgroundRouteArgs{key: $key, onContinue: $onContinue}';
  }
}

/// generated route for
/// [_i11.SelectCharacterScreen]
class SelectCharacterRoute extends _i21.PageRouteInfo<void> {
  const SelectCharacterRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SelectCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectCharacterRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i11.SelectCharacterScreen();
    },
  );
}

/// generated route for
/// [_i12.SelectClassScreen]
class SelectClassRoute extends _i21.PageRouteInfo<SelectClassRouteArgs> {
  SelectClassRoute({
    _i22.Key? key,
    required Map<_i23.StatKind, int> stats,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectClassRoute.name,
          args: SelectClassRouteArgs(
            key: key,
            stats: stats,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectClassRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectClassRouteArgs>();
      return _i12.SelectClassScreen(
        key: args.key,
        stats: args.stats,
      );
    },
  );
}

class SelectClassRouteArgs {
  const SelectClassRouteArgs({
    this.key,
    required this.stats,
  });

  final _i22.Key? key;

  final Map<_i23.StatKind, int> stats;

  @override
  String toString() {
    return 'SelectClassRouteArgs{key: $key, stats: $stats}';
  }
}

/// generated route for
/// [_i13.SelectCollegiumScreen]
class SelectCollegiumRoute
    extends _i21.PageRouteInfo<SelectCollegiumRouteArgs> {
  SelectCollegiumRoute({
    required void Function(_i25.BardCollegium) onCollegiumSelected,
    _i22.Key? key,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectCollegiumRoute.name,
          args: SelectCollegiumRouteArgs(
            onCollegiumSelected: onCollegiumSelected,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectCollegiumRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectCollegiumRouteArgs>();
      return _i13.SelectCollegiumScreen(
        onCollegiumSelected: args.onCollegiumSelected,
        key: args.key,
      );
    },
  );
}

class SelectCollegiumRouteArgs {
  const SelectCollegiumRouteArgs({
    required this.onCollegiumSelected,
    this.key,
  });

  final void Function(_i25.BardCollegium) onCollegiumSelected;

  final _i22.Key? key;

  @override
  String toString() {
    return 'SelectCollegiumRouteArgs{onCollegiumSelected: $onCollegiumSelected, key: $key}';
  }
}

/// generated route for
/// [_i14.SelectRaceScreen]
class SelectRaceRoute extends _i21.PageRouteInfo<void> {
  const SelectRaceRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SelectRaceRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectRaceRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i14.SelectRaceScreen();
    },
  );
}

/// generated route for
/// [_i15.SelectSkillsScreen]
class SelectSkillsRoute extends _i21.PageRouteInfo<SelectSkillsRouteArgs> {
  SelectSkillsRoute({
    _i22.Key? key,
    required _i26.ClassKind classKind,
    required List<_i27.Skill> availableSkills,
    required int maxSkills,
    void Function(List<_i27.Skill>)? onSkillsSelected,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectSkillsRoute.name,
          args: SelectSkillsRouteArgs(
            key: key,
            classKind: classKind,
            availableSkills: availableSkills,
            maxSkills: maxSkills,
            onSkillsSelected: onSkillsSelected,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectSkillsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSkillsRouteArgs>();
      return _i15.SelectSkillsScreen(
        key: args.key,
        classKind: args.classKind,
        availableSkills: args.availableSkills,
        maxSkills: args.maxSkills,
        onSkillsSelected: args.onSkillsSelected,
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
    this.onSkillsSelected,
  });

  final _i22.Key? key;

  final _i26.ClassKind classKind;

  final List<_i27.Skill> availableSkills;

  final int maxSkills;

  final void Function(List<_i27.Skill>)? onSkillsSelected;

  @override
  String toString() {
    return 'SelectSkillsRouteArgs{key: $key, classKind: $classKind, availableSkills: $availableSkills, maxSkills: $maxSkills, onSkillsSelected: $onSkillsSelected}';
  }
}

/// generated route for
/// [_i16.SelectSpellsScreen]
class SelectSpellsRoute extends _i21.PageRouteInfo<SelectSpellsRouteArgs> {
  SelectSpellsRoute({
    _i22.Key? key,
    List<_i28.Spell> knownSpells = const [],
    List<_i29.SpellSlot>? availableSlots,
    dynamic Function(List<_i28.Spell>)? onSpellsSelected,
    required int maxSpells,
    required int maxConspiracies,
    required _i26.ClassKind classKind,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectSpellsRoute.name,
          args: SelectSpellsRouteArgs(
            key: key,
            knownSpells: knownSpells,
            availableSlots: availableSlots,
            onSpellsSelected: onSpellsSelected,
            maxSpells: maxSpells,
            maxConspiracies: maxConspiracies,
            classKind: classKind,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectSpellsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSpellsRouteArgs>();
      return _i16.SelectSpellsScreen(
        key: args.key,
        knownSpells: args.knownSpells,
        availableSlots: args.availableSlots,
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
    this.availableSlots,
    this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  });

  final _i22.Key? key;

  final List<_i28.Spell> knownSpells;

  final List<_i29.SpellSlot>? availableSlots;

  final dynamic Function(List<_i28.Spell>)? onSpellsSelected;

  final int maxSpells;

  final int maxConspiracies;

  final _i26.ClassKind classKind;

  @override
  String toString() {
    return 'SelectSpellsRouteArgs{key: $key, knownSpells: $knownSpells, availableSlots: $availableSlots, onSpellsSelected: $onSpellsSelected, maxSpells: $maxSpells, maxConspiracies: $maxConspiracies, classKind: $classKind}';
  }
}

/// generated route for
/// [_i17.SelectToolsScreen]
class SelectToolsRoute extends _i21.PageRouteInfo<SelectToolsRouteArgs> {
  SelectToolsRoute({
    _i22.Key? key,
    required void Function() onContinue,
    required List<_i30.Tool> tools,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectToolsRoute.name,
          args: SelectToolsRouteArgs(
            key: key,
            onContinue: onContinue,
            tools: tools,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectToolsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectToolsRouteArgs>();
      return _i17.SelectToolsScreen(
        key: args.key,
        onContinue: args.onContinue,
        tools: args.tools,
      );
    },
  );
}

class SelectToolsRouteArgs {
  const SelectToolsRouteArgs({
    this.key,
    required this.onContinue,
    required this.tools,
  });

  final _i22.Key? key;

  final void Function() onContinue;

  final List<_i30.Tool> tools;

  @override
  String toString() {
    return 'SelectToolsRouteArgs{key: $key, onContinue: $onContinue, tools: $tools}';
  }
}

/// generated route for
/// [_i18.SelectWeaponsScreen]
class SelectWeaponsRoute extends _i21.PageRouteInfo<SelectWeaponsRouteArgs> {
  SelectWeaponsRoute({
    _i22.Key? key,
    required _i31.StartEquipment equipment,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          SelectWeaponsRoute.name,
          args: SelectWeaponsRouteArgs(
            key: key,
            equipment: equipment,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectWeaponsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectWeaponsRouteArgs>();
      return _i18.SelectWeaponsScreen(
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

  final _i22.Key? key;

  final _i31.StartEquipment equipment;

  @override
  String toString() {
    return 'SelectWeaponsRouteArgs{key: $key, equipment: $equipment}';
  }
}

/// generated route for
/// [_i19.SetPersonalityScreen]
class SetPersonalityRoute extends _i21.PageRouteInfo<void> {
  const SetPersonalityRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SetPersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetPersonalityRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i19.SetPersonalityScreen();
    },
  );
}

/// generated route for
/// [_i20.SpellsScreen]
class SpellsRoute extends _i21.PageRouteInfo<void> {
  const SpellsRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SpellsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SpellsRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i20.SpellsScreen();
    },
  );
}
