import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

enum Skill {
  ///Акробатика
  acrobatics(StatKind.dexterity),

  ///Атлетика
  athletics(StatKind.strength),

  ///Магия
  magic(StatKind.intelligence),

  ///Обман
  fraud(StatKind.charisma),

  ///История
  history(StatKind.intelligence),

  ///Проницательность
  insight(StatKind.wisdom),

  ///Запугивание
  harassment(StatKind.charisma),

  ///Анализ
  analysis(StatKind.intelligence),

  ///Медицина
  medicine(StatKind.wisdom),

  ///Природа
  nature(StatKind.wisdom),

  ///Восприятие
  perception(StatKind.wisdom),

  ///Выступление
  perfomance(StatKind.charisma),

  ///Убеждение
  conviction(StatKind.charisma),

  ///Религия
  religion(StatKind.intelligence),

  ///Ловкость рук
  manualDexterity(StatKind.dexterity),

  ///Скрытность
  stealth(StatKind.dexterity),

  ///Выживание
  surviving(StatKind.wisdom),

  ///Обращение с животными
  animalTaming(StatKind.wisdom);

  const Skill(this.origin);

  final StatKind origin;

  String get name => switch (this) {
        acrobatics => 'Акробатика',
        athletics => 'Атлетика',
        magic => 'Магия',
        fraud => 'Обман',
        history => 'История',
        insight => 'Проницательность',
        harassment => 'Запугивание',
        analysis => 'Анализ',
        medicine => 'Медицина',
        nature => 'Природа',
        perception => 'Восприятие',
        perfomance => 'Выступление',
        conviction => 'Убеждение',
        religion => 'Религия',
        manualDexterity => 'Ловкость рук',
        stealth => 'Скрытность',
        surviving => 'Выживание',
        animalTaming => 'Обращение с животными',
      };

  int getBonus(Player player) {
    var mainBonus = switch (origin) {
      StatKind.strength => player.strength.bonus,
      StatKind.dexterity => player.dexterity.bonus,
      StatKind.constitution => player.constitution.bonus,
      StatKind.intelligence => player.intelligence.bonus,
      StatKind.wisdom => player.wisdom.bonus,
      StatKind.charisma => player.charisma.bonus,
    };

    if (player.chosenSkills.contains(this)) {
      return mainBonus + player.proficiencyBonus;
    }
    return mainBonus;
  }
}
