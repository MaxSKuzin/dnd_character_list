import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

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

extension SkillLocalization on Skill {
  String get localizedName => switch (this) {
        Skill.athletics => 'Атлетика',
        Skill.acrobatics => 'Акробатика',
        Skill.sleightOfHand => 'Ловкость рук',
        Skill.stealth => 'Скрытность',
        Skill.history => 'История',
        Skill.arcana => 'Магия',
        Skill.nature => 'Природа',
        Skill.investigation => 'Расследование',
        Skill.religion => 'Религия',
        Skill.perception => 'Восприятие',
        Skill.survival => 'Выживание',
        Skill.medicine => 'Медицина',
        Skill.insight => 'Проницательность',
        Skill.animalHandling => 'Уход за животными',
        Skill.performance => 'Выступление',
        Skill.intimidation => 'Запугивание',
        Skill.deception => 'Обман',
        Skill.persuasion => 'Убеждение',
      };
}

extension StatKindLocalization on StatKind {
  String get localizedName => switch (this) {
        StatKind.strength => 'Сила',
        StatKind.dexterity => 'Ловкость',
        StatKind.constitution => 'Телосложение',
        StatKind.intelligence => 'Интеллект',
        StatKind.wisdom => 'Мудрость',
        StatKind.charisma => 'Харизма',
      };
}

extension ToolCategoryLocalization on ToolCategory {
  String get localizedName => switch (this) {
        ToolCategory.thievesTool => 'Воровские инструменты',
        ToolCategory.playSet => 'Игровой набор',
        ToolCategory.navigatorTool => 'Навигаторские инструменты',
        ToolCategory.poisonerTool => 'Инструменты отравителя',
        ToolCategory.musicalInstrument => 'Музыкальный инструмент',
        ToolCategory.makeupKit => 'Набор для грима',
        ToolCategory.falsificationKit => 'Набор для фальсификации',
        ToolCategory.foldOfLawn => 'Набор травника',
        ToolCategory.craftsmenTool => 'Инструменты ремесленника',
        ToolCategory.vehicle => 'Транспорт',
      };
}

extension LanguageLocalization on Language {
  String get localizedName => switch (this) {
        Language.giant => 'Великаний',
        Language.gnomish => 'Гномий',
        Language.goblin => 'Гоблинский',
        Language.dvarven => 'Дварфский',
        Language.common => 'Общий',
        Language.orcish => 'Орочий',
        Language.halfling => 'Полуросликов',
        Language.elvish => 'Эльфийский',
        Language.abyssal => 'Бездны',
        Language.deepSpeech => 'Глубинная речь',
        Language.draconic => 'Драконий',
        Language.infernal => 'Инфернальный',
        Language.celestial => 'Небесный',
        Language.primordial => 'Первичный',
        Language.underground => 'Подземный',
        Language.sylvan => 'Сильванский',
      };
}

extension ArmorProficiencyLocalization on ArmorProficiency {
  String get localizedName => switch (this) {
        ArmorProficiency.light => 'лёгкие',
        ArmorProficiency.medium => 'средние',
        ArmorProficiency.heavy => 'тяжёлые',
        ArmorProficiency.shields => 'щиты',
      };
}
