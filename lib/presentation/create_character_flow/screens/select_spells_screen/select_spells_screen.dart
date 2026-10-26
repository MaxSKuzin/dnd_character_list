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
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_widget.dart';
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
            (e) =>
                widget.availableSlots.contains(e.slot) &&
                _isClassSpell(e) &&
                !widget.knownSpells.contains(e),
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
        (e) =>
            (_selectedSpellSlot == null || e.slot == _selectedSpellSlot) &&
            e.matchesQuery(_query),
      )
      .toList();

  /// Расширенные списки TCE при создании и развитии персонажа включены всегда.
  bool _isClassSpell(Spell spell) =>
      widget.classKind == null ||
      [widget.classKind!, ...?widget.additionalClassKinds].any(spell.isAvailableFor);

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

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedSpells.length == widget.maxSpells &&
        _selectedConspiracies.length == widget.maxConspiracies &&
        !_isSaving;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.description != null) ...[
                const Gap(8),
                Text(widget.description!, textAlign: TextAlign.center),
              ],
              const Gap(16),
              if (widget.maxConspiracies > 0)
                Text(
                  'Заговоры: ${_selectedConspiracies.length}/${widget.maxConspiracies}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (widget.maxSpells > 0)
                Text(
                  'Заклинания: ${_selectedSpells.length}/${widget.maxSpells}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              const Gap(16),
              SpellSearchField(onChanged: (value) => setState(() => _query = value)),
              const Gap(8),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...widget.availableSlots.map(
                      (e) => GestureDetector(
                        onTap: () => setState(() {
                          if (e != _selectedSpellSlot) {
                            _selectedSpellSlot = e;
                          } else {
                            _selectedSpellSlot = null;
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(
                              e.localizedName,
                              style: TextStyle(
                                color: _selectedSpellSlot == e ? context.theme.scaffoldBackgroundColor : null,
                              ),
                            ),
                            color: WidgetStatePropertyAll(
                              _selectedSpellSlot == e ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              if (_isLoadingDetails && _spells != null) ...[
                Text(
                  'Загрузка описаний с ttg.club: $_loadedDetailsCount/${_spells!.length}',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall,
                ),
                const Gap(4),
                LinearProgressIndicator(value: _loadedDetailsCount / _spells!.length),
                const Gap(8),
              ],
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_error != null) {
                      return LoadingError(
                        message: 'Не удалось загрузить заклинания с ttg.club.',
                        error: _error!,
                        onRetry: () => _load(forceRefresh: true),
                      );
                    }
                    if (_spells == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
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
                          : ListView.builder(
                              itemCount: visibleSpells.length,
                              itemBuilder: (context, index) {
                                final spell = visibleSpells[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Stack(
                                    children: [
                                      SpellWidget(
                                        onTap: () => _toggle(spell),
                                        backgroundColor:
                                            _selectedSpells.contains(spell) || _selectedConspiracies.contains(spell)
                                                ? null
                                                : Colors.transparent,
                                        spell: spell,
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: _InfoButton(
                                          spell: spell,
                                          isLoading: _isLoadingDetails,
                                          onRetry: () => _retryDetails(spell),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: canContinue ? _onContinue : null,
                child: _isSaving
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Далее'),
              ),
            ],
          ),
        ),
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
        icon: const Icon(Icons.info),
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
