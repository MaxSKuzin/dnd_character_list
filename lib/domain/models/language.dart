import 'package:dnd_character_list/domain/models/item_with_name.dart';

enum Language with ItemWithName {
  giant,
  gnomish,
  goblin,
  dvarven,
  common,
  orcish,
  halfling,
  elvish,
  abyssal,
  deepSpeech,
  draconic,
  infernal,
  celestial,
  primordial,
  underground,
  sylvan;

  @override
  String get name => switch (this) {
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
