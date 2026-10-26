import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/class_extra_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/death_throws_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/hit_dices.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/initiative_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/knockout_banner.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/martial_arts_dice.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/rest_button.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/speed_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spell_slots_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spells_stats_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapons_section.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/session/battle_queue_bar.dart';
import 'package:dnd_character_list/presentation/session/session_button.dart';
import 'package:dnd_character_list/presentation/session/statuses_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Экран боя: шапка постоянной высоты (сессия мастера, отдых) и одна прокрутка со всем остальным — сводка,
/// счётчики сеткой, ячейки, оружие и магия. Ничего не прячется в горизонтальную прокрутку, а кнопки, которые
/// бывают недоступны, не исчезают, а гаснут, чтобы содержимое не прыгало.
@RoutePage()
class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: SessionButton())),
                RestButton(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                // Бой у мастера, эффекты и нокаут бывают не всегда — появляются плавно.
                const AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [BattleQueueBar(), StatusesBar(), KnockoutBanner()],
                  ),
                ),
                const _Summary(),
                const Gap(16),
                const _Counters(),
                const Gap(24),
                // Без ячеек секция пустая и не занимает места.
                const SpellSlotsSection(),
                const _SectionTitle('ОРУЖИЕ'),
                const WeaponsSection(),
                Builder(
                  builder: (context) {
                    final spellStats = PlayerModel.spellStats(context);
                    if (spellStats.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [const Gap(16), const _SectionTitle('МАГИЯ'), SpellsStatsSection(spellStats)],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Инициатива, КД и скорость — три квадрата в ряд.
class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = constraints.maxWidth / 3 - 24;
        return SizedBox(
          height: dimension,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final widget in const [InitiativeWidget(), ProtectionWidget(), SpeedWidget()])
                SizedBox(width: dimension, child: widget),
            ],
          ),
        );
      },
    );
  }
}

/// Хиты, кубы здоровья, спасброски от смерти, кость боевых искусств монаха и ресурсы классов — сеткой в две колонки,
/// все видны сразу.
class _Counters extends StatelessWidget {
  static const _spacing = 16.0;

  const _Counters();

  @override
  Widget build(BuildContext context) {
    final extras = PlayerModel.extras(context);
    final isMonk = PlayerModel.classes(context).any((e) => e is Monk);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _spacing) / 2;
        // Пропорции плиток прежние: вдвое шире, чем выше.
        final height = width / 2;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            const HealthSection(),
            const HitDices(),
            const DeathThrowsWidget(),
            if (isMonk) const MartialArtsDice(),
            for (final extra in extras.entries) ClassExtraWidget(extra: extra.key, count: extra.value),
          ].map((e) => SizedBox(width: width, height: height, child: e)).toList(),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
