import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';

class Peculiarity {
  final String name;
  final String description;
  final SpellSlot? manaRequired;

  const Peculiarity({
    required this.name,
    required this.description,
    this.manaRequired,
  });

  @override
  bool operator ==(Object other) {
    if (other is Peculiarity) {
      return name == other.name && description == other.description;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([name, description]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory Peculiarity.fromJson(Map<String, dynamic> json) => Peculiarity(
        name: json['name'],
        description: json['description'],
      );
}
