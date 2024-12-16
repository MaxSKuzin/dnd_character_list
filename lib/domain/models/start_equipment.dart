import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

class StartEquipment {
  final List<Weapon> weapons;
  final Armor? armor;
  final List<Weapon>? secondWeapons;

  StartEquipment({
    required this.weapons,
    required this.armor,
    required this.secondWeapons,
  });
}
