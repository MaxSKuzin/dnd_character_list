import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_master/presentation/monsters/monster_stat_block.dart';
import 'package:flutter/material.dart';

/// Выбор монстра из бестиария. `null` — закрыто без выбора.
Future<MonsterTemplate?> pickMonster(BuildContext context) => showModalBottomSheet<MonsterTemplate>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => SafeArea(
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Бестиарий', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          ),
          for (final monster in Bestiary.monsters)
            ListTile(
              title: Text(monster.name),
              subtitle: Text('ПО ${monster.challenge} · КД ${monster.armorClass} · хиты ${monster.averageHits}'),
              onTap: () => Navigator.pop(context, monster),
              trailing: IconButton(
                tooltip: 'Статблок',
                icon: const Icon(Icons.info_outline),
                onPressed: () => showMonsterStatBlock(context, monster),
              ),
            ),
        ],
      ),
    ),
  ),
);
