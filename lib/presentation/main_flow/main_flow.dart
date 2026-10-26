import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'MainFlowRoute')
class MainFlow extends StatefulWidget {
  final Player player;

  const MainFlow({
    super.key,
    required this.player,
  });

  @override
  State<MainFlow> createState() => _MainFlowState();
}

class _MainFlowState extends State<MainFlow> {
  final _session = getIt<SessionSource>();

  @override
  void dispose() {
    // Персонаж закрыт — мастеру он больше не виден на связи.
    if (_session.isJoined(widget.player)) _session.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PlayerCubit>(param1: widget.player),
      child: BlocConsumer<PlayerCubit, Player>(
        // Хиты, ячейки и ресурсы уходят мастеру при каждом изменении, если персонаж подключён к сессии.
        listener: (context, player) => _session.updatePlayer(player),
        builder: (context, state) => PlayerModel(
          player: state,
          child: AutoTabsScaffold(
            homeIndex: 2,
            // appBarBuilder: (context, tabsRouter) => AppBar(
            //   title: const Text('DnD Character List'),
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.arrow_upward),
            //       onPressed: () {
            //         context.read<PlayerCubit>().levelUp<Bard>();
            //       },
            //     ),
            //   ],
            // ),
            bottomNavigationBuilder: (context, tabsRouter) => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  label: 'Бой',
                  icon: Icon(Icons.sports_mma_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Спеллы',
                  icon: Icon(Icons.back_hand_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Статы',
                  icon: Icon(Icons.format_list_numbered),
                ),
                BottomNavigationBarItem(
                  label: 'Инвентарь',
                  icon: Icon(Icons.inventory),
                ),
                BottomNavigationBarItem(
                  label: 'Перс',
                  icon: Icon(Icons.person),
                ),
              ],
              onTap: tabsRouter.setActiveIndex,
              currentIndex: tabsRouter.activeIndex,
            ),
            routes: const [
              BattleRoute(),
              SpellsRoute(),
              MainRoute(),
              InventoryRoute(),
              PersonalityRoute(),
            ],
          ),
        ),
      ),
    );
  }
}
