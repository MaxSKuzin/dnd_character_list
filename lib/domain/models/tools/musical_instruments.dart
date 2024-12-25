import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

const _description =
    '''Владение музыкальным инструментом означает, что вы знакомы с приёмами игры на нём. Вы также знаете несколько песен, как правило, исполняющихся на этом инструменте.

<b>История</b>. Ваш опыт помогает вам вспомнить исторические факты, связанные с вашим инструментом.

<b>Выступление</b>. Ваши постановки заметно улучшаются, когда вы включаете в них игру на инструменте.

<b>Сочинение мелодии</b>. Частью продолжительного отдыха вы можете сочинить новую мелодию и слова для песни, исполняемой на вашем инструменте. Вы можете использовать эту способность, чтобы произвести впечатление на дворянина или распространять скандальные слухи с надоедливой мелодией.''';

List<Tool> get musicalInstruments => [
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Барабан',
        description: _description,
        price: Balance.fromGold(6),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Виола',
        description: _description,
        price: Balance.fromGold(30),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Волынка',
        description: _description,
        price: Balance.fromGold(30),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Лира',
        description: _description,
        price: Balance.fromGold(30),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Лютня',
        description: _description,
        price: Balance.fromGold(35),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Рожок',
        description: _description,
        price: Balance.fromGold(3),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Свирель',
        description: _description,
        price: Balance.fromGold(12),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Флейта',
        description: _description,
        price: Balance.fromGold(2),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Цимбалы',
        description: _description,
        price: Balance.fromGold(25),
      ),
      Tool(
        category: ToolCategory.musicalInstrument,
        name: 'Шалмей',
        description: _description,
        price: Balance.fromGold(2),
      ),
    ];
