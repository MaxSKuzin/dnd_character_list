import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Характеристики: шапка с бонусом мастерства и пассивным восприятием, характеристики плитками, спасброски
/// и навыки по характеристикам с отметкой владения и компетентности.
@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            Gap(16),
            _Stats(),
            Gap(16),
            _SaveThrows(),
            Gap(16),
            _Skills(),
          ],
        ),
      ),
    );
  }
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    final valueStyle = context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);
    return SheetHeader(
      child: TileGrid(
        columns: 2,
        children: [
          InfoTile(label: 'Бонус мастерства', value: _signed(player.proficiencyBonus), valueStyle: valueStyle),
          // Пассивная Мудрость (Восприятие): замечать скрытое, не ища специально.
          InfoTile(
            label: 'Пассивное восприятие',
            value: '${player.passivePerception}',
            caption: 'Мудрость (Восприятие)',
            valueStyle: valueStyle,
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final stats = PlayerModel.stats(context);
    return SheetSection(
      icon: Icons.fitness_center,
      title: 'Характеристики',
      child: TileGrid(
        columns: 3,
        children: [
          for (final stat in stats.values)
            InfoTile(
              label: stat.kind.localizedName,
              value: _signed(stat.bonus),
              caption: '${stat.value}',
              valueStyle: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _SaveThrows extends StatelessWidget {
  const _SaveThrows();

  @override
  Widget build(BuildContext context) {
    final saves = PlayerModel.saveThrows(context);
    return SheetSection(
      icon: Icons.shield_outlined,
      title: 'Спасброски',
      child: TileGrid(
        columns: 2,
        spacing: 4,
        children: [
          for (final save in saves)
            _CheckRow(name: save.origin.localizedName, bonus: save.bonus, isProficient: save.isChosen),
        ],
      ),
    );
  }
}

/// Навыки по характеристикам: «Ловкость» — Акробатика, Ловкость рук, Скрытность.
class _Skills extends StatelessWidget {
  const _Skills();

  @override
  Widget build(BuildContext context) {
    final skills = PlayerModel.skills(context);
    final expertise = PlayerModel.watch(context).expertiseSkills;
    final byStat = groupBy(skills, (e) => e.origin.origin);
    return SheetSection(
      icon: Icons.school_outlined,
      title: 'Навыки',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, stat) in StatKind.values.where(byStat.containsKey).indexed) ...[
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 12, bottom: 4),
              child: Text(
                stat.localizedName,
                style: context.theme.textTheme.labelMedium?.copyWith(color: context.theme.colorScheme.primary),
              ),
            ),
            for (final skill in byStat[stat]!.sortedBy((e) => e.origin.localizedName))
              _CheckRow(
                key: Key(skill.origin.name),
                name: skill.origin.localizedName,
                bonus: skill.bonus,
                isProficient: skill.isChosen,
                isExpert: expertise.contains(skill.origin),
              ),
          ],
          const Gap(12),
          Text(
            '● владение   ★ компетентность',
            style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

/// Строка спасброска или навыка: отметка владения, бонус и название.
class _CheckRow extends StatelessWidget {
  final String name;
  final int bonus;
  final bool isProficient;
  final bool isExpert;

  const _CheckRow(
      {super.key, required this.name, required this.bonus, required this.isProficient, this.isExpert = false});

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Icon(
              isExpert ? Icons.star : (isProficient ? Icons.circle : Icons.circle_outlined),
              size: isExpert ? 16 : 12,
              color: isProficient || isExpert ? primary : Colors.white38,
            ),
          ),
          const Gap(6),
          SizedBox(
            width: 32,
            child: Text(
              _signed(bonus),
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w700, color: isProficient || isExpert ? null : Colors.white70),
            ),
          ),
          const Gap(10),
          // Длинное название («Телосложение» в две колонки) уменьшается, а не переносится.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(name, maxLines: 1, softWrap: false),
            ),
          ),
        ],
      ),
    );
  }
}
