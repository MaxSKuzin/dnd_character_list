import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'LevelUpFlowRoute')
class LevelUpFlow extends StatelessWidget {
  final Player player;

  const LevelUpFlow({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LevelUpCubit>(param1: player),
      child: BlocListener<LevelUpCubit, Player?>(
        listener: (context, state) {
          if (state != null) {
            context.router.pushAndPopUntil(
              MainFlowRoute(player: state),
              predicate: (route) => route.settings.name == SelectCharacterRoute.name,
            );
          }
        },
        child: PlayerModel(
          player: player,
          child: const AutoRouter(),
        ),
      ),
    );
  }
}
