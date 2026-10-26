import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_master/presentation/encounters/encounter_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Подготовленные боевые ситуации: создание, редактирование, удаление.
class EncountersScreen extends StatelessWidget {
  const EncountersScreen({super.key});

  static String summary(Encounter encounter) {
    if (encounter.monsters.isEmpty) return 'Без монстров';
    final monsters = encounter.monsters.map((e) => e.count == 1 ? e.template.name : '${e.template.name} ×${e.count}');
    return '${monsters.join(', ')} · ${encounter.experience} опыта';
  }

  Future<void> _remove(BuildContext context, Encounter encounter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить «${encounter.name}»?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<BattleCubit>().forget(encounter.id);
    await context.read<EncountersCubit>().remove(encounter.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Боевые ситуации')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Новая ситуация',
        onPressed: () => EncounterEditorScreen.open(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<EncountersCubit, List<Encounter>>(
        builder: (context, encounters) {
          if (encounters.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Подготовьте ситуации заранее — во время сессии между ними можно переключаться',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                for (final encounter in encounters)
                  ListTile(
                    title: Text(encounter.name),
                    subtitle: Text(summary(encounter)),
                    onTap: () => EncounterEditorScreen.open(context, encounter),
                    trailing: IconButton(
                      tooltip: 'Удалить',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remove(context, encounter),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
