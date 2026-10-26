import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'CreateCharacterRoute')
class CreateCharacterFlow extends StatelessWidget {
  const CreateCharacterFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _prefetch();
        return getIt<CreateCharacterCubit>();
      },
      child: BlocListener<CreateCharacterCubit, Player?>(
        listener: (context, state) {
          if (state != null) {
            context.router.pushAndPopUntil(
              MainFlowRoute(player: state),
              predicate: (route) => route.settings.name == SelectCharacterRoute.name,
            );
          }
        },
        child: const AutoRouter(),
      ),
    );
  }

  /// Предыстории, снаряжение и заклинания понадобятся на следующих шагах: их загрузка с сайта
  /// занимает несколько секунд, поэтому начинается сразу. Ошибки покажут сами экраны.
  static void _prefetch() {
    final rules = getIt<RulesRepository>();
    for (final future in [rules.getBackgrounds(), rules.getEquipment(), getIt<SpellsRepository>().getSpells()]) {
      unawaited(future.then<void>((_) {}, onError: (_) {}));
    }
  }
}
