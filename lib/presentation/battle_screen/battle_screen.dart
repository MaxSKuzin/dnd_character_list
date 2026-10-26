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
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
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
              children: const [
                // Бой у мастера, эффекты и нокаут бывают не всегда — появляются плавно.
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [BattleQueueBar(), StatusesBar(), KnockoutBanner()],
                  ),
                ),
                SheetHeader(padding: EdgeInsets.symmetric(vertical: 16), child: _Summary()),
                Gap(20),
                _Heading(icon: Icons.favorite_outline, title: 'Состояние'),
                _Counters(),
                Gap(20),
                WeaponsSection(),
                Gap(20),
                // Ячейки — рядом с магией, отступ до неё — в самих ячейках. Без ячеек и без магии разделы пустые и
                // не занимают места.
                SpellSlotsSection(),
                SpellsStatsSection(),
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

/// Хиты, кубы здоровья, спасброски от смерти, кость боевых искусств монаха и ресурсы классов — карточкой с плитками
/// в две колонки, все видны сразу. Плитки одного ряда — одной высоты.
class _Counters extends StatelessWidget {
  const _Counters();

  @override
  Widget build(BuildContext context) {
    final extras = PlayerModel.extras(context);
    final isMonk = PlayerModel.classes(context).any((e) => e is Monk);
    return SheetCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TileGrid(
          columns: 2,
          children: [
            const HealthSection(),
            const HitDices(),
            const DeathThrowsWidget(),
            if (isMonk) const MartialArtsDice(),
            for (final extra in extras.entries) ClassExtraWidget(extra: extra.key, count: extra.value),
          ],
        ),
      ),
    );
  }
}

/// Заголовок раздела экрана боя — над карточкой раздела, как у оружия, ячеек и магии.
class _Heading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Heading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: SheetSectionTitle(icon: icon, title: title),
    );
  }
}
