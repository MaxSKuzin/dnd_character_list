import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Подробности заклинания: шапка с названием и метками, параметры плитками, описание с сайта. С [canSpendSlot] —
/// закреплённая снизу панель: выбор ячейки (с остатком) и «Использовать».
class SpellInfoDialog extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    required Spell spell,
    bool canSpendSlot = true,
    bool canChangeSlot = true,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        final child = Dialog(
          backgroundColor: context.customColors?.cardColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SpellInfoDialog(spell: spell, canChangeSlot: canChangeSlot, canSpendSlot: canSpendSlot),
        );
        return canSpendSlot ? BlocProvider.value(value: context.read<PlayerCubit>(), child: child) : child;
      },
    );
  }

  final Spell spell;
  final bool canSpendSlot;
  final bool canChangeSlot;

  const SpellInfoDialog({super.key, required this.spell, required this.canSpendSlot, this.canChangeSlot = true});

  @override
  State<SpellInfoDialog> createState() => _SpellInfoDialogState();
}

class _SpellInfoDialogState extends State<SpellInfoDialog> {
  late SpellSlot _slot = widget.spell.slot;

  Spell get spell => widget.spell;

  bool get _canSpend => widget.canSpendSlot && spell.slot != SpellSlot.conspiracy;

  /// Заговор с концентрацией ячейку не тратит, но концентрацию отметить можно.
  bool get _canConcentrate => widget.canSpendSlot && spell.isConcentration;

  @override
  Widget build(BuildContext context) {
    final details = spell.details;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(spell: spell),
                const Gap(12),
                if (details != null)
                  _SpellDetailsView(spell: spell, details: details)
                else
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Описание не загружено с ttg.club. Обновите список заклинаний.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_canSpend || _canConcentrate)
          // Панель не прокручивается вместе с описанием: использовать заклинание можно, не листая до конца.
          DecoratedBox(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white24))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<PlayerCubit, Player>(
                builder: (context, player) => _canSpend
                    ? _SlotPanel(
                        player: player,
                        spell: spell,
                        slot: _slot,
                        // Расовое заклинание накладывается только своим уровнем.
                        onSelected: widget.canChangeSlot ? (slot) => setState(() => _slot = slot) : null,
                      )
                    : _ConcentrationPanel(player: player, spell: spell),
              ),
            ),
          ),
      ],
    );
  }
}

/// Название, английское название, уровень и школа, метки концентрации и ритуала; крестик — закрыть.
class _Header extends StatelessWidget {
  final Spell spell;

  const _Header({required this.spell});

  @override
  Widget build(BuildContext context) {
    final levelAndSchool = spell.details?.levelAndSchool ??
        (spell.slot == SpellSlot.conspiracy
            ? 'Заговор, ${spell.school}'
            : '${spell.slot.localizedName}, ${spell.school}');
    return SheetHeader(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spell.name, style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                if (spell.nameEn.isNotEmpty)
                  Text(spell.nameEn, style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                const Gap(8),
                Text(levelAndSchool, style: const TextStyle(fontStyle: FontStyle.italic)),
                if (spell.isConcentration || spell.isRitual) ...[
                  const Gap(8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (spell.isConcentration) const SheetBadge('Концентрация'),
                      if (spell.isRitual) const SheetBadge('Ритуал'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Закрыть',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _SpellDetailsView extends StatelessWidget {
  final Spell spell;
  final SpellDetails details;

  const _SpellDetailsView({required this.spell, required this.details});

  /// Материалы из строки компонентов сайта: «В, С, М (щепотка серы)» → «щепотка серы».
  String? get _materials {
    final start = details.components.indexOf('(');
    final end = details.components.lastIndexOf(')');
    if (start < 0 || end <= start) return null;
    return details.components.substring(start + 1, end).trim();
  }

  @override
  Widget build(BuildContext context) {
    final letters = spell.components.map((e) => e.localizedName).join(', ');
    final materials = _materials;
    final footer = {'Классы': details.classes, 'Подклассы': details.subclasses, 'Источник': details.source};
    final small = context.theme.textTheme.bodySmall?.copyWith(color: Colors.white60);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TileGrid(
          columns: 2,
          children: [
            InfoTile(label: 'Время накладывания', value: details.castTime),
            InfoTile(label: 'Дистанция', value: details.distance),
            InfoTile(label: 'Компоненты', value: letters.isEmpty ? details.components : letters),
            InfoTile(label: 'Длительность', value: details.duration),
          ],
        ),
        if (materials != null && materials.isNotEmpty) ...[
          const Gap(8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Материалы: ', style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: materials),
              ],
            ),
            style: small,
          ),
        ],
        const Gap(16),
        const SheetSectionTitle(icon: Icons.menu_book_outlined, title: 'Описание'),
        const Gap(8),
        HtmlContent(
          details.descriptionHtml,
          canOpenLink: (href) => href.startsWith('/spells/'),
          onLinkTap: (href) => _openSpell(context, href),
        ),
        const Gap(16),
        for (final entry in footer.entries)
          if (entry.value case final value? when value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: value),
                  ],
                ),
                style: small,
              ),
            ),
      ],
    );
  }

  /// Ссылка ведёт на другое заклинание: загружаем его целиком и открываем готовую модель.
  Future<void> _openSpell(BuildContext context, String link) async {
    final repository = getIt<SpellsRepository>();
    final spell = await repository.findByLink(link);
    if (spell == null) return;
    final loaded = (await repository.withDetailsIfPossible([spell])).first;
    if (!context.mounted) return;
    await SpellInfoDialog.show(context, spell: loaded, canSpendSlot: false);
  }
}

/// Предупреждение: концентрация на другом заклинании прервётся.
class _ConcentrationWarning extends StatelessWidget {
  final Player player;
  final Spell spell;

  const _ConcentrationWarning({required this.player, required this.spell});

  @override
  Widget build(BuildContext context) {
    final current = player.concentration;
    if (!spell.isConcentration || current == null || current == spell.name) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Концентрация на «$current» прервётся',
        textAlign: TextAlign.center,
        style: context.theme.textTheme.bodySmall?.copyWith(color: context.theme.colorScheme.error),
      ),
    );
  }
}

/// Заговор с концентрацией: отметить концентрацию или прервать её.
class _ConcentrationPanel extends StatelessWidget {
  final Player player;
  final Spell spell;

  const _ConcentrationPanel({required this.player, required this.spell});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final isCurrent = player.concentration == spell.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConcentrationWarning(player: player, spell: spell),
        isCurrent
            ? OutlinedButton(onPressed: cubit.endConcentration, child: const Text('Прервать концентрацию'))
            : FilledButton(onPressed: () => cubit.concentrate(spell.name), child: const Text('Концентрироваться')),
      ],
    );
  }
}

/// Выбор ячейки — плитки уровней не ниже уровня заклинания с остатком — и «Использовать». Заклинание
/// с концентрацией заодно отмечает её.
class _SlotPanel extends StatelessWidget {
  final Player player;
  final Spell spell;
  final SpellSlot slot;

  /// `null` — уровень ячейки не меняется (расовое заклинание).
  final ValueChanged<SpellSlot>? onSelected;

  const _SlotPanel({required this.player, required this.spell, required this.slot, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final minSlot = spell.slot;
    final levels = onSelected == null ? [slot] : player.spellSlotLevels.where((e) => e.index >= minSlot.index).toList();
    final left = player.currentSpellSlots[slot] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Остаток виден всегда; выбрать можно, если подходит больше одного уровня.
        Text('Ячейка', style: context.theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
        const Gap(6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final level in levels) ...[
                if (level != levels.first) const Gap(6),
                _SlotChoice(
                  slot: level,
                  left: player.currentSpellSlots[level] ?? 0,
                  isSelected: level == slot,
                  onTap: levels.length > 1 ? () => onSelected!(level) : null,
                ),
              ],
            ],
          ),
        ),
        const Gap(10),
        _ConcentrationWarning(player: player, spell: spell),
        FilledButton(
          onPressed: left > 0
              ? () {
                  final cubit = context.read<PlayerCubit>()..spendSpellSlot(slot);
                  if (spell.isConcentration) cubit.concentrate(spell.name);
                }
              : null,
          child: Text(left > 0 ? 'Использовать' : 'Нет ячеек ${slot.level} уровня'),
        ),
      ],
    );
  }
}

class _SlotChoice extends StatelessWidget {
  final SpellSlot slot;
  final int left;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SlotChoice({required this.slot, required this.left, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    return SizedBox(
      width: 64,
      child: SheetTile(
        onTap: onTap,
        color: isSelected ? primary.withValues(alpha: 0.15) : null,
        borderColor: isSelected ? primary : Colors.white24,
        child: Column(
          children: [
            Text('${slot.level} ур.', style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
            Text(
              '$left',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: left == 0 ? Colors.white38 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
