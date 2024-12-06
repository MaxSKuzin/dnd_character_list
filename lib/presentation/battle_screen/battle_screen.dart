import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/initiative_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/speed_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spell_stats_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spells_stats_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapons_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final dimension = constraints.maxWidth / 3 - 32;
                return SizedBox(
                  height: dimension,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const InitiativeWidget(),
                      const ProtectionWidget(),
                      const SpeedWidget(),
                    ]
                        .map(
                          (e) => SizedBox(
                            width: dimension,
                            child: e,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const Gap(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: ManaSection()),
                const Gap(16),
                const Expanded(child: HealthSection()),
                const Gap(16),
                Expanded(
                  child: Theme(
                    data: context.theme.copyWith(
                      filledButtonTheme: FilledButtonThemeData(
                        style: context.theme.filledButtonTheme.style?.copyWith(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: () async {
                            final damage = await EnterNumberDialog.show(
                              context,
                              title: 'Введите полученный урон',
                              labelText: 'Урон',
                            );
                            if (!mounted || damage == null) return;
                            context.read<PlayerCubit>().takeDamage(damage);
                          },
                          child: const Text('Урон'),
                        ),
                        const Gap(16),
                        FilledButton(
                          onPressed: () async {
                            final health = await EnterNumberDialog.show(
                              context,
                              title: 'Введите здоровье для восстановления',
                              labelText: 'Лечение',
                            );
                            if (!mounted || health == null) return;
                            context.read<PlayerCubit>().heal(health);
                          },
                          child: const Text('Лечение'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ОРУЖИЕ',
                        textAlign: TextAlign.center,
                      ),
                      Gap(8),
                      WeaponsSection(),
                      Gap(16),
                      Text(
                        'МАГИЯ',
                        textAlign: TextAlign.center,
                      ),
                      Gap(8),
                      SpellsStatsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
