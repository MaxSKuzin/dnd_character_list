import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

abstract class Spell {
  String get name;

  SpellSlot get slot;

  int get distance;

  Duration? get duration;

  int? get durationInRounds;

  bool get isConcentration;

  String description(Player player, Specialization spec);

  List<SpellComponent> get components;

  List<ClassKind> get allowedSpecializations;

  SpellTime get castTimeType;

  int get timeToCast;

  bool get isRitual => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Spell &&
        other.name == name &&
        other.slot == slot &&
        other.distance == distance &&
        other.duration == duration &&
        other.isConcentration == isConcentration &&
        other.components.equals(components);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        slot.hashCode ^
        distance.hashCode ^
        duration.hashCode ^
        isConcentration.hashCode ^
        components.hashCode;
  }
}
