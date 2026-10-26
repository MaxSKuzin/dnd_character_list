import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

Future<void> showMonsterStatBlock(BuildContext context, MonsterTemplate monster) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => SafeArea(
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        child: MonsterStatBlock(monster: monster),
      ),
    ),
  ),
);

/// Статблок монстра: защита, характеристики, особенности и действия.
class MonsterStatBlock extends StatelessWidget {
  final MonsterTemplate monster;

  /// Хиты экземпляра в бою вместо средних из статблока.
  final String? hits;

  const MonsterStatBlock({super.key, required this.monster, this.hits});

  static const _abilityNames = {
    Ability.strength: 'СИЛ',
    Ability.dexterity: 'ЛОВ',
    Ability.constitution: 'ТЕЛ',
    Ability.intelligence: 'ИНТ',
    Ability.wisdom: 'МДР',
    Ability.charisma: 'ХАР',
  };

  static String _signed(int value) => value >= 0 ? '+$value' : '−${value.abs()}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget feature(MonsterFeature feature) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${feature.name}. ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            TextSpan(text: feature.text),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(monster.name, style: theme.textTheme.titleLarge),
        Text(monster.kind, style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
        const Divider(),
        Text('Класс доспеха: ${monster.armorClass}${monster.armorNote == null ? '' : ' (${monster.armorNote})'}'),
        Text('Хиты: ${hits ?? '${monster.averageHits} (${monster.hitDice})'}'),
        Text('Скорость: ${[if (monster.speed > 0) '${monster.speed} фт.', ?monster.speedNote].join(', ')}'),
        const Divider(),
        Row(
          children: [
            for (final ability in Ability.values)
              Expanded(
                child: Column(
                  children: [
                    Text(_abilityNames[ability]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${monster.abilities[ability]} (${_signed(abilityModifier(monster.abilities[ability]))})'),
                  ],
                ),
              ),
          ],
        ),
        const Divider(),
        for (final property in monster.properties) Text('${property.name}: ${property.text}'),
        Text('Пассивная Внимательность: ${monster.passivePerception}'),
        Text('Опасность: ${monster.challenge} (${monster.experience} опыта)'),
        const Divider(),
        ...monster.traits.map(feature),
        for (final (title, features) in [
          ('Действия', monster.actions),
          ('Бонусные действия', monster.bonusActions),
          ('Реакции', monster.reactions),
          ('Легендарные действия', monster.legendaryActions),
        ])
          if (features.isNotEmpty) ...[
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...features.map(feature),
          ],
      ],
    );
  }
}
