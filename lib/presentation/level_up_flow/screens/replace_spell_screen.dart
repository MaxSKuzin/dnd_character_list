import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_search_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Замена одного известного заклинания другим из списка класса. Шаг необязательный:
/// «Пропустить» передаёт `null`.
@RoutePage()
class ReplaceSpellScreen extends StatefulWidget {
  final String title;
  final String description;

  /// Заклинания, которые можно заменить.
  final List<Spell> replaceableSpells;

  /// Класс, из списка которого берётся новое заклинание.
  final ClassKind classKind;

  /// Дополнительные списки, например список жреца у «Божественной души».
  final List<ClassKind> additionalClassKinds;

  /// Уровни нового заклинания; заговор меняется только на заговор (это задаёт вызывающий код).
  final List<SpellSlot> newSpellSlots;

  /// Заклинания, которые персонаж уже знает или выучил на этом уровне: их нельзя выбрать как новые.
  final List<Spell> knownSpells;

  final void Function(SpellReplacement? replacement) onSelected;

  const ReplaceSpellScreen({
    super.key,
    required this.title,
    required this.description,
    required this.replaceableSpells,
    required this.classKind,
    this.additionalClassKinds = const [],
    required this.newSpellSlots,
    required this.knownSpells,
    required this.onSelected,
  });

  @override
  State<ReplaceSpellScreen> createState() => _ReplaceSpellScreenState();
}

class _ReplaceSpellScreenState extends State<ReplaceSpellScreen> {
  final _repository = getIt<SpellsRepository>();

  Spell? _replaced;
  Spell? _learned;
  bool _isSaving = false;

  Future<void> _chooseReplaced() async {
    final spell = await _SpellPickerDialog.show(
      context,
      title: 'Заклинание на замену',
      load: () async => widget.replaceableSpells,
      selected: _replaced,
    );
    if (spell == null || !mounted) return;
    setState(() {
      _replaced = spell;
      // Заговор меняется на заговор, заклинание — на заклинание.
      if (_learned != null && (_learned!.slot == SpellSlot.conspiracy) != (spell.slot == SpellSlot.conspiracy)) {
        _learned = null;
      }
    });
  }

  List<SpellSlot> get _newSlots => _replaced?.slot == SpellSlot.conspiracy
      ? [SpellSlot.conspiracy]
      : widget.newSpellSlots.where((e) => e != SpellSlot.conspiracy).toList();

  Future<void> _chooseLearned() async {
    final slots = _newSlots;
    final spell = await _SpellPickerDialog.show(
      context,
      title: 'Новое заклинание',
      selected: _learned,
      load: () async => (await _repository.getSpells())
          .where(
            (e) =>
                [widget.classKind, ...widget.additionalClassKinds].any(e.isAvailableFor) &&
                slots.contains(e.slot) &&
                !widget.knownSpells.contains(e),
          )
          .sorted((a, b) => a.slot != b.slot ? a.slot.compareTo(b.slot) : a.name.compareTo(b.name)),
    );
    if (spell == null || !mounted) return;
    setState(() => _learned = spell);
  }

  /// Новое заклинание сохраняется с описанием, чтобы лист персонажа работал без сети.
  Future<void> _onReplace() async {
    setState(() => _isSaving = true);
    final learned = (await _repository.withDetailsIfPossible([_learned!])).first;
    if (!mounted) return;
    setState(() => _isSaving = false);
    widget.onSelected(SpellReplacement(replaced: _replaced!, learned: learned));
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      actionLabel: 'Заменить',
      isBusy: _isSaving,
      onAction: _replaced != null && _learned != null ? _onReplace : null,
      onSkip: () => widget.onSelected(null),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SpellCard(
            label: 'Заклинание на замену',
            spell: _replaced,
            placeholder: 'Выберите известное заклинание',
            onTap: _chooseReplaced,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(Icons.arrow_downward, color: Colors.white54),
          ),
          _SpellCard(
            label: 'Новое заклинание',
            spell: _learned,
            placeholder: _replaced == null
                ? 'Сначала выберите заклинание на замену'
                : _replaced!.slot == SpellSlot.conspiracy
                    ? 'Выберите заговор'
                    : 'Выберите заклинание до ${_newSlots.last.index} уровня',
            onTap: _replaced == null ? null : _chooseLearned,
          ),
        ],
      ),
    );
  }
}

class _SpellCard extends StatelessWidget {
  final String label;
  final Spell? spell;
  final String placeholder;
  final VoidCallback? onTap;

  const _SpellCard({required this.label, required this.spell, required this.placeholder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final spell = this.spell;
    // Выбранное заклинание — цветом карточек с белой рамкой, как выбранные варианты на других шагах.
    return SheetCard(
      color: spell != null ? null : Colors.transparent,
      borderColor: spell != null ? Colors.white : (onTap == null ? Colors.white12 : Colors.white38),
      child: ListTile(
        enabled: onTap != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(label, style: context.theme.textTheme.labelMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: spell == null
              ? Text(placeholder)
              : Text(
                  '${spell.name}\n${spell.slot.localizedName}, ${spell.school}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Диалог выбора одного заклинания с поиском; «i» открывает описание.
class _SpellPickerDialog extends StatefulWidget {
  final String title;
  final Future<List<Spell>> Function() load;
  final Spell? selected;

  const _SpellPickerDialog({required this.title, required this.load, required this.selected});

  static Future<Spell?> show(
    BuildContext context, {
    required String title,
    required Future<List<Spell>> Function() load,
    required Spell? selected,
  }) =>
      showDialog<Spell>(
        context: context,
        builder: (_) => _SpellPickerDialog(title: title, load: load, selected: selected),
      );

  @override
  State<_SpellPickerDialog> createState() => _SpellPickerDialogState();
}

class _SpellPickerDialogState extends State<_SpellPickerDialog> {
  late Future<List<Spell>> _spells = widget.load();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.customColors?.cardColor,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            SpellSearchField(onChanged: (value) => setState(() => _query = value)),
            const Gap(8),
            Flexible(
              child: FutureBuilder<List<Spell>>(
                future: _spells,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return LoadingError(
                      message: 'Не удалось загрузить заклинания с ttg.club.',
                      error: snapshot.error!,
                      onRetry: () => setState(() => _spells = widget.load()),
                    );
                  }
                  final spells = snapshot.data?.where((e) => e.matchesQuery(_query)).toList();
                  if (spells == null) return const Center(child: CircularProgressIndicator());
                  if (spells.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Нет подходящих заклинаний', textAlign: TextAlign.center),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: spells.length,
                    itemBuilder: (context, index) {
                      final spell = spells[index];
                      return ListTile(
                        selected: spell == widget.selected,
                        title: Text(spell.name),
                        subtitle: Text('${spell.slot.localizedName}, ${spell.school}'),
                        trailing: IconButton(
                          tooltip: 'Описание',
                          icon: const Icon(Icons.info_outline, color: Colors.white70),
                          onPressed: () async {
                            final loaded = (await getIt<SpellsRepository>().withDetailsIfPossible([spell])).first;
                            if (!context.mounted) return;
                            await SpellInfoDialog.show(context, spell: loaded, canSpendSlot: false);
                          },
                        ),
                        onTap: () => Navigator.of(context).pop(spell),
                      );
                    },
                  );
                },
              ),
            ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          ],
        ),
      ),
    );
  }
}
