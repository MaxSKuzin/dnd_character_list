import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

extension ClassKindLocalization on ClassKind {
  String get localizedName => switch (this) {
        ClassKind.bard => 'Бард',
        ClassKind.barbarian => 'Варвар',
        ClassKind.warrior => 'Воин',
        ClassKind.wizard => 'Волшебник',
        ClassKind.driud => 'Друид',
        ClassKind.cliric => 'Жрец',
        ClassKind.inventor => 'Изобретатель',
        ClassKind.witch => 'Колдун',
        ClassKind.monk => 'Монах',
        ClassKind.paladin => 'Паладин',
        ClassKind.thief => 'Плут',
        ClassKind.ranger => 'Следопыт',
        ClassKind.sorcerer => 'Чародей',
      };
}

extension SpellSlotLocalization on SpellSlot {
  String get localizedName => switch (this) {
        SpellSlot.conspiracy => 'Заговор',
        SpellSlot.level1 => '1 уровень',
        SpellSlot.level2 => '2 уровень',
        SpellSlot.level3 => '3 уровень',
        SpellSlot.level4 => '4 уровень',
        SpellSlot.level5 => '5 уровень',
        SpellSlot.level6 => '6 уровень',
        SpellSlot.level7 => '7 уровень',
        SpellSlot.level8 => '8 уровень',
        SpellSlot.level9 => '9 уровень',
      };
}

extension SpellTimeLocalization on SpellTime {
  String get localizedName => switch (this) {
        SpellTime.action => 'Действие',
        SpellTime.bonusAction => 'Бонусное действие',
        SpellTime.reaction => 'Реакция',
        SpellTime.minute => 'Минуты',
        SpellTime.hour => 'Часы',
      };
}

extension SpellComponentLocalization on SpellComponent {
  String get localizedName => switch (this) {
        SpellComponent.verbal => 'В',
        SpellComponent.somatic => 'С',
        SpellComponent.material => 'М',
      };
}
