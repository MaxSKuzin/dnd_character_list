import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerCubit(widget.player),
      child: BlocBuilder<PlayerCubit, Player>(
        builder: (context, state) => PlayerModel(
          player: state,
          child: AutoTabsScaffold(
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
                  label: 'Статы',
                  icon: Icon(Icons.format_list_numbered),
                ),
                BottomNavigationBarItem(
                  label: 'Бой',
                  icon: Icon(Icons.sports_mma_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Спеллы',
                  icon: Icon(Icons.back_hand_outlined),
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
              MainRoute(),
              BattleRoute(),
              SpellsRoute(),
              PersonalityRoute(),
            ],
          ),
        ),
      ),
    );
  }
}
