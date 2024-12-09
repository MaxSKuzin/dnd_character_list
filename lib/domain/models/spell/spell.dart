import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';

class Spell {
  final String name;
  final SpellSlot slot;
  final int distance;
  final int duration;
  final bool isConcentration;
  final String description;
  final List<SpellComponent> components;

  const Spell({
    required this.name,
    required this.slot,
    required this.distance,
    required this.duration,
    required this.isConcentration,
    required this.description,
    required this.components,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Spell &&
        other.name == name &&
        other.slot == slot &&
        other.distance == distance &&
        other.duration == duration &&
        other.isConcentration == isConcentration &&
        other.description == description &&
        other.components == components;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        slot.hashCode ^
        distance.hashCode ^
        duration.hashCode ^
        isConcentration.hashCode ^
        description.hashCode ^
        components.hashCode;
  }
}
