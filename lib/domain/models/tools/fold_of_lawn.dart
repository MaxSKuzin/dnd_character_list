import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

List<Tool> get foldOfLawnTools => [
      Tool(
        category: ToolCategory.foldOfLawn,
        name: 'Набор травника',
        description:
            '''Владение набором травника позволяет вам распознавать растения и безопасно собирать их полезные части.

<b>Компоненты</b>. Включает в себя мешочки для хранения трав, секатор и кожаные перчатки для сбора растений, несколько стеклянных банок, ступку и пестик.

<b>Магия</b>. Ваши осведомлённость в природе и использовании растений может дать дополнительные знания к магическим исследованиям, когда дело касается растений и попыток опознать зелье.

<b>Расследование</b>. Когда вы обследуете заросшую растениями зону, владение этим набором помогает вам находить детали и зацепки, которые другие бы проглядели.

<b>Медицина</b>. Ваше мастерство травника улучшает ваши способности лечить болезни и раны, расширяя доступные методы благодаря использованию лекарственных растений.

<b>Природа и Выживание</b>. Когда вы путешествуете в дикой местности, ваши навыки травничества облегчают опознание растений и поиск источников еды, которые другие могут не заметить.

<b>Опознание растений</b>. Вы можете быстро распознать большинство растений по запаху и внешнему виду.''',
        price: Balance.fromGold(5),
      ),
    ];
