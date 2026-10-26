import 'package:dnd_character_list/domain/models/armor_proficiency.dart';

enum ArmorKind {
  light,
  medium,
  heavy;

  ArmorProficiency get proficiency => switch (this) {
        ArmorKind.light => ArmorProficiency.light,
        ArmorKind.medium => ArmorProficiency.medium,
        ArmorKind.heavy => ArmorProficiency.heavy,
      };
}
