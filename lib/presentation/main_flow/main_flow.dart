import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/bard.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'MainFlowRoute')
class MainFlow extends StatefulWidget {
  const MainFlow({super.key});

  @override
  State<MainFlow> createState() => _MainFlowState();
}

class _MainFlowState extends State<MainFlow> {
  Player setPlayer() {
    return Player(
      weapons: [
        Weapon.rapier(),
        Weapon.dagger(),
      ],
      shield: null,
      armor: Armor.leather(),
      strength: 11,
      dexterity: 17,
      constitution: 15,
      intelligence: 10,
      wisdom: 13,
      charisma: 16,
      classes: [
        Bard(
          level: 1,
          isMain: true,
        ),
      ],
      chosenSkills: [
        Skill.acrobatics,
        Skill.fraud,
        Skill.harassment,
        Skill.conviction,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerCubit(setPlayer()),
      child: BlocBuilder<PlayerCubit, Player>(
        builder: (context, state) => PlayerModel(
          player: state,
          child: AutoTabsScaffold(
            bottomNavigationBuilder: (context, tabsRouter) => BottomNavigationBar(
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
              PersonalityRoute(),
            ],
          ),
        ),
      ),
    );
  }
}
