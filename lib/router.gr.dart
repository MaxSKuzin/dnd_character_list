// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i41;

import 'package:auto_route/auto_route.dart' as _i27;
import 'package:dnd_character_list/domain/bloc/player_cubit.dart' as _i32;
import 'package:dnd_character_list/domain/models/background.dart' as _i44;
import 'package:dnd_character_list/domain/models/class_info.dart' as _i43;
import 'package:dnd_character_list/domain/models/classes/class_kind.dart'
    as _i37;
import 'package:dnd_character_list/domain/models/equipment_catalog.dart'
    as _i35;
import 'package:dnd_character_list/domain/models/feat.dart' as _i30;
import 'package:dnd_character_list/domain/models/fighting_style.dart' as _i40;
import 'package:dnd_character_list/domain/models/inventory.dart' as _i46;
import 'package:dnd_character_list/domain/models/language.dart' as _i33;
import 'package:dnd_character_list/domain/models/player.dart' as _i29;
import 'package:dnd_character_list/domain/models/skill.dart' as _i42;
import 'package:dnd_character_list/domain/models/spell/spell.dart' as _i36;
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart'
    as _i39;
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart' as _i38;
import 'package:dnd_character_list/domain/models/starting_equipment.dart'
    as _i45;
import 'package:dnd_character_list/domain/models/stat_kind.dart' as _i31;
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart'
    as _i34;
import 'package:dnd_character_list/presentation/battle_screen/battle_screen.dart'
    as _i2;
import 'package:dnd_character_list/presentation/create_character_flow/create_character_flow.dart'
    as _i3;
import 'package:dnd_character_list/presentation/create_character_flow/screens/fill_stats_screen/fill_stats_screen.dart'
    as _i4;
import 'package:dnd_character_list/presentation/create_character_flow/screens/proficiencies_screen/proficiencies_screen.dart'
    as _i13;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_background_screen/select_background_screen.dart'
    as _i15;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_class_screen/select_class_screen.dart'
    as _i17;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart'
    as _i19;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_race_screen/select_race_screen.dart'
    as _i20;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_skills_screen/select_skills_screen.dart'
    as _i21;
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_spells_screen/select_spells_screen.dart'
    as _i22;
import 'package:dnd_character_list/presentation/create_character_flow/screens/set_personality_screen/set_personality_screen.dart'
    as _i24;
import 'package:dnd_character_list/presentation/create_character_flow/screens/starting_equipment_screen/starting_equipment_screen.dart'
    as _i26;
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/Inventory_add_item_screen.dart'
    as _i5;
import 'package:dnd_character_list/presentation/inventory_screen/inventory_screen.dart'
    as _i6;
import 'package:dnd_character_list/presentation/inventory_screen/item_catalog_screen.dart'
    as _i7;
import 'package:dnd_character_list/presentation/level_up_flow/level_up_class_screen.dart'
    as _i8;
import 'package:dnd_character_list/presentation/level_up_flow/level_up_flow.dart'
    as _i9;
import 'package:dnd_character_list/presentation/level_up_flow/screens/ability_score_improvement_screen.dart'
    as _i1;
import 'package:dnd_character_list/presentation/level_up_flow/screens/replace_spell_screen.dart'
    as _i14;
import 'package:dnd_character_list/presentation/level_up_flow/screens/select_fighting_style_screen.dart'
    as _i18;
import 'package:dnd_character_list/presentation/level_up_flow/screens/select_subclass_screen.dart'
    as _i23;
import 'package:dnd_character_list/presentation/main_flow/main_flow.dart'
    as _i10;
import 'package:dnd_character_list/presentation/main_screen/main_screen.dart'
    as _i11;
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart'
    as _i12;
import 'package:dnd_character_list/presentation/select_character_screen/select_character_screen.dart'
    as _i16;
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart'
    as _i25;
import 'package:flutter/material.dart' as _i28;

/// generated route for
/// [_i1.AbilityScoreImprovementScreen]
class AbilityScoreImprovementRoute
    extends _i27.PageRouteInfo<AbilityScoreImprovementRouteArgs> {
  AbilityScoreImprovementRoute({
    _i28.Key? key,
    required _i29.Player player,
    required int level,
    required void Function(_i30.AbilityScoreImprovement) onSelected,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AbilityScoreImprovementRoute.name,
         args: AbilityScoreImprovementRouteArgs(
           key: key,
           player: player,
           level: level,
           onSelected: onSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'AbilityScoreImprovementRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AbilityScoreImprovementRouteArgs>();
      return _i1.AbilityScoreImprovementScreen(
        key: args.key,
        player: args.player,
        level: args.level,
        onSelected: args.onSelected,
      );
    },
  );
}

class AbilityScoreImprovementRouteArgs {
  const AbilityScoreImprovementRouteArgs({
    this.key,
    required this.player,
    required this.level,
    required this.onSelected,
  });

  final _i28.Key? key;

  final _i29.Player player;

  final int level;

  final void Function(_i30.AbilityScoreImprovement) onSelected;

  @override
  String toString() {
    return 'AbilityScoreImprovementRouteArgs{key: $key, player: $player, level: $level, onSelected: $onSelected}';
  }
}

/// generated route for
/// [_i2.BattleScreen]
class BattleRoute extends _i27.PageRouteInfo<void> {
  const BattleRoute({List<_i27.PageRouteInfo>? children})
    : super(BattleRoute.name, initialChildren: children);

  static const String name = 'BattleRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i2.BattleScreen();
    },
  );
}

/// generated route for
/// [_i3.CreateCharacterFlow]
class CreateCharacterRoute extends _i27.PageRouteInfo<void> {
  const CreateCharacterRoute({List<_i27.PageRouteInfo>? children})
    : super(CreateCharacterRoute.name, initialChildren: children);

  static const String name = 'CreateCharacterRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i3.CreateCharacterFlow();
    },
  );
}

/// generated route for
/// [_i4.FillStatsScreen]
class FillStatsRoute extends _i27.PageRouteInfo<FillStatsRouteArgs> {
  FillStatsRoute({
    _i28.Key? key,
    String? title,
    String? description,
    bool isInitial = true,
    bool canSpendOnOneStat = true,
    int maxPoints = 27,
    Map<_i31.StatKind, int> initialStats = const {},
    List<_i31.StatKind> forbiddenStats = const [],
    String? quickBuildHtml,
    required void Function(Map<_i31.StatKind, int>) onStatsFilled,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         FillStatsRoute.name,
         args: FillStatsRouteArgs(
           key: key,
           title: title,
           description: description,
           isInitial: isInitial,
           canSpendOnOneStat: canSpendOnOneStat,
           maxPoints: maxPoints,
           initialStats: initialStats,
           forbiddenStats: forbiddenStats,
           quickBuildHtml: quickBuildHtml,
           onStatsFilled: onStatsFilled,
         ),
         initialChildren: children,
       );

  static const String name = 'FillStatsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FillStatsRouteArgs>();
      return _i4.FillStatsScreen(
        key: args.key,
        title: args.title,
        description: args.description,
        isInitial: args.isInitial,
        canSpendOnOneStat: args.canSpendOnOneStat,
        maxPoints: args.maxPoints,
        initialStats: args.initialStats,
        forbiddenStats: args.forbiddenStats,
        quickBuildHtml: args.quickBuildHtml,
        onStatsFilled: args.onStatsFilled,
      );
    },
  );
}

class FillStatsRouteArgs {
  const FillStatsRouteArgs({
    this.key,
    this.title,
    this.description,
    this.isInitial = true,
    this.canSpendOnOneStat = true,
    this.maxPoints = 27,
    this.initialStats = const {},
    this.forbiddenStats = const [],
    this.quickBuildHtml,
    required this.onStatsFilled,
  });

  final _i28.Key? key;

  final String? title;

  final String? description;

  final bool isInitial;

  final bool canSpendOnOneStat;

  final int maxPoints;

  final Map<_i31.StatKind, int> initialStats;

  final List<_i31.StatKind> forbiddenStats;

  final String? quickBuildHtml;

  final void Function(Map<_i31.StatKind, int>) onStatsFilled;

  @override
  String toString() {
    return 'FillStatsRouteArgs{key: $key, title: $title, description: $description, isInitial: $isInitial, canSpendOnOneStat: $canSpendOnOneStat, maxPoints: $maxPoints, initialStats: $initialStats, forbiddenStats: $forbiddenStats, quickBuildHtml: $quickBuildHtml, onStatsFilled: $onStatsFilled}';
  }
}

/// generated route for
/// [_i5.InventoryAddItemScreen]
class InventoryAddItemRoute
    extends _i27.PageRouteInfo<InventoryAddItemRouteArgs> {
  InventoryAddItemRoute({
    _i28.Key? key,
    required Type itemType,
    required _i32.PlayerCubit playerCubit,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         InventoryAddItemRoute.name,
         args: InventoryAddItemRouteArgs(
           key: key,
           itemType: itemType,
           playerCubit: playerCubit,
         ),
         initialChildren: children,
       );

  static const String name = 'InventoryAddItemRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InventoryAddItemRouteArgs>();
      return _i5.InventoryAddItemScreen(
        key: args.key,
        itemType: args.itemType,
        playerCubit: args.playerCubit,
      );
    },
  );
}

class InventoryAddItemRouteArgs {
  const InventoryAddItemRouteArgs({
    this.key,
    required this.itemType,
    required this.playerCubit,
  });

  final _i28.Key? key;

  final Type itemType;

  final _i32.PlayerCubit playerCubit;

  @override
  String toString() {
    return 'InventoryAddItemRouteArgs{key: $key, itemType: $itemType, playerCubit: $playerCubit}';
  }
}

/// generated route for
/// [_i6.InventoryScreen]
class InventoryRoute extends _i27.PageRouteInfo<void> {
  const InventoryRoute({List<_i27.PageRouteInfo>? children})
    : super(InventoryRoute.name, initialChildren: children);

  static const String name = 'InventoryRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i6.InventoryScreen();
    },
  );
}

/// generated route for
/// [_i7.ItemCatalogScreen]
class ItemCatalogRoute extends _i27.PageRouteInfo<ItemCatalogRouteArgs> {
  ItemCatalogRoute({
    _i28.Key? key,
    required _i32.PlayerCubit playerCubit,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ItemCatalogRoute.name,
         args: ItemCatalogRouteArgs(key: key, playerCubit: playerCubit),
         initialChildren: children,
       );

  static const String name = 'ItemCatalogRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ItemCatalogRouteArgs>();
      return _i7.ItemCatalogScreen(
        key: args.key,
        playerCubit: args.playerCubit,
      );
    },
  );
}

class ItemCatalogRouteArgs {
  const ItemCatalogRouteArgs({this.key, required this.playerCubit});

  final _i28.Key? key;

  final _i32.PlayerCubit playerCubit;

  @override
  String toString() {
    return 'ItemCatalogRouteArgs{key: $key, playerCubit: $playerCubit}';
  }
}

/// generated route for
/// [_i8.LevelUpClassScreen]
class LevelUpClassRoute extends _i27.PageRouteInfo<void> {
  const LevelUpClassRoute({List<_i27.PageRouteInfo>? children})
    : super(LevelUpClassRoute.name, initialChildren: children);

  static const String name = 'LevelUpClassRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i8.LevelUpClassScreen();
    },
  );
}

/// generated route for
/// [_i9.LevelUpFlow]
class LevelUpFlowRoute extends _i27.PageRouteInfo<LevelUpFlowRouteArgs> {
  LevelUpFlowRoute({
    _i28.Key? key,
    required _i29.Player player,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         LevelUpFlowRoute.name,
         args: LevelUpFlowRouteArgs(key: key, player: player),
         initialChildren: children,
       );

  static const String name = 'LevelUpFlowRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LevelUpFlowRouteArgs>();
      return _i9.LevelUpFlow(key: args.key, player: args.player);
    },
  );
}

class LevelUpFlowRouteArgs {
  const LevelUpFlowRouteArgs({this.key, required this.player});

  final _i28.Key? key;

  final _i29.Player player;

  @override
  String toString() {
    return 'LevelUpFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i10.MainFlow]
class MainFlowRoute extends _i27.PageRouteInfo<MainFlowRouteArgs> {
  MainFlowRoute({
    _i28.Key? key,
    required _i29.Player player,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         MainFlowRoute.name,
         args: MainFlowRouteArgs(key: key, player: player),
         initialChildren: children,
       );

  static const String name = 'MainFlowRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MainFlowRouteArgs>();
      return _i10.MainFlow(key: args.key, player: args.player);
    },
  );
}

class MainFlowRouteArgs {
  const MainFlowRouteArgs({this.key, required this.player});

  final _i28.Key? key;

  final _i29.Player player;

  @override
  String toString() {
    return 'MainFlowRouteArgs{key: $key, player: $player}';
  }
}

/// generated route for
/// [_i11.MainScreen]
class MainRoute extends _i27.PageRouteInfo<void> {
  const MainRoute({List<_i27.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i11.MainScreen();
    },
  );
}

/// generated route for
/// [_i12.PersonalityScreen]
class PersonalityRoute extends _i27.PageRouteInfo<void> {
  const PersonalityRoute({List<_i27.PageRouteInfo>? children})
    : super(PersonalityRoute.name, initialChildren: children);

  static const String name = 'PersonalityRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i12.PersonalityScreen();
    },
  );
}

/// generated route for
/// [_i13.ProficienciesScreen]
class ProficienciesRoute extends _i27.PageRouteInfo<ProficienciesRouteArgs> {
  ProficienciesRoute({
    _i28.Key? key,
    required String title,
    required void Function(List<String>, List<_i33.Language>) onSelected,
    String? description,
    List<_i34.ToolProficiencyOption> tools = const [],
    int languagesCount = 0,
    List<_i33.Language> knownLanguages = const [],
    List<String> knownTools = const [],
    _i35.EquipmentCatalog? catalog,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ProficienciesRoute.name,
         args: ProficienciesRouteArgs(
           key: key,
           title: title,
           onSelected: onSelected,
           description: description,
           tools: tools,
           languagesCount: languagesCount,
           knownLanguages: knownLanguages,
           knownTools: knownTools,
           catalog: catalog,
         ),
         initialChildren: children,
       );

  static const String name = 'ProficienciesRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProficienciesRouteArgs>();
      return _i13.ProficienciesScreen(
        key: args.key,
        title: args.title,
        onSelected: args.onSelected,
        description: args.description,
        tools: args.tools,
        languagesCount: args.languagesCount,
        knownLanguages: args.knownLanguages,
        knownTools: args.knownTools,
        catalog: args.catalog,
      );
    },
  );
}

class ProficienciesRouteArgs {
  const ProficienciesRouteArgs({
    this.key,
    required this.title,
    required this.onSelected,
    this.description,
    this.tools = const [],
    this.languagesCount = 0,
    this.knownLanguages = const [],
    this.knownTools = const [],
    this.catalog,
  });

  final _i28.Key? key;

  final String title;

  final void Function(List<String>, List<_i33.Language>) onSelected;

  final String? description;

  final List<_i34.ToolProficiencyOption> tools;

  final int languagesCount;

  final List<_i33.Language> knownLanguages;

  final List<String> knownTools;

  final _i35.EquipmentCatalog? catalog;

  @override
  String toString() {
    return 'ProficienciesRouteArgs{key: $key, title: $title, onSelected: $onSelected, description: $description, tools: $tools, languagesCount: $languagesCount, knownLanguages: $knownLanguages, knownTools: $knownTools, catalog: $catalog}';
  }
}

/// generated route for
/// [_i14.ReplaceSpellScreen]
class ReplaceSpellRoute extends _i27.PageRouteInfo<ReplaceSpellRouteArgs> {
  ReplaceSpellRoute({
    _i28.Key? key,
    required String title,
    required String description,
    required List<_i36.Spell> replaceableSpells,
    required _i37.ClassKind classKind,
    required List<_i38.SpellSlot> newSpellSlots,
    required List<_i36.Spell> knownSpells,
    required void Function(_i39.SpellReplacement?) onSelected,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ReplaceSpellRoute.name,
         args: ReplaceSpellRouteArgs(
           key: key,
           title: title,
           description: description,
           replaceableSpells: replaceableSpells,
           classKind: classKind,
           newSpellSlots: newSpellSlots,
           knownSpells: knownSpells,
           onSelected: onSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'ReplaceSpellRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReplaceSpellRouteArgs>();
      return _i14.ReplaceSpellScreen(
        key: args.key,
        title: args.title,
        description: args.description,
        replaceableSpells: args.replaceableSpells,
        classKind: args.classKind,
        newSpellSlots: args.newSpellSlots,
        knownSpells: args.knownSpells,
        onSelected: args.onSelected,
      );
    },
  );
}

class ReplaceSpellRouteArgs {
  const ReplaceSpellRouteArgs({
    this.key,
    required this.title,
    required this.description,
    required this.replaceableSpells,
    required this.classKind,
    required this.newSpellSlots,
    required this.knownSpells,
    required this.onSelected,
  });

  final _i28.Key? key;

  final String title;

  final String description;

  final List<_i36.Spell> replaceableSpells;

  final _i37.ClassKind classKind;

  final List<_i38.SpellSlot> newSpellSlots;

  final List<_i36.Spell> knownSpells;

  final void Function(_i39.SpellReplacement?) onSelected;

  @override
  String toString() {
    return 'ReplaceSpellRouteArgs{key: $key, title: $title, description: $description, replaceableSpells: $replaceableSpells, classKind: $classKind, newSpellSlots: $newSpellSlots, knownSpells: $knownSpells, onSelected: $onSelected}';
  }
}

/// generated route for
/// [_i15.SelectBackgroundScreen]
class SelectBackgroundRoute
    extends _i27.PageRouteInfo<SelectBackgroundRouteArgs> {
  SelectBackgroundRoute({
    _i28.Key? key,
    required _i28.VoidCallback onContinue,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectBackgroundRoute.name,
         args: SelectBackgroundRouteArgs(key: key, onContinue: onContinue),
         initialChildren: children,
       );

  static const String name = 'SelectBackgroundRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectBackgroundRouteArgs>();
      return _i15.SelectBackgroundScreen(
        key: args.key,
        onContinue: args.onContinue,
      );
    },
  );
}

class SelectBackgroundRouteArgs {
  const SelectBackgroundRouteArgs({this.key, required this.onContinue});

  final _i28.Key? key;

  final _i28.VoidCallback onContinue;

  @override
  String toString() {
    return 'SelectBackgroundRouteArgs{key: $key, onContinue: $onContinue}';
  }
}

/// generated route for
/// [_i16.SelectCharacterScreen]
class SelectCharacterRoute extends _i27.PageRouteInfo<void> {
  const SelectCharacterRoute({List<_i27.PageRouteInfo>? children})
    : super(SelectCharacterRoute.name, initialChildren: children);

  static const String name = 'SelectCharacterRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i16.SelectCharacterScreen();
    },
  );
}

/// generated route for
/// [_i17.SelectClassScreen]
class SelectClassRoute extends _i27.PageRouteInfo<void> {
  const SelectClassRoute({List<_i27.PageRouteInfo>? children})
    : super(SelectClassRoute.name, initialChildren: children);

  static const String name = 'SelectClassRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i17.SelectClassScreen();
    },
  );
}

/// generated route for
/// [_i18.SelectFightingStyleScreen]
class SelectFightingStyleRoute
    extends _i27.PageRouteInfo<SelectFightingStyleRouteArgs> {
  SelectFightingStyleRoute({
    _i28.Key? key,
    required void Function(_i40.FightingStyle) onStyleSelected,
    List<_i40.FightingStyle>? styles,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectFightingStyleRoute.name,
         args: SelectFightingStyleRouteArgs(
           key: key,
           onStyleSelected: onStyleSelected,
           styles: styles,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectFightingStyleRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectFightingStyleRouteArgs>();
      return _i18.SelectFightingStyleScreen(
        key: args.key,
        onStyleSelected: args.onStyleSelected,
        styles: args.styles,
      );
    },
  );
}

class SelectFightingStyleRouteArgs {
  const SelectFightingStyleRouteArgs({
    this.key,
    required this.onStyleSelected,
    this.styles,
  });

  final _i28.Key? key;

  final void Function(_i40.FightingStyle) onStyleSelected;

  final List<_i40.FightingStyle>? styles;

  @override
  String toString() {
    return 'SelectFightingStyleRouteArgs{key: $key, onStyleSelected: $onStyleSelected, styles: $styles}';
  }
}

/// generated route for
/// [_i19.SelectOptionScreen]
class SelectOptionRoute extends _i27.PageRouteInfo<SelectOptionRouteArgs> {
  SelectOptionRoute({
    _i28.Key? key,
    required String title,
    String? description,
    required List<_i19.SelectOption> options,
    required _i41.FutureOr<void> Function(int) onSelected,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectOptionRoute.name,
         args: SelectOptionRouteArgs(
           key: key,
           title: title,
           description: description,
           options: options,
           onSelected: onSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectOptionRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectOptionRouteArgs>();
      return _i19.SelectOptionScreen(
        key: args.key,
        title: args.title,
        description: args.description,
        options: args.options,
        onSelected: args.onSelected,
      );
    },
  );
}

class SelectOptionRouteArgs {
  const SelectOptionRouteArgs({
    this.key,
    required this.title,
    this.description,
    required this.options,
    required this.onSelected,
  });

  final _i28.Key? key;

  final String title;

  final String? description;

  final List<_i19.SelectOption> options;

  final _i41.FutureOr<void> Function(int) onSelected;

  @override
  String toString() {
    return 'SelectOptionRouteArgs{key: $key, title: $title, description: $description, options: $options, onSelected: $onSelected}';
  }
}

/// generated route for
/// [_i20.SelectRaceScreen]
class SelectRaceRoute extends _i27.PageRouteInfo<void> {
  const SelectRaceRoute({List<_i27.PageRouteInfo>? children})
    : super(SelectRaceRoute.name, initialChildren: children);

  static const String name = 'SelectRaceRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i20.SelectRaceScreen();
    },
  );
}

/// generated route for
/// [_i21.SelectSkillsScreen]
class SelectSkillsRoute extends _i27.PageRouteInfo<SelectSkillsRouteArgs> {
  SelectSkillsRoute({
    _i28.Key? key,
    String title = 'Навыки',
    String? description,
    required List<_i42.Skill> availableSkills,
    required int maxSkills,
    required void Function(List<_i42.Skill>) onSkillsSelected,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectSkillsRoute.name,
         args: SelectSkillsRouteArgs(
           key: key,
           title: title,
           description: description,
           availableSkills: availableSkills,
           maxSkills: maxSkills,
           onSkillsSelected: onSkillsSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectSkillsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSkillsRouteArgs>();
      return _i21.SelectSkillsScreen(
        key: args.key,
        title: args.title,
        description: args.description,
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
    this.title = 'Навыки',
    this.description,
    required this.availableSkills,
    required this.maxSkills,
    required this.onSkillsSelected,
  });

  final _i28.Key? key;

  final String title;

  final String? description;

  final List<_i42.Skill> availableSkills;

  final int maxSkills;

  final void Function(List<_i42.Skill>) onSkillsSelected;

  @override
  String toString() {
    return 'SelectSkillsRouteArgs{key: $key, title: $title, description: $description, availableSkills: $availableSkills, maxSkills: $maxSkills, onSkillsSelected: $onSkillsSelected}';
  }
}

/// generated route for
/// [_i22.SelectSpellsScreen]
class SelectSpellsRoute extends _i27.PageRouteInfo<SelectSpellsRouteArgs> {
  SelectSpellsRoute({
    _i28.Key? key,
    List<_i36.Spell> knownSpells = const [],
    List<_i38.SpellSlot>? availableSlots,
    String title = 'Заклинания',
    String? description,
    List<_i37.ClassKind>? additionalClassKinds,
    bool cantripsCountAsSpells = false,
    required void Function(List<_i36.Spell>) onSpellsSelected,
    required int maxSpells,
    required int maxConspiracies,
    required _i37.ClassKind? classKind,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectSpellsRoute.name,
         args: SelectSpellsRouteArgs(
           key: key,
           knownSpells: knownSpells,
           availableSlots: availableSlots,
           title: title,
           description: description,
           additionalClassKinds: additionalClassKinds,
           cantripsCountAsSpells: cantripsCountAsSpells,
           onSpellsSelected: onSpellsSelected,
           maxSpells: maxSpells,
           maxConspiracies: maxConspiracies,
           classKind: classKind,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectSpellsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSpellsRouteArgs>();
      return _i22.SelectSpellsScreen(
        key: args.key,
        knownSpells: args.knownSpells,
        availableSlots: args.availableSlots,
        title: args.title,
        description: args.description,
        additionalClassKinds: args.additionalClassKinds,
        cantripsCountAsSpells: args.cantripsCountAsSpells,
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
    this.title = 'Заклинания',
    this.description,
    this.additionalClassKinds,
    this.cantripsCountAsSpells = false,
    required this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  });

  final _i28.Key? key;

  final List<_i36.Spell> knownSpells;

  final List<_i38.SpellSlot>? availableSlots;

  final String title;

  final String? description;

  final List<_i37.ClassKind>? additionalClassKinds;

  final bool cantripsCountAsSpells;

  final void Function(List<_i36.Spell>) onSpellsSelected;

  final int maxSpells;

  final int maxConspiracies;

  final _i37.ClassKind? classKind;

  @override
  String toString() {
    return 'SelectSpellsRouteArgs{key: $key, knownSpells: $knownSpells, availableSlots: $availableSlots, title: $title, description: $description, additionalClassKinds: $additionalClassKinds, cantripsCountAsSpells: $cantripsCountAsSpells, onSpellsSelected: $onSpellsSelected, maxSpells: $maxSpells, maxConspiracies: $maxConspiracies, classKind: $classKind}';
  }
}

/// generated route for
/// [_i23.SelectSubclassScreen]
class SelectSubclassRoute extends _i27.PageRouteInfo<SelectSubclassRouteArgs> {
  SelectSubclassRoute({
    _i28.Key? key,
    required String title,
    String? description,
    required List<_i43.Subclass> subclasses,
    required _i41.FutureOr<void> Function(_i43.Subclass) onSelected,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SelectSubclassRoute.name,
         args: SelectSubclassRouteArgs(
           key: key,
           title: title,
           description: description,
           subclasses: subclasses,
           onSelected: onSelected,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectSubclassRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectSubclassRouteArgs>();
      return _i23.SelectSubclassScreen(
        key: args.key,
        title: args.title,
        description: args.description,
        subclasses: args.subclasses,
        onSelected: args.onSelected,
      );
    },
  );
}

class SelectSubclassRouteArgs {
  const SelectSubclassRouteArgs({
    this.key,
    required this.title,
    this.description,
    required this.subclasses,
    required this.onSelected,
  });

  final _i28.Key? key;

  final String title;

  final String? description;

  final List<_i43.Subclass> subclasses;

  final _i41.FutureOr<void> Function(_i43.Subclass) onSelected;

  @override
  String toString() {
    return 'SelectSubclassRouteArgs{key: $key, title: $title, description: $description, subclasses: $subclasses, onSelected: $onSelected}';
  }
}

/// generated route for
/// [_i24.SetPersonalityScreen]
class SetPersonalityRoute extends _i27.PageRouteInfo<SetPersonalityRouteArgs> {
  SetPersonalityRoute({
    _i28.Key? key,
    List<_i44.PersonalityTable> tables = const [],
    List<_i27.PageRouteInfo>? children,
  }) : super(
         SetPersonalityRoute.name,
         args: SetPersonalityRouteArgs(key: key, tables: tables),
         initialChildren: children,
       );

  static const String name = 'SetPersonalityRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SetPersonalityRouteArgs>(
        orElse: () => const SetPersonalityRouteArgs(),
      );
      return _i24.SetPersonalityScreen(key: args.key, tables: args.tables);
    },
  );
}

class SetPersonalityRouteArgs {
  const SetPersonalityRouteArgs({this.key, this.tables = const []});

  final _i28.Key? key;

  final List<_i44.PersonalityTable> tables;

  @override
  String toString() {
    return 'SetPersonalityRouteArgs{key: $key, tables: $tables}';
  }
}

/// generated route for
/// [_i25.SpellsScreen]
class SpellsRoute extends _i27.PageRouteInfo<void> {
  const SpellsRoute({List<_i27.PageRouteInfo>? children})
    : super(SpellsRoute.name, initialChildren: children);

  static const String name = 'SpellsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i25.SpellsScreen();
    },
  );
}

/// generated route for
/// [_i26.StartingEquipmentScreen]
class StartingEquipmentRoute
    extends _i27.PageRouteInfo<StartingEquipmentRouteArgs> {
  StartingEquipmentRoute({
    _i28.Key? key,
    required String title,
    required List<_i45.StartingEquipmentChoice> choices,
    required void Function(List<_i46.InventoryItem>) onSelected,
    _i35.EquipmentCatalog? catalog,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         StartingEquipmentRoute.name,
         args: StartingEquipmentRouteArgs(
           key: key,
           title: title,
           choices: choices,
           onSelected: onSelected,
           catalog: catalog,
         ),
         initialChildren: children,
       );

  static const String name = 'StartingEquipmentRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StartingEquipmentRouteArgs>();
      return _i26.StartingEquipmentScreen(
        key: args.key,
        title: args.title,
        choices: args.choices,
        onSelected: args.onSelected,
        catalog: args.catalog,
      );
    },
  );
}

class StartingEquipmentRouteArgs {
  const StartingEquipmentRouteArgs({
    this.key,
    required this.title,
    required this.choices,
    required this.onSelected,
    this.catalog,
  });

  final _i28.Key? key;

  final String title;

  final List<_i45.StartingEquipmentChoice> choices;

  final void Function(List<_i46.InventoryItem>) onSelected;

  final _i35.EquipmentCatalog? catalog;

  @override
  String toString() {
    return 'StartingEquipmentRouteArgs{key: $key, title: $title, choices: $choices, onSelected: $onSelected, catalog: $catalog}';
  }
}
