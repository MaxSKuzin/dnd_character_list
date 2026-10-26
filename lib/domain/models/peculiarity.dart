import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';

class Peculiarity {
  final String name;
  final String description;
  final String? _magicDescription;
  final SpellSlot? requiredSlot;
  final Dice? valueDice;
  final int? startDiceCount;
  final int? dicePerLevel;
  final int? maxDiceCount;

  /// Описание в html с ttg.club; иначе — текст с разметкой <b>/<i>.
  final bool isHtml;

  const Peculiarity({
    required this.name,
    required this.description,
    this.isHtml = false,
    String? magicDescription,
    this.requiredSlot,
    this.valueDice,
    this.startDiceCount,
    this.dicePerLevel,
    this.maxDiceCount,
  }) : _magicDescription = magicDescription;

  String magicDescription(SpellSlot slotToUse) {
    if (_magicDescription == null || requiredSlot == null || startDiceCount == null || valueDice == null) {
      return description;
    }

    int startCount = startDiceCount!;

    startCount += slotToUse.index * dicePerLevel!;
    if (maxDiceCount != null) {
      startCount = startCount.clamp(0, maxDiceCount!);
    }

    final newDescription = _magicDescription.replaceAll(RegExp('[0-9]к[0-9]*'), '$startCount${valueDice!.name}');

    return newDescription;
  }

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
        'spellSlot': requiredSlot?.name,
        'valueDice': valueDice?.toJson(),
        'startDiceCount': startDiceCount,
        'dicePerLevel': dicePerLevel,
        'magicDescription': _magicDescription,
        'maxDiceCount': maxDiceCount,
        'isHtml': isHtml,
      };

  factory Peculiarity.fromJson(Map<String, dynamic> json) => Peculiarity(
        name: json['name'],
        description: json['description'],
        requiredSlot: json['spellSlot'] != null ? SpellSlot.values.byName(json['spellSlot']) : null,
        valueDice: json['valueDice'] != null ? Dice.fromJson(json['valueDice']) : null,
        startDiceCount: json['startDiceCount'],
        dicePerLevel: json['dicePerLevel'],
        magicDescription: json['magicDescription'],
        maxDiceCount: json['maxDiceCount'],
        isHtml: json['isHtml'] ?? false,
      );
}
