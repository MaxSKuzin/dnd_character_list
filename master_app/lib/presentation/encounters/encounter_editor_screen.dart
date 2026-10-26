import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_master/presentation/monsters/monster_picker.dart';
import 'package:dnd_master/presentation/monsters/monster_stat_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Подготовка боевой ситуации: название, заметки, монстры и их количество.
class EncounterEditorScreen extends StatefulWidget {
  /// `null` — новая ситуация.
  final Encounter? encounter;

  const EncounterEditorScreen({super.key, this.encounter});

  static Future<void> open(BuildContext context, [Encounter? encounter]) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EncounterEditorScreen(encounter: encounter)));

  @override
  State<EncounterEditorScreen> createState() => _EncounterEditorScreenState();
}

class _EncounterEditorScreenState extends State<EncounterEditorScreen> {
  late final _nameController = TextEditingController(text: widget.encounter?.name ?? '');
  late final _notesController = TextEditingController(text: widget.encounter?.notes ?? '');
  late var _monsters = [...?widget.encounter?.monsters];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Encounter get _encounter => Encounter(
    id: widget.encounter?.id ?? EncountersCubit.newId(),
    name: _nameController.text.trim().isEmpty ? 'Без названия' : _nameController.text.trim(),
    notes: _notesController.text.trim(),
    monsters: _monsters,
  );

  Future<void> _addMonster() async {
    final monster = await pickMonster(context);
    if (monster == null) return;
    final index = _monsters.indexWhere((e) => e.monsterId == monster.id);
    setState(() {
      if (index < 0) {
        _monsters = [..._monsters, EncounterMonster(monsterId: monster.id, count: 1)];
      } else {
        _changeCount(index, 1);
      }
    });
  }

  /// Количество 0 убирает монстра из ситуации.
  void _changeCount(int index, int delta) {
    final group = _monsters[index];
    final count = group.count + delta;
    _monsters = [
      for (final (i, e) in _monsters.indexed)
        if (i != index) e else if (count > 0) EncounterMonster(monsterId: group.monsterId, count: count),
    ];
  }

  Future<void> _save() async {
    final encounter = _encounter;
    context.read<BattleCubit>().encounterChanged(encounter);
    await context.read<EncountersCubit>().save(encounter);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final encounter = _encounter;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.encounter == null ? 'Новая ситуация' : 'Ситуация'),
        actions: [IconButton(tooltip: 'Сохранить', onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название', hintText: 'Засада на тракте'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Заметки', hintText: 'Местность, тактика, награда'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Text('Монстры', style: Theme.of(context).textTheme.titleMedium)),
                Text('${encounter.monsterCount} шт. · ${encounter.experience} опыта'),
              ],
            ),
            for (final (index, group) in _monsters.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(group.template!.name),
                subtitle: Text('ПО ${group.template!.challenge} · КД ${group.template!.armorClass}'),
                onTap: () => showMonsterStatBlock(context, group.template!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() => _changeCount(index, -1)),
                    ),
                    Text('${group.count}'),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _changeCount(index, 1))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addMonster,
              icon: const Icon(Icons.add),
              label: const Text('Добавить монстра'),
            ),
          ],
        ),
      ),
    );
  }
}
