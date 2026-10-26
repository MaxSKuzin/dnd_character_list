import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// «Увеличение характеристик»: +2 к характеристикам (максимум 20) или черта из «Книги игрока».
@RoutePage()
class AbilityScoreImprovementScreen extends StatefulWidget {
  final Player player;
  final int level;
  final void Function(AbilityScoreImprovement improvement) onSelected;

  const AbilityScoreImprovementScreen({
    super.key,
    required this.player,
    required this.level,
    required this.onSelected,
  });

  @override
  State<AbilityScoreImprovementScreen> createState() => _AbilityScoreImprovementScreenState();
}

class _AbilityScoreImprovementScreenState extends State<AbilityScoreImprovementScreen> {
  static const _points = 2;
  static const _maxStat = 20;

  /// Классы, из списков которых «Посвящённый в магию» берёт заклинания.
  static const _magicInitiateClasses = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  final _repository = getIt<RulesRepository>();
  late Future<List<Feat>> _feats = _repository.getFeats();

  bool _takeFeat = false;
  final _stats = <StatKind, int>{};

  Feat? _feat;
  StatKind? _increasedStat;
  final _skills = <Skill>[];
  final _languages = <Language>[];
  final _weapons = <Weapon>[];

  /// Оружие для «Мастера оружия» загружается, только когда черта выбрана.
  late Future<EquipmentCatalog> _equipment = _repository.getEquipment();
  ClassKind? _spellsClass;
  List<Spell> _spells = [];

  Player get _player => widget.player;

  int get _spentPoints => _stats.values.fold(0, (sum, e) => sum + e);

  void _selectFeat(Feat feat) => setState(() {
        _feat = feat == _feat ? null : feat;
        _increasedStat = _feat?.statIncreaseOptions.length == 1 ? _feat!.statIncreaseOptions.first : null;
        _skills.clear();
        _languages.clear();
        _weapons.clear();
        _spellsClass = null;
        _spells = [];
      });

  bool get _isFeatComplete {
    final feat = _feat;
    if (feat == null) return false;
    return (feat.statIncreaseOptions.isEmpty || _increasedStat != null) &&
        _skills.length == feat.skillChoices &&
        _languages.length == feat.languageChoices &&
        _weapons.length == feat.weaponChoices &&
        (!feat.grantsMagicInitiate || _spells.length == 3);
  }

  void _done() => widget.onSelected(
        _takeFeat
            ? AbilityScoreImprovement(
                level: widget.level,
                feat: ChosenFeat(
                  feat: _feat!,
                  increasedStat: _increasedStat,
                  skills: [..._skills],
                  languages: [..._languages],
                  weapons: _weapons.map((e) => e.proficiencyKey).toList(),
                  spellsClass: _spellsClass,
                  spells: _spells,
                ),
              )
            : AbilityScoreImprovement(level: widget.level, stats: Map.of(_stats)..removeWhere((_, v) => v == 0)),
      );

  Future<void> _chooseMagicInitiateSpells(ClassKind classKind) async {
    final spells = await context.pushRoute<List<Spell>>(
      SelectSpellsRoute(
        title: 'Посвящённый в магию: ${classKind.localizedName}',
        classKind: classKind,
        maxConspiracies: 2,
        maxSpells: 1,
        availableSlots: const [SpellSlot.conspiracy, SpellSlot.level1],
        knownSpells: _player.spells.values.expand((e) => e).toList(),
        onSpellsSelected: (spells) => context.maybePop(spells),
      ),
    );
    if (spells == null || !mounted) return;
    setState(() {
      _spellsClass = classKind;
      _spells = spells;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _takeFeat ? _isFeatComplete : _spentPoints == _points;
    return StepScaffold(
      title: 'Увеличение характеристик',
      description: _takeFeat
          ? 'Вместо увеличения характеристик можно взять черту из «Книги игрока».'
          : 'Повысьте одну характеристику на 2 или две на 1. Значение не может превысить $_maxStat.',
      counter: _takeFeat ? null : 'Осталось ${_points - _spentPoints} из $_points',
      isCounterDone: _spentPoints == _points,
      headerBottom: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Характеристики')),
          ButtonSegment(value: true, label: Text('Черта')),
        ],
        selected: {_takeFeat},
        onSelectionChanged: (value) => setState(() => _takeFeat = value.first),
      ),
      onAction: isComplete ? _done : null,
      body: _takeFeat ? _buildFeats() : _buildStats(),
    );
  }

  Widget _buildStats() {
    final valueStyle = context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        SheetCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TileGrid(
              columns: 2,
              children: [
                for (final stat in StatKind.values)
                  Builder(
                    builder: (context) {
                      final current = _player.stats[stat]!.value;
                      final added = _stats[stat] ?? 0;
                      return InfoTile(
                        label: stat.localizedName,
                        value: '${current + added}',
                        caption: added > 0 ? 'было $current, +$added' : 'сейчас',
                        valueStyle:
                            added > 0 ? valueStyle?.copyWith(color: context.theme.colorScheme.primary) : valueStyle,
                        decreaseTooltip: '${stat.localizedName}: меньше',
                        increaseTooltip: '${stat.localizedName}: больше',
                        onDecrease: added > 0 ? () => setState(() => _stats[stat] = added - 1) : null,
                        onIncrease: _spentPoints < _points && current + added < _maxStat
                            ? () => setState(() => _stats[stat] = added + 1)
                            : null,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeats() => FutureBuilder(
        future: _feats,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadingError(
              message: 'Не удалось загрузить черты с ttg.club.',
              error: snapshot.error!,
              onRetry: () => setState(() => _feats = _repository.getFeats()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final taken = _player.feats.map((e) => e.feat).toSet();
          final feats = [...snapshot.data!]..sort((a, b) => a.name.compareTo(b.name));
          return ChoiceList(
            children: [
              for (final feat in feats)
                Builder(
                  builder: (context) {
                    final unmet = taken.contains(feat) ? 'Уже взята' : feat.requirement.unmetReason(_player);
                    final isSelected = feat == _feat;
                    return ChoiceCard(
                      title: feat.name,
                      subtitle: feat.requirementText == null ? null : 'Требование: ${feat.requirementText}',
                      unavailableReason: unmet,
                      isSelected: isSelected,
                      onTap: unmet == null ? () => _selectFeat(feat) : null,
                      // Описание и выборы черты — только у выбранной, чтобы список оставался коротким.
                      child: isSelected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                HtmlContent(feat.descriptionHtml),
                                const Gap(8),
                                _buildFeatChoices(feat),
                              ],
                            )
                          : null,
                    );
                  },
                ),
            ],
          );
        },
      );

  Widget _buildFeatChoices(Feat feat) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (feat.statIncreaseOptions.length > 1) ...[
            Text(feat.grantsSavingThrow ? 'Характеристика (+1 и владение спасброском)' : 'Характеристика +1'),
            Wrap(
              spacing: 8,
              children: feat.statIncreaseOptions
                  .map(
                    (stat) => ChoiceChip(
                      label: Text(stat.localizedName),
                      selected: _increasedStat == stat,
                      onSelected:
                          _player.stats[stat]!.value < _maxStat ? (_) => setState(() => _increasedStat = stat) : null,
                    ),
                  )
                  .toList(),
            ),
            const Gap(8),
          ],
          if (feat.skillChoices > 0) ...[
            Text('Навыки: ${_skills.length}/${feat.skillChoices}'),
            Wrap(
              spacing: 8,
              children: Skill.values
                  .where((e) => !_player.chosenSkills.contains(e))
                  .map((skill) => FilterChip(
                        label: Text(skill.localizedName),
                        selected: _skills.contains(skill),
                        onSelected: (_) => setState(() => _toggle(_skills, skill, feat.skillChoices)),
                      ))
                  .toList(),
            ),
            const Gap(8),
          ],
          if (feat.languageChoices > 0) ...[
            Text('Языки: ${_languages.length}/${feat.languageChoices}'),
            Wrap(
              spacing: 8,
              children: Language.values
                  .where((e) => !_player.knownLanguages.contains(e))
                  .map((language) => FilterChip(
                        label: Text(language.localizedName),
                        selected: _languages.contains(language),
                        onSelected: (_) => setState(() => _toggle(_languages, language, feat.languageChoices)),
                      ))
                  .toList(),
            ),
            const Gap(8),
          ],
          if (feat.weaponChoices > 0) ...[
            Text('Владение оружием: ${_weapons.length}/${feat.weaponChoices}'),
            FutureBuilder(
              future: _equipment,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return LoadingError(
                    message: 'Не удалось загрузить оружие с ttg.club.',
                    error: snapshot.error!,
                    onRetry: () => setState(() => _equipment = _repository.getEquipment()),
                  );
                }
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return Wrap(
                  spacing: 8,
                  children: snapshot.data!.weapons
                      .where((e) => !_player.isProficientWith(e))
                      .map((weapon) => FilterChip(
                            label: Text(weapon.name),
                            selected: _weapons.contains(weapon),
                            onSelected: (_) => setState(() => _toggle(_weapons, weapon, feat.weaponChoices)),
                          ))
                      .toList(),
                );
              },
            ),
            const Gap(8),
          ],
          if (feat.grantsMagicInitiate) ...[
            const Text('Класс, из списка которого берутся заклинания'),
            Wrap(
              spacing: 8,
              children: _magicInitiateClasses
                  .map((classKind) => ChoiceChip(
                        label: Text(classKind.localizedName),
                        selected: _spellsClass == classKind,
                        onSelected: (_) => _chooseMagicInitiateSpells(classKind),
                      ))
                  .toList(),
            ),
            if (_spells.isNotEmpty) Text('Заклинания: ${_spells.map((e) => e.name).join(', ')}'),
          ],
        ],
      );

  void _toggle<T>(List<T> selected, T value, int max) {
    if (selected.contains(value)) {
      selected.remove(value);
    } else if (selected.length < max) {
      selected.add(value);
    }
  }
}
