import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_search_field.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_tile.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SpellsScreen extends StatefulWidget {
  const SpellsScreen({super.key});

  @override
  State<SpellsScreen> createState() => _SpellsScreenState();
}

/// Заклинание на экране: расовые показываются отдельной меткой, их ячейку не меняют.
typedef _ShownSpell = ({Spell spell, bool isRacial});

class _SpellsScreenState extends State<SpellsScreen> {
  final _source = getIt<SpSource>();
  SpellSlot? selectedSlot;
  ClassKind? selectedClass;
  String query = '';

  /// Сетка или список; выбор запоминается на устройстве.
  late bool _isGrid = _source.isSpellsGrid;

  void _toggleView() {
    setState(() => _isGrid = !_isGrid);
    _source.setSpellsGrid(_isGrid);
  }

  void _showSpell(_ShownSpell e) => SpellInfoDialog.show(context, spell: e.spell, canChangeSlot: !e.isRacial);

  @override
  Widget build(BuildContext context) {
    final spells = PlayerModel.spells(context);
    final availableSpells = spells.entries
        .expand(
          (e) => e.value.map(
            (el) => MapEntry(e.key, el),
          ),
        )
        .where(
          (e) =>
              (selectedSlot != null ? e.value.slot == selectedSlot : true) &&
              (selectedClass != null ? e.key.classKind == selectedClass : true) &&
              e.value.matchesQuery(query),
        )
        .sorted(
          (a, b) => a.value.slot.compareTo(b.value.slot),
        );
    final raceSpells = PlayerModel.raceSpells(context)
        .entries
        .where(
          (e) => (selectedSlot != null ? e.value.slot == selectedSlot : true) && e.value.matchesQuery(query),
        )
        .sorted(
          (a, b) => a.value.slot.compareTo(b.value.slot),
        );
    // Расовые заклинания — первыми, как и раньше.
    final shown = <_ShownSpell>[
      for (final e in raceSpells) (spell: e.value, isRacial: true),
      for (final e in availableSpells) (spell: e.value, isRacial: false),
    ];
    return SafeArea(
      child: Column(
        children: [
          // Поиск, вид и фильтры — в шапке экрана; списки фильтров прокручиваются вбок.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SheetHeader(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: SpellSearchField(onChanged: (value) => setState(() => query = value))),
                      IconButton(
                        tooltip: _isGrid ? 'Показать списком' : 'Показать сеткой',
                        onPressed: _toggleView,
                        icon: Icon(_isGrid ? Icons.view_agenda_outlined : Icons.grid_view),
                      ),
                    ],
                  ),
                  if (spells.keys.length > 1)
                    _Filters(
                      children: [
                        for (final spec in spells.keys)
                          ChoiceChip(
                            label: Text(spec.name),
                            selected: selectedClass == spec.classKind,
                            onSelected: (_) => setState(
                              () => selectedClass = selectedClass == spec.classKind ? null : spec.classKind,
                            ),
                          ),
                      ],
                    ),
                  _Filters(
                    children: [
                      for (final slot in SpellSlot.values)
                        ChoiceChip(
                          label: Text(slot.localizedName),
                          selected: selectedSlot == slot,
                          onSelected: (_) => setState(() => selectedSlot = selectedSlot == slot ? null : slot),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          Expanded(child: _isGrid ? _grid(shown) : _list(shown)),
        ],
      ),
    );
  }

  Widget _list(List<_ShownSpell> shown) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: shown.length,
        separatorBuilder: (context, index) => const Gap(16),
        itemBuilder: (context, index) {
          final e = shown[index];
          final widget = SpellWidget(onTap: () => _showSpell(e), spell: e.spell);
          if (!e.isRacial) return widget;
          return Stack(
            children: [
              widget,
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Chip(label: Text('Расовое', style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          );
        },
      );

  /// Сетка по уровням: «Заговоры», «1 уровень»… Внутри уровня — по названию.
  Widget _grid(List<_ShownSpell> shown) {
    final bySlot =
        groupBy(shown, (e) => e.spell.slot).map((slot, spells) => MapEntry(slot, spells.sortedBy((e) => e.spell.name)));
    final slots = bySlot.keys.sorted((a, b) => a.compareTo(b));
    return CustomScrollView(
      slivers: [
        for (final slot in slots) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: SheetSectionTitle(
                icon: slot == SpellSlot.conspiracy ? Icons.flare_outlined : Icons.local_fire_department_outlined,
                title: slot == SpellSlot.conspiracy ? 'Заговоры' : slot.localizedName,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: SpellTile.height,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: bySlot[slot]!.length,
              itemBuilder: (context, index) {
                final e = bySlot[slot]![index];
                return SpellTile(spell: e.spell, isRacial: e.isRacial, onTap: () => _showSpell(e));
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: Gap(16)),
      ],
    );
  }
}

/// Ряд фильтров-переключателей с прокруткой вбок.
class _Filters extends StatelessWidget {
  final List<Widget> children;

  const _Filters({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (_, index) => Center(child: children[index]),
      ),
    );
  }
}
