import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SpellInfoDialog extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    required Spell spell,
    bool canDrainMana = true,
    bool canChangeSlot = true,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        final child = Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: SpellInfoDialog(
            spell: spell,
            canChangeSlot: canChangeSlot,
            canDrainMana: canDrainMana,
          ),
        );
        return canDrainMana
            ? BlocProvider.value(
                value: context.read<PlayerCubit>(),
                child: child,
              )
            : child;
      },
    );
  }

  final Spell spell;
  final bool canDrainMana;
  final bool canChangeSlot;

  const SpellInfoDialog({
    super.key,
    required this.spell,
    required this.canDrainMana,
    this.canChangeSlot = true,
  });

  @override
  State<SpellInfoDialog> createState() => _SpellInfoDialogState();
}

class _SpellInfoDialogState extends State<SpellInfoDialog> {
  late SpellSlot _slot = widget.spell.slot;

  Spell get spell => widget.spell;

  @override
  Widget build(BuildContext context) {
    final availableSlots = widget.canDrainMana
        ? context
            .read<PlayerCubit>()
            .state
            .spellCells
            .entries
            .where(
              (e) => e.key.index >= spell.slot.index && e.value > 0,
            )
            .map((e) => e.key)
            .toList()
        : <SpellSlot>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spell.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            spell.nameEn,
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodySmall,
          ),
          if (widget.canDrainMana && spell.slot != SpellSlot.conspiracy) Text('${_slot.mana} маны'),
          if (availableSlots.length > 1 && widget.canChangeSlot) ...[
            const Gap(8),
            const Text('Ячейка'),
            const Gap(8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableSlots
                  .map((e) => GestureDetector(
                        onTap: () => setState(() {
                          _slot = e;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: e == _slot ? Colors.white : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            '${e.level}',
                            style: TextStyle(
                              color: e == _slot ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (spell.details != null)
                    _SpellDetailsView(details: spell.details!)
                  else
                    const Text(
                      'Описание не загружено с ttg.club. Обновите список заклинаний.',
                      textAlign: TextAlign.center,
                    ),
                  if (widget.canDrainMana && spell.slot != SpellSlot.conspiracy) ...[
                    const Gap(16),
                    BlocBuilder<PlayerCubit, Player>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.currentMana >= _slot.mana
                            ? () => context.read<PlayerCubit>().spendMana(_slot.mana)
                            : null,
                        child: const Text('Использовать'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SpellDetailsView extends StatelessWidget {
  final SpellDetails details;

  const _SpellDetailsView({required this.details});

  @override
  Widget build(BuildContext context) {
    final params = {
      'Время накладывания': details.castTime,
      'Дистанция': details.distance,
      'Компоненты': details.components,
      'Длительность': details.duration,
      'Классы': details.classes,
      'Подклассы': details.subclasses,
      'Источник': details.source,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          details.levelAndSchool,
          textAlign: TextAlign.center,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const Gap(8),
        for (final param in params.entries)
          if (param.value != null && param.value!.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${param.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: param.value),
                ],
              ),
            ),
        const Divider(height: 24),
        HtmlContent(
          details.descriptionHtml,
          canOpenLink: (href) => href.startsWith('/spells/'),
          onLinkTap: (href) => _openSpell(context, href),
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
    await SpellInfoDialog.show(context, spell: loaded, canDrainMana: false);
  }
}
