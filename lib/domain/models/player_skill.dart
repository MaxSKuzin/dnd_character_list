import 'package:dnd_character_list/domain/models/skill.dart';

class PlayerSkill {
  final Skill origin;
  final int bonus;
  final bool isChosen;

  const PlayerSkill({
    required this.origin,
    required this.bonus,
    required this.isChosen,
  });

  @override
  bool operator ==(Object other) => other is PlayerSkill && other.origin == origin && other.bonus == bonus && other.isChosen == isChosen;

  @override
  int get hashCode => Object.hash(origin, bonus, isChosen);
}
