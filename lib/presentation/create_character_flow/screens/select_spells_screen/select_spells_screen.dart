import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_search_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectSpellsScreen extends StatefulWidget {
  /// Класс, из списка которого выбираются заклинания (с расширенным списком TCE).
  /// `null` — любой класс, как для «Тайн магии».
  final ClassKind? classKind;

  /// Списки других классов, из которых тоже можно выбирать, например жреца у «Божественной души».
  final List<ClassKind>? additionalClassKinds;
  final int maxConspiracies;
  final int maxSpells;
  final List<Spell> knownSpells;
  final void Function(List<Spell> spells) onSpellsSelected;
  final List<SpellSlot> availableSlots;
  final String title;
  final String? description;

  /// Заговоры входят в общий лимит [maxSpells] (как в «Тайнах магии»).
  final bool cantripsCountAsSpells;

  const SelectSpellsScreen({
    super.key,
    this.knownSpells = const [],
    List<SpellSlot>? availableSlots,
    this.title = 'Заклинания',
    this.description,
    this.additionalClassKinds,
    this.cantripsCountAsSpells = false,
    required this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  }) : availableSlots = availableSlots ?? const [SpellSlot.conspiracy, SpellSlot.level1];

  @override
  State<SelectSpellsScreen> createState() => _SelectSpellsScreenState();
}

class _SelectSpellsScreenState extends State<SelectSpellsScreen> {
  final _repository = getIt<SpellsRepository>();

  final _selectedConspiracies = <Spell>[];
  final _selectedSpells = <Spell>[];
  SpellSlot? _selectedSpellSlot;
  String _query = '';
  bool _isSaving = false;

  /// Заклинания, доступные классу, по мере загрузки дополняются полными данными.
  List<Spell>? _spells;
  Object? _error;
  StreamSubscription<Spell>? _detailsSubscription;
  int _loadedDetailsCount = 0;

  bool get _isLoadingDetails => _detailsSubscription != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _detailsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    await _detailsSubscription?.cancel();
    setState(() {
      _detailsSubscription = null;
      _error = null;
      if (forceRefresh) _spells = null;
    });
    try {
      final spells = (await _repository.getSpells(forceRefresh: forceRefresh))
          .where(
            (e) => widget.availableSlots.contains(e.slot) && _isClassSpell(e) && !widget.knownSpells.contains(e),
          )
          .sorted((a, b) => a.slot != b.slot ? a.slot.compareTo(b.slot) : a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        _spells = spells;
        _loadedDetailsCount = 0;
      });
      _loadDetails(spells);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  void _loadDetails(List<Spell> spells) {
    _detailsSubscription = _repository.loadDetails(spells).listen(
          (spell) => setState(() {
            _loadedDetailsCount++;
            _spells = _spells?.map((e) => e == spell ? spell : e).toList();
          }),
          onDone: () => setState(() => _detailsSubscription = null),
        );
  }

  Future<void> _retryDetails(Spell spell) async {
    final loaded = await _repository.withDetailsIfPossible([spell]);
    if (!mounted) return;
    setState(() {
      _spells = _spells?.map((e) => e == spell ? loaded.first : e).toList();
    });
  }

  List<Spell> _visibleSpells(List<Spell> spells) => spells
      .where(
        (e) => (_selectedSpellSlot == null || e.slot == _selectedSpellSlot) && e.matchesQuery(_query),
      )
      .toList();

  /// Расширенные списки TCE при создании и развитии персонажа включены всегда.
  bool _isClassSpell(Spell spell) =>
      widget.classKind == null || [widget.classKind!, ...?widget.additionalClassKinds].any(spell.isAvailableFor);

  void _toggle(Spell spell) {
    if (spell.slot != SpellSlot.conspiracy || widget.cantripsCountAsSpells) {
      if (_selectedSpells.contains(spell)) {
        _selectedSpells.remove(spell);
      } else if (_selectedSpells.length < widget.maxSpells) {
        _selectedSpells.add(spell);
      }
    } else {
      if (_selectedConspiracies.contains(spell)) {
        _selectedConspiracies.remove(spell);
      } else if (_selectedConspiracies.length < widget.maxConspiracies) {
        _selectedConspiracies.add(spell);
      }
    }
    setState(() {});
  }

  /// Сохраняем выбранные заклинания вместе с описаниями, чтобы лист персонажа работал без сети.
  Future<void> _onContinue() async {
    setState(() => _isSaving = true);
    final loaded = {for (final spell in _spells ?? <Spell>[]) spell.id: spell};
    final selected = await _repository.withDetailsIfPossible(
      [..._selectedSpells, ..._selectedConspiracies].map((e) => loaded[e.id] ?? e).toList(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    widget.onSpellsSelected(selected);
  }

  /// Заговоры отдельно от заклинаний, если у них свой лимит.
  bool _isCantrip(Spell spell) => spell.slot == SpellSlot.conspiracy && !widget.cantripsCountAsSpells;

  /// Лимит набран: невыбранные заклинания той же группы гаснут.
  bool _isFull(Spell spell) => _isCantrip(spell)
      ? _selectedConspiracies.length >= widget.maxConspiracies
      : _selectedSpells.length >= widget.maxSpells;

  @override
  Widget build(BuildContext context) {
    final canContinue =
        _selectedSpells.length == widget.maxSpells && _selectedConspiracies.length == widget.maxConspiracies;
    final primary = context.theme.colorScheme.primary;
    SheetBadge counter(String label, int selected, int max) =>
        SheetBadge('$label: $selected из $max', color: selected == max ? primary : null);
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      isBusy: _isSaving,
      onAction: canContinue ? _onContinue : null,
      headerBottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.maxConspiracies > 0) counter('Заговоры', _selectedConspiracies.length, widget.maxConspiracies),
              if (widget.maxSpells > 0) counter('Заклинания', _selectedSpells.length, widget.maxSpells),
            ],
          ),
          const Gap(8),
          SpellSearchField(onChanged: (value) => setState(() => _query = value)),
          if (widget.availableSlots.length > 1) ...[
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final slot in widget.availableSlots)
                  ChoiceChip(
                    label: Text(slot.localizedName),
                    selected: _selectedSpellSlot == slot,
                    onSelected: (_) => setState(() => _selectedSpellSlot = _selectedSpellSlot == slot ? null : slot),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoadingDetails && _spells != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Загрузка описаний с ttg.club: $_loadedDetailsCount/${_spells!.length}',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodySmall,
                  ),
                  const Gap(4),
                  LinearProgressIndicator(value: _loadedDetailsCount / _spells!.length),
                ],
              ),
            ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_error != null) {
      return LoadingError(
        message: 'Не удалось загрузить заклинания с ttg.club.',
        error: _error!,
        onRetry: () => _load(forceRefresh: true),
      );
    }
    if (_spells == null) return const Center(child: CircularProgressIndicator());
    final visibleSpells = _visibleSpells(_spells!);
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: visibleSpells.isEmpty
          ? ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ничего не найдено', textAlign: TextAlign.center),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: visibleSpells.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
                final spell = visibleSpells[index];
                final details = spell.details;
                final isSelected = _selectedSpells.contains(spell) || _selectedConspiracies.contains(spell);
                return ChoiceCard(
                  title: spell.name,
                  subtitle: [
                    [
                      '${spell.slot.localizedName}, ${spell.school.toLowerCase()}',
                      if (spell.isConcentration) 'концентрация',
                      if (spell.isRitual) 'ритуал',
                    ].join(' · '),
                    if (details != null)
                      [
                        details.castTime,
                        details.distance,
                        spell.components.map((e) => e.localizedName).join(', '),
                      ].join(' · '),
                  ].join('\n'),
                  isSelected: isSelected,
                  isMultiple: true,
                  onTap: isSelected || !_isFull(spell) ? () => _toggle(spell) : null,
                  trailing:
                      _InfoButton(spell: spell, isLoading: _isLoadingDetails, onRetry: () => _retryDetails(spell)),
                );
              },
            ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final Spell spell;
  final bool isLoading;
  final VoidCallback onRetry;

  const _InfoButton({
    required this.spell,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (spell.details != null) {
      return IconButton(
        onPressed: () => SpellInfoDialog.show(
          context,
          canSpendSlot: false,
          spell: spell,
        ),
        icon: const Icon(Icons.info_outline, color: Colors.white70),
      );
    }
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      tooltip: 'Не удалось загрузить описание. Повторить',
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
    );
  }
}
