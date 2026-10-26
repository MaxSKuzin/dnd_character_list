import 'package:dnd_character_list/data/dnd_su/dnd_su_backgrounds_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_class_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_feats_parser.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:flutter_test/flutter_test.dart';

// Сокращённые фрагменты реальных страниц dnd.su.
const _classPage = '''
<div class="card__header"><h2 class="card-title" itemprop="name"><a href='/class/88-bard/'>Бард [Bard]</a></h2></div>
<div class="card__body new-article" itemprop="articleBody">
<ul class="params card__article-body"><li><strong>Источник:</strong> «<span>Player's Handbook</span>»</li></ul>
<table class="class_table"><tbody>
<tr class="table_header">
  <td rowspan="2"><span class="long">Уровень</span></td>
  <td rowspan="2"><span class="long">Бонус<br>мастерства</span></td>
  <td rowspan="2">Умения</td>
  <td rowspan="2"><span class="long">Известные<br>заговоры</span></td>
  <td rowspan="2"><span class="long">Известные<br>заклинания</span></td>
  <td colspan="9"><span class="long">Ячейки заклинаний на уровень заклинаний</span></td>
</tr>
<tr class="table_header spell-slots-row"><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td><td>8</td><td>9</td></tr>
<tr><td>1</td><td>+2</td>
<td><a href="#feature.spellcasting">Использование заклинаний</a><span class="TCE-feature-on">, <a href="#feature.extra-spells">Дополнительные заклинания</a></span>, <a href="#feature.bardic-inspiration">Вдохновение барда (к6)</a></td>
<td>2</td><td>4</td><td>2</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
<tr><td>2</td><td>+2</td>
<td><a href="#feature.bardic-inspiration">Вдохновение барда (к8)</a></td>
<td>2</td><td>5</td><td>3</td><td>1</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
</tbody></table>
<h3 class="underlined spoiler_head"><span id='sozdanie_barda'>Создание барда</span></h3><div>
<h3 class="smallSectionTitle">БЫСТРОЕ СОЗДАНИЕ</h3>
<p>У вашей Харизмы должно быть наивысшее значение.</p>
<br></div>
<div class="additionalInfo"><h3 class="smallSectionTitle spoiler_head">Хиты, владение и снаряжение</h3><span>
<h4 class="smallSectionTitle">ХИТЫ</h4>
<p><strong>Кость Хитов:</strong> 1к8 за каждый уровень барда</p>
<br>
<h4 class="smallSectionTitle">ВЛАДЕНИЕ</h4>
<p><strong>Доспехи:</strong> Лёгкие доспехи</p>
<p><strong>Инструменты:</strong> Три <a href="/articles/inventory/100-tools/#Музыкальные">музыкальных инструмента</a> на ваш выбор</p>
<p><strong>Спасброски:</strong> Ловкость, Харизма</p>
<p><strong>Навыки:</strong> Выберите три любых</p>
<br>
<h4 class="smallSectionTitle">СНАРЯЖЕНИЕ</h4>
<ul><li>Кожаный доспех и кинжал</li></ul>
</span></div>
<br>
<h3 class="underlined"><span id='feature.spellcasting'>ИСПОЛЬЗОВАНИЕ ЗАКЛИНАНИЙ</span></h3>
<p><em>1-й уровень, умение барда</em></p>
<p>Вы научились изменять ткань реальности.</p>
<h4 class="smallSectionTitle">Заговоры (заклинания 0-го уровня)</h4>
<p>Вы знаете два заговора.</p>
<div class="TCE-feature-on">
<br>
<h3 class="underlined"><span id='feature.extra-spells'>Дополнительные заклинания барда</span></h3>
<p><em>1-й уровень, опциональное умение барда</em></p>
<p>Заклинания расширяют список барда.</p></div>
<br>
<h3 class="underlined"><span id='feature.bardic-inspiration'>ВДОХНОВЕНИЕ БАРДА</span></h3>
<p><em>1-й уровень, умение барда</em></p>
<p>Это существо получает кость бардовского вдохновения — к6.</p>
<br><br>
<h2 class="bigSectionTitle spoiler_head"><span id='bard-colleges'>Коллегии бардов</span></h2><div>
<p>Барды не любят одиночества.</p>
<br></div>
<h2 class="bigSectionTitle hide-next hide-next-h2"><span id='college.lore'>Коллегия знаний</span></h2>
<div class="hide-wrapper">
<p>Барды коллегии знаний знают что-то о многом.</p>
<br>
<h3 class="smallSectionTitle">ДОПОЛНИТЕЛЬНЫЕ НАВЫКИ</h3>
<p><em>3-й уровень, умение коллегии знаний</em></p>
<p>Вы получаете владение тремя любыми навыками.</p>
</div>
<div class="addition-wrapper addition-6"><h2 class="bigSectionTitle hide-next hide-next-h2"><span id='college.swords'>Коллегия мечей</span></h2>
<div class="hide-wrapper">
<p><strong>Источник: «Xanathar’s Guide to Everything»</strong></p>
<br><p>Бардов Коллегии Мечей называют клинками.</p>
<br>
<h3 class="smallSectionTitle">БОЕВОЙ СТИЛЬ</h3>
<p><em>3-й уровень, умение коллегии мечей</em></p>
<p>Вы выбираете боевой стиль.</p>
</div></div>
<h2 class="bigSectionTitle hide-next hide-next-h2"><span id='uglubljonnaya_predystoriya'>Углублённая предыстория Барда (XGE)</span></h2>
<div class="hide-wrapper"><p>Главное произведение.</p></div>
<br><h2 class="bigSectionTitle underlined"><span id='unofficial'>Unearthed Arcana &amp; Unofficial</span></h2>
<h2 class="bigSectionTitle hide-next hide-next-h2"><span id='hb.college.fury'>Коллегия ярости</span></h2>
<div class="hide-wrapper">
<h3 class="smallSectionTitle"><span id='feature.furys-revelry'>Разгул ярости</span></h3>
<p><em>3-й уровень, умение коллегии ярости</em></p>
<p>Homebrew.</p>
</div>
</div>
<section class="comments-block">Комментарии</section>''';

const _backgroundPage = '''
<div class="card__header"><h2 class="card-title" itemprop="name"><span data-copy="Артист [Entertainer]">Артист [Entertainer]</span><span class='source-plaque' title="Player's Handbook">PH14</span></h2></div>
<div class="card__body new-article" itemprop="articleBody"><ul class="params card__article-body"><li class="subsection desc"><div itemprop="description"><p>Вам нравится выступать на публике.</p>
<p><strong>Владение навыками:</strong> <span tooltip-for="skill.acrobatics" title="skill.acrobatics">Акробатика</span>, <span tooltip-for="skill.performance" title="skill.performance">Выступление</span>.</p>
<p><strong>Владение инструментами:</strong> <span tooltip-for="tools.disguise" title="tools.disguise">Набор для грима</span>, один вид <span tooltip-for="tools.music" title="tools.music">музыкального инструмента</span>.</p>
<p><strong>Языки:</strong> Один на ваш выбор</p>
<p><strong>Снаряжение:</strong> <a href="/articles/inventory/100-tools/#Музыкальные">Музыкальный инструмент</a> (на ваш выбор), подарок от поклонницы (любовное письмо, локон волос или безделушка), карта города, в котором вы выросли, костюм, поясной кошель с 15 зм</p>
<br><h3 class="smallSectionTitle">УМЕНИЕ: ПО МНОГОЧИСЛЕННЫМ ПРОСЬБАМ </h3><p>Вы всегда можете найти место для выступления.</p>
<br><h3 class="smallSectionTitle">ПЕРСОНАЛИЗАЦИЯ </h3><p>Успешные артисты могут овладевать вниманием публики.</p>
<br><table><tbody>
<tr class="table_header"><td>к10</td><td>Амплуа</td></tr>
<tr><td>1</td><td>Акробат</td></tr>
<tr><td>2</td><td>Актер</td></tr>
</tbody></table>
<br><table><tbody>
<tr class="table_header"><td>к8</td><td>Черта характера</td></tr>
<tr><td>1</td><td>Для любой ситуации я найду подходящий рассказ. </td></tr>
<tr><td>2</td><td>Я безнадёжный романтик.</td></tr>
</tbody></table>
<br><table><tbody>
<tr class="table_header"><td>к6</td><td>Идеал</td></tr>
<tr><td>1</td><td><strong>Красота</strong>. Выступая, я делаю мир лучше. (Добрый)</td></tr>
</tbody></table>
</div></li></ul></div>''';

String _featPage(String title, String body, {String? requirement}) => '''
<div class="card__header"><h2 class="card-title" itemprop="name"><span data-copy="$title">$title</span></h2></div>
<div class="card__body new-article" itemprop="articleBody"><ul class="params card__article-body">
${requirement == null ? '' : '<li class="size-type-alignment">Требование: $requirement</li>'}
<li class="subsection desc"><div itemprop="description">$body</div></li></ul></div>''';

void main() {
  group('class page', () {
    late final ClassInfo bard;

    setUpAll(() => bard = DndSuClassParser().parseClass('/class/88-bard/', _classPage));

    test('parses name, proficiencies and quick build', () {
      expect(bard.name, 'Бард');
      expect(bard.nameEn, 'Bard');
      expect(bard.savingThrows, [StatKind.dexterity, StatKind.charisma]);
      expect(bard.skillsCount, 3);
      expect(bard.skillOptions, isEmpty, reason: '«Выберите три любых»');
      expect(bard.tools.single.category, ToolCategory.musicalInstrument);
      expect(bard.tools.single.choose, 3);
      expect(bard.hitPointsHtml, contains('1к8'));
      expect(bard.equipmentHtml, contains('Кожаный доспех'));
      expect(bard.quickBuildHtml, contains('Харизмы'));
    });

    test('parses level table with TCE features', () {
      final first = bard.level(1);
      expect(first.proficiencyBonus, 2);
      expect(first.cantripsKnown, 2);
      expect(first.spellsKnown, 4);
      expect(first.spellSlots, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(first.features.map((e) => e.id), [
        'feature.spellcasting',
        'feature.extra-spells',
        'feature.bardic-inspiration',
      ]);
      expect(bard.level(2).maxSpellLevel, 2);
      expect(bard.featureValueAt('feature.bardic-inspiration', 1), 'к6');
      expect(bard.featureValueAt('feature.bardic-inspiration', 2), 'к8');
    });

    test('parses features without unofficial ones', () {
      expect(bard.features.map((e) => e.id), [
        'feature.spellcasting',
        'feature.extra-spells',
        'feature.bardic-inspiration',
      ]);
      final spellcasting = bard.feature('feature.spellcasting')!;
      expect(spellcasting.name, 'Использование заклинаний');
      expect(spellcasting.level, 1);
      expect(spellcasting.isOptional, isFalse);
      expect(spellcasting.descriptionHtml, contains('Вы знаете два заговора'));
      expect(spellcasting.descriptionHtml, isNot(contains('1-й уровень')));
      expect(bard.feature('feature.extra-spells')!.isOptional, isTrue);
      expect(bard.featuresAt(1).map((e) => e.name), contains('Вдохновение барда'));
    });

    test('parses official colleges only', () {
      expect(bard.subclasses.map((e) => e.id), ['college.lore', 'college.swords']);
      final lore = bard.subclass('college.lore')!;
      expect(lore.source, "Player's Handbook", reason: 'Без своей строки — источник класса');
      expect(lore.featuresAt(3).single.name, 'Дополнительные навыки');
      final swords = bard.subclass('college.swords')!;
      expect(swords.source, 'Xanathar’s Guide to Everything');
      expect(swords.descriptionHtml, isNot(contains('Источник')));
      expect(swords.features.single.descriptionHtml, contains('боевой стиль'));
    });

    test('survives json roundtrip', () {
      expect(ClassInfo.fromJson(bard.toJson()).toJson(), bard.toJson());
    });
  });

  test('background page', () {
    final background = DndSuBackgroundsParser().parseBackground('/backgrounds/757-entertainer/', _backgroundPage);

    expect(background.id, 757);
    expect(background.name, 'Артист');
    expect(background.nameEn, 'Entertainer');
    expect(background.skills, [Skill.acrobatics, Skill.performance]);
    expect(background.tools.map((e) => (e.title, e.category, e.choose)), [
      ('Набор для грима', ToolCategory.makeupKit, 0),
      ('Один вид музыкального инструмента', ToolCategory.musicalInstrument, 1),
    ]);
    expect(background.languagesCount, 1);
    expect(background.gold, 15);
    expect(background.equipment, [
      'Музыкальный инструмент (на ваш выбор)',
      'Подарок от поклонницы (любовное письмо, локон волос или безделушка)',
      'Карта города, в котором вы выросли',
      'Костюм',
      'Поясной кошель',
    ]);
    expect(background.featureName, 'По многочисленным просьбам');
    expect(background.featureHtml, contains('найти место для выступления'));
    expect(background.tables.map((e) => (e.title, e.kind, e.options.length)), [
      ('Амплуа', PersonalityTableKind.other, 2),
      ('Черта характера', PersonalityTableKind.trait, 2),
      ('Идеал', PersonalityTableKind.ideal, 1),
    ]);
    expect(background.tables[2].options.single, 'Красота. Выступая, я делаю мир лучше. (Добрый)');
    expect(Background.fromJson(background.toJson()).toJson(), background.toJson());
  });

  group('feat page', () {
    final parser = DndSuFeatsParser();

    test('parses stat increase options', () {
      final athlete = parser.parseFeat(
        '/feats/102-athlete/',
        _featPage('Атлетичный [Athlete]', '<ul><li>Увеличьте значение Силы или Ловкости на 1 при максимуме 20.</li></ul>'),
      );
      expect(athlete.name, 'Атлетичный');
      expect(athlete.slug, 'athlete');
      expect(athlete.statIncreaseOptions, [StatKind.strength, StatKind.dexterity]);

      final resilient = parser.parseFeat(
        '/feats/140-resilient/',
        _featPage(
          'Устойчивый [Resilient]',
          '<ul><li>Увеличьте значение выбранной характеристики на 1 при максимуме 20.</li></ul>',
        ),
      );
      expect(resilient.statIncreaseOptions, StatKind.values);
      expect(resilient.grantsSavingThrow, isTrue);
    });

    test('parses requirements', () {
      final ritualCaster = parser.parseFeat(
        '/feats/135-ritual-caster/',
        _featPage('Ритуальный заклинатель [Ritual caster]', '<p>Вы выучили ритуалы.</p>',
            requirement: 'Интеллект или Мудрость 13 или выше'),
      );
      expect(ritualCaster.requirement.minimumStats, [StatKind.intelligence, StatKind.wisdom]);

      final heavilyArmored = parser.parseFeat(
        '/feats/115-heavily-armored/',
        _featPage('Знаток тяжёлых доспехов [Heavily armored]', '<p>Доспехи.</p>',
            requirement: 'Владение средними доспехами'),
      );
      expect(heavilyArmored.requirement.armor, ArmorProficiency.medium);
      expect(heavilyArmored.armorProficiency, ArmorProficiency.heavy);

      final warCaster = parser.parseFeat(
        '/feats/104-war-caster/',
        _featPage('Боевой заклинатель [War Caster]', '<p>Магия.</p>',
            requirement: 'Способность накладывать хотя бы одно заклинание'),
      );
      expect(warCaster.requirement.spellcasting, isTrue);
    });
  });

  test('page without card content can be retried', () {
    expect(
      () => DndSuBackgroundsParser().parseBackground('/backgrounds/757-entertainer/', '<div class="cards-wrapper"></div>'),
      throwsA(isA<DndSuMissingContentException>()),
    );
  });
}
