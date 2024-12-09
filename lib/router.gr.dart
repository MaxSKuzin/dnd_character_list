// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:dnd_character_list/presentation/battle_screen/battle_screen.dart'
    as _i1;
import 'package:dnd_character_list/presentation/main_flow/main_flow.dart'
    as _i2;
import 'package:dnd_character_list/presentation/main_screen/main_screen.dart'
    as _i3;
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart'
    as _i4;
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart'
    as _i5;

/// generated route for
/// [_i1.BattleScreen]
class BattleRoute extends _i6.PageRouteInfo<void> {
  const BattleRoute({List<_i6.PageRouteInfo>? children})
      : super(
          BattleRoute.name,
          initialChildren: children,
        );

  static const String name = 'BattleRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.BattleScreen();
    },
  );
}

/// generated route for
/// [_i2.MainFlow]
class MainFlowRoute extends _i6.PageRouteInfo<void> {
  const MainFlowRoute({List<_i6.PageRouteInfo>? children})
      : super(
          MainFlowRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainFlowRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.MainFlow();
    },
  );
}

/// generated route for
/// [_i3.MainScreen]
class MainRoute extends _i6.PageRouteInfo<void> {
  const MainRoute({List<_i6.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.MainScreen();
    },
  );
}

/// generated route for
/// [_i4.PersonalityScreen]
class PersonalityRoute extends _i6.PageRouteInfo<void> {
  const PersonalityRoute({List<_i6.PageRouteInfo>? children})
      : super(
          PersonalityRoute.name,
          initialChildren: children,
        );

  static const String name = 'PersonalityRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.PersonalityScreen();
    },
  );
}

/// generated route for
/// [_i5.SpellsScreen]
class SpellsRoute extends _i6.PageRouteInfo<void> {
  const SpellsRoute({List<_i6.PageRouteInfo>? children})
      : super(
          SpellsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SpellsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.SpellsScreen();
    },
  );
}
