// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart'
    as _i26;
import 'package:dnd_character_list/domain/models/classes/class_kind.dart'
    as _i28;
import 'package:dnd_character_list/domain/models/language.dart' as _i27;
import 'package:dnd_character_list/domain/models/player.dart' as _i25;
import 'package:dnd_character_list/domain/models/skill.dart' as _i29;
import 'package:dnd_character_list/domain/models/spell/spell.dart' as _i30;
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart' as _i31;
import 'package:dnd_character_list/domain/models/start_equipment.dart' as _i33;
import 'package:dnd_character_list/domain/models/stat_kind.dart' as _i24;
import 'package:dnd_character_list/domain/models/tools/tool.dart' as _i32;
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
    as _i15;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_skills_screen/select_skills_screen.dart'
    as _i16;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_spells_screen/select_spells_screen.dart'
    as _i17;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_tools_screen/select_tools_screen.dart'
    as _i18;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_weapons_screen/select_weapons_screen.dart'
    as _i19;
import 'package:dnd_character_list/presentation/create_character_flow/screens/set_personality_screen/set_personality_screen.dart'
    as _i20;
import 'package:dnd_character_list/presentation/create_character_flow/select_languages_screen/select_languages_screen.dart'
    as _i14;
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
    as _i21;
import 'package:flutter/material.dart' as _i23;

/// generated route for
/// [_i1.BattleScreen]
class BattleRoute extends _i22.PageRouteInfo<void> {
  const BattleRoute({List<_i22.PageRouteInfo>? children})
      : super(
          BattleRoute.name,
          initialChildren: children,
        );

  static const String name = 'BattleRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i1.BattleScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateCharacterFlow]
class CreateCharacterRoute extends _i22.PageRouteInfo<void> {
  const CreateCharacterRoute({List<_i22.PageRouteInfo>? children})
      : super(
          CreateCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateCharacterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateCharacterFlow();
    },
  );
}

/// generated route for
/// [_i3.FillStatsScreen]
class FillStatsRoute extends _i22.PageRouteInfo<FillStatsRouteArgs> {
  FillStatsRoute({
    _i23.Key? key,
    bool isInitial = true,
    int maxPoints = 27,
    Map<_i24.StatKind, int> initialStats = const {},
    dynamic Function(Map<_i24.StatKind, int>)? onStatsFilled,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final bool isInitial;

  final int maxPoints;

  final Map<_i24.StatKind, int> initialStats;

  final dynamic Function(Map<_i24.StatKind, int>)? onStatsFilled;

  @override
  String toString() {
    return 'FillStatsRouteArgs{key: $key, isInitial: $isInitial, maxPoints: $maxPoints, initialStats: $initialStats, onStatsFilled: $onStatsFilled}';
  }
}

/// generated route for
/// [_i4.InventoryScreen]
class InventoryRoute extends _i22.PageRouteInfo<void> {
  const InventoryRoute({List<_i22.PageRouteInfo>? children})
      : super(
          InventoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'InventoryRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i4.InventoryScreen();
    },
  );
}

/// generated route for
/// [_i5.LevelUpClassScreen]
class LevelUpClassRoute extends _i22.PageRouteInfo<void> {
  const LevelUpClassRoute({List<_i22.PageRouteInfo>? children})
      : super(
          LevelUpClassRoute.name,
          initialChildren: children,
        );

  static const String name = 'LevelUpClassRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i5.LevelUpClassScreen();
    },
  );
}

/// generated route for
/// [_i6.LevelUpFlow]
class LevelUpFlowRoute extends _i22.PageRouteInfo<LevelUpFlowRouteArgs> {
  LevelUpFlowRoute({
    _i23.Key? key,
    required _i25.Player player,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          LevelUpFlowRoute.name,
          args: LevelUpFlowRouteArgs(
            key: key,
            player: player,
          ),
          initialChildren: children,
        );

  static const String name = 'LevelUpFlowRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final _i25.Player player;

  @override
  String toString() {
    return 'LevelUpFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i7.MainFlow]
class MainFlowRoute extends _i22.PageRouteInfo<MainFlowRouteArgs> {
  MainFlowRoute({
    _i23.Key? key,
    required _i25.Player player,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          MainFlowRoute.name,
          args: MainFlowRouteArgs(
            key: key,
            player: player,
          ),
          initialChildren: children,
        );

  static const String name = 'MainFlowRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final _i25.Player player;

  @override
  String toString() {
    return 'MainFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i8.MainScreen]
class MainRoute extends _i22.PageRouteInfo<void> {
  const MainRoute({List<_i22.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i8.MainScreen();
    },
  );
}

/// generated route for
/// [_i9.PersonalityScreen]
class PersonalityRoute extends _i22.PageRouteInfo<void> {
  const PersonalityRoute({List<_i22.PageRouteInfo>? children})
      : super(
          PersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalityRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.PersonalityScreen();
    },
  );
}

/// generated route for
/// [_i10.SelectBackgroundScreen]
class SelectBackgroundRoute
    extends _i22.PageRouteInfo<SelectBackgroundRouteArgs> {
  SelectBackgroundRoute({
    _i23.Key? key,
    required void Function() onContinue,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          SelectBackgroundRoute.name,
          args: SelectBackgroundRouteArgs(
            key: key,
            onContinue: onContinue,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectBackgroundRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final void Function() onContinue;

  @override
  String toString() {
    return 'SelectBackgroundRouteArgs{key: $key, onContinue: $onContinue}';
  }
}

/// generated route for
/// [_i11.SelectCharacterScreen]
class SelectCharacterRoute extends _i22.PageRouteInfo<void> {
  const SelectCharacterRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SelectCharacterRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectCharacterRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.SelectCharacterScreen();
    },
  );
}

/// generated route for
/// [_i12.SelectClassScreen]
class SelectClassRoute extends _i22.PageRouteInfo<SelectClassRouteArgs> {
  SelectClassRoute({
    _i23.Key? key,
    required Map<_i24.StatKind, int> stats,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          SelectClassRoute.name,
          args: SelectClassRouteArgs(
            key: key,
            stats: stats,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectClassRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final Map<_i24.StatKind, int> stats;

  @override
  String toString() {
    return 'SelectClassRouteArgs{key: $key, stats: $stats}';
  }
}

/// generated route for
/// [_i13.SelectCollegiumScreen]
class SelectCollegiumRoute
    extends _i22.PageRouteInfo<SelectCollegiumRouteArgs> {
  SelectCollegiumRoute({
    required void Function(_i26.BardCollegium) onCollegiumSelected,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          SelectCollegiumRoute.name,
          args: SelectCollegiumRouteArgs(
            onCollegiumSelected: onCollegiumSelected,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectCollegiumRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final void Function(_i26.BardCollegium) onCollegiumSelected;

  final _i23.Key? key;

  @override
  String toString() {
    return 'SelectCollegiumRouteArgs{onCollegiumSelected: $onCollegiumSelected, key: $key}';
  }
}

/// generated route for
/// [_i14.SelectLanguagesScreen]
class SelectLanguagesRoute
    extends _i22.PageRouteInfo<SelectLanguagesRouteArgs> {
  SelectLanguagesRoute({
    _i23.Key? key,
    required List<_i27.Language> knownLanguages,
    required int maxLanguages,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          SelectLanguagesRoute.name,
          args: SelectLanguagesRouteArgs(
            key: key,
            knownLanguages: knownLanguages,
            maxLanguages: maxLanguages,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectLanguagesRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectLanguagesRouteArgs>();
      return _i14.SelectLanguagesScreen(
        key: args.key,
        knownLanguages: args.knownLanguages,
        maxLanguages: args.maxLanguages,
      );
    },
  );
}

class SelectLanguagesRouteArgs {
  const SelectLanguagesRouteArgs({
    this.key,
    required this.knownLanguages,
    required this.maxLanguages,
  });

  final _i23.Key? key;

  final List<_i27.Language> knownLanguages;

  final int maxLanguages;

  @override
  String toString() {
    return 'SelectLanguagesRouteArgs{key: $key, knownLanguages: $knownLanguages, maxLanguages: $maxLanguages}';
  }
}

/// generated route for
/// [_i15.SelectRaceScreen]
class SelectRaceRoute extends _i22.PageRouteInfo<void> {
  const SelectRaceRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SelectRaceRoute.name,
          initialChildren: children,
        );

  static const String name = 'SelectRaceRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.SelectRaceScreen();
    },
  );
}

/// generated route for
/// [_i16.SelectSkillsScreen]
class SelectSkillsRoute extends _i22.PageRouteInfo<SelectSkillsRouteArgs> {
  SelectSkillsRoute({
    _i23.Key? key,
    required _i28.ClassKind classKind,
    required List<_i29.Skill> availableSkills,
    required int maxSkills,
    void Function(List<_i29.Skill>)? onSkillsSelected,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSkillsRouteArgs>();
      return _i16.SelectSkillsScreen(
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

  final _i23.Key? key;

  final _i28.ClassKind classKind;

  final List<_i29.Skill> availableSkills;

  final int maxSkills;

  final void Function(List<_i29.Skill>)? onSkillsSelected;

  @override
  String toString() {
    return 'SelectSkillsRouteArgs{key: $key, classKind: $classKind, availableSkills: $availableSkills, maxSkills: $maxSkills, onSkillsSelected: $onSkillsSelected}';
  }
}

/// generated route for
/// [_i17.SelectSpellsScreen]
class SelectSpellsRoute extends _i22.PageRouteInfo<SelectSpellsRouteArgs> {
  SelectSpellsRoute({
    _i23.Key? key,
    List<_i30.Spell> knownSpells = const [],
    List<_i31.SpellSlot>? availableSlots,
    dynamic Function(List<_i30.Spell>)? onSpellsSelected,
    required int maxSpells,
    required int maxConspiracies,
    required _i28.ClassKind classKind,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSpellsRouteArgs>();
      return _i17.SelectSpellsScreen(
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

  final _i23.Key? key;

  final List<_i30.Spell> knownSpells;

  final List<_i31.SpellSlot>? availableSlots;

  final dynamic Function(List<_i30.Spell>)? onSpellsSelected;

  final int maxSpells;

  final int maxConspiracies;

  final _i28.ClassKind classKind;

  @override
  String toString() {
    return 'SelectSpellsRouteArgs{key: $key, knownSpells: $knownSpells, availableSlots: $availableSlots, onSpellsSelected: $onSpellsSelected, maxSpells: $maxSpells, maxConspiracies: $maxConspiracies, classKind: $classKind}';
  }
}

/// generated route for
/// [_i18.SelectToolsScreen]
class SelectToolsRoute extends _i22.PageRouteInfo<SelectToolsRouteArgs> {
  SelectToolsRoute({
    _i23.Key? key,
    required void Function() onContinue,
    required List<_i32.Tool> tools,
    List<_i22.PageRouteInfo>? children,
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

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectToolsRouteArgs>();
      return _i18.SelectToolsScreen(
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

  final _i23.Key? key;

  final void Function() onContinue;

  final List<_i32.Tool> tools;

  @override
  String toString() {
    return 'SelectToolsRouteArgs{key: $key, onContinue: $onContinue, tools: $tools}';
  }
}

/// generated route for
/// [_i19.SelectWeaponsScreen]
class SelectWeaponsRoute extends _i22.PageRouteInfo<SelectWeaponsRouteArgs> {
  SelectWeaponsRoute({
    _i23.Key? key,
    required _i33.StartEquipment equipment,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          SelectWeaponsRoute.name,
          args: SelectWeaponsRouteArgs(
            key: key,
            equipment: equipment,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectWeaponsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectWeaponsRouteArgs>();
      return _i19.SelectWeaponsScreen(
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

  final _i23.Key? key;

  final _i33.StartEquipment equipment;

  @override
  String toString() {
    return 'SelectWeaponsRouteArgs{key: $key, equipment: $equipment}';
  }
}

/// generated route for
/// [_i20.SetPersonalityScreen]
class SetPersonalityRoute extends _i22.PageRouteInfo<void> {
  const SetPersonalityRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SetPersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetPersonalityRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.SetPersonalityScreen();
    },
  );
}

/// generated route for
/// [_i21.SpellsScreen]
class SpellsRoute extends _i22.PageRouteInfo<void> {
  const SpellsRoute({List<_i22.PageRouteInfo>? children})
      : super(
          SpellsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SpellsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i21.SpellsScreen();
    },
  );
}
