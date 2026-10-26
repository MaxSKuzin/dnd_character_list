import 'package:dnd_character_list/data/dnd_su/dnd_su_class_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_equipment_parser.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';
import 'package:flutter_test/flutter_test.dart';

// Сокращённые фрагменты статей https://dnd.su/articles/inventory/.
String _article(String content) => '''
<div class="card__header"><h2 class="card-title">Статья</h2></div>
<div class="card__body" itemprop="articleBody">$content</div>
<section class="comments-block"></section>''';

final _weapons = _article('''
<table><tbody>
<tr class="table_header"><td>Название</td><td>Стоимость</td><td>Урон</td><td>Вес</td><td>Свойства</td></tr>
<tr><td colspan="5"><strong><em><span id='weapon.simple'>Простое рукопашное оружие</span></em></strong></td></tr>
<tr><td><span id='weapon.dagger'>Кинжал</span></td><td>2 зм</td><td>1к4 колющий</td><td>1 фнт.</td>
<td><span class="tooltip">Лёгкое</span>, <span class="tooltip">метательное </span>(дис. 20/60), <span class="tooltip">фехтовальное</span></td></tr>
<tr><td><span id='weapon.javelin'>Метательное копьё</span></td><td>5 см</td><td>1к6 колющий</td><td>2 фнт.</td><td>Метательное (дис. 30/120)</td></tr>
<tr><td colspan="5"><strong><em>Простое дальнобойное оружие</em></strong></td></tr>
<tr><td><span id='weapon.shortbow'>Короткий лук</span></td><td>25 зм</td><td>1к6 колющий</td><td>2 фнт.</td><td>Боеприпас (дис. 80/320), двуручное</td></tr>
<tr><td colspan="5"><strong><em><span id='weapon.martial'>Воинское рукопашное оружие</span></em></strong></td></tr>
<tr><td><span id='weapon.longsword'>Длинный меч</span></td><td>15 зм</td><td>1к8 рубящий</td><td>3 фнт.</td><td>Универсальное (1к10)</td></tr>
<tr><td>Двуручный меч</td><td>50 зм</td><td>2к6 рубящий</td><td>6 фнт.</td><td>Двуручное, тяжёлое</td></tr>
<tr><td><span id='weapon.rapier'>Рапира</span></td><td>25 зм</td><td>1к8 колющий</td><td>2 фнт.</td><td>Фехтовальное</td></tr>
<tr><td colspan="5"><strong><em>Воинское дальнобойное оружие</em></strong></td></tr>
<tr><td>Духовая трубка</td><td>10 зм</td><td>1 колющий</td><td>1 фнт.</td><td>Боеприпас (дис. 25/100), перезарядка</td></tr>
<tr><td>Сеть</td><td>1 зм</td><td>-</td><td>3 фнт.</td><td>Метательное (дис. 5/15), особое</td></tr>
</tbody></table>''');

final _armor = _article('''
<table><tbody>
<tr class="table_header"><td>Доспех</td><td>Стоимость</td><td>Класс доспеха (КД)</td><td>Сила</td><td>Скрытность</td><td>Вес</td></tr>
<tr><td colspan="6"><span id='armor.light'>Лёгкий доспех</span></td></tr>
<tr><td>Стёганый</td><td>5 зм.</td><td>11 + модификатор ЛОВ</td><td>-</td><td>Помеха</td><td>8 фнт.</td></tr>
<tr><td><span id='armor.leather'>Кожаный</span></td><td>10 зм.</td><td>11 + модификатор ЛОВ</td><td>-</td><td>-</td><td>10 фнт.</td></tr>
<tr><td colspan="6"><span id='armor.medium'>Средний доспех</span></td></tr>
<tr><td><span id='armor.scailmail'>Чешуйчатый</span></td><td>50 зм.</td><td>14 + модификатор ЛОВ (макс. 2)</td><td>-</td><td>Помеха</td><td>45 фнт.</td></tr>
<tr><td colspan="6"><span id='armor.heavy'>Тяжёлый доспех</span></td></tr>
<tr><td><span id='armor.chainmail'>Кольчуга</span></td><td>75 зм.</td><td>16</td><td>13</td><td>Помеха</td><td>55 фнт.</td></tr>
<tr><td>Латы</td><td>1 500 зм.</td><td>18</td><td>15</td><td>Помеха</td><td>65 фнт.</td></tr>
<tr><td colspan="6"><span id='armor.sheild'>Щиты</span></td></tr>
<tr><td>Щит</td><td>10 зм.</td><td>+2</td><td>-</td><td></td><td>6 фнт.</td></tr>
</tbody></table>''');

final _gear = _article('''
<table><tbody>
<tr class="table_header"><td>Предмет</td><td>Цена</td><td>Вес</td></tr>
<tr><td>Абак</td><td>2 зм</td><td>2 фнт.</td></tr>
<tr><td colspan="3"><em>Боеприпасы</em></td></tr>
<tr><td class="pad"><span id='equipment.arrow'>Стрелы (20)</span></td><td>1 зм</td><td>1 фнт.</td></tr>
<tr><td>Бочка</td><td>2 зм</td><td>70 фнт.</td></tr>
</tbody></table>
<table><tbody><tr class="table_header"><td>Предмет</td><td>Стоимость</td><td>Вес</td></tr>
<tr><td>Мешок</td><td>1 мм</td><td>½ фнт.</td></tr></tbody></table>
<table><tbody><tr class="table_header"><td>Контейнер</td><td>Вместимость</td></tr><tr><td>Бочка</td><td>40 галлонов</td></tr></tbody></table>
<p><strong>Набор артиста (40 зм)</strong>. Включает рюкзак, спальник, 2 костюма, 5 свечек, рационы на 5 дней, бурдюк и набор для грима.</p>
<p><strong>Набор путешественника (10 зм)</strong>. Включает рюкзак, спальник, столовый набор и бурдюк. В набор также входит 50-футовая пеньковая верёвка, закреплённая сбоку.</p>''');

final _tools = _article('''
<table><tbody>
<tr class="table_header"><td>Предмет</td><td>Стоимость</td><td>Вес</td><td>Предмет</td><td>Стоимость</td><td>Вес</td></tr>
<tr><td>Воровские инструменты</td><td>25 зм</td><td>1 фнт.</td><td colspan="3">Инструменты ремесленников</td></tr>
<tr><td colspan="3">Игровой набор</td><td>Инструменты алхимика</td><td>50 зм</td><td>8 фнт.</td></tr>
<tr><td>Кости</td><td>1 см</td><td>-</td><td>Инструменты гончара</td><td>10 зм</td><td>3 фнт.</td></tr>
<tr><td>Инструменты навигатора</td><td>25 зм</td><td>2 фнт.</td><td></td></tr>
<tr><td colspan="3">Музыкальные инструменты</td><td></td></tr>
<tr><td>Лютня</td><td>35 зм</td><td>2 фнт.</td><td></td></tr>
<tr><td>Набор для грима</td><td>25 зм</td><td>3 фнт.</td><td></td></tr>
</tbody></table>
<h2>Музыкальный инструмент [XGE]</h2><p>Владение музыкальным инструментом.</p>
<h2>Инструменты алхимика [XGE]</h2><p>Алхимики.</p>''');

const _classEquipment = '''
<div class="card__header"><h2 class="card-title">Паладин [Paladin]</h2></div>
<div class="card__body" itemprop="articleBody">
<table class="class_table"><tbody><tr class="table_header"><td>Уровень</td><td>Бонус мастерства</td><td>Умения</td></tr>
<tr><td>1</td><td>+2</td><td>-</td></tr></tbody></table>
<div class="additionalInfo"><span>
<h4 class="smallSectionTitle">ХИТЫ</h4><p><strong>Кость Хитов:</strong> 1к10</p>
<h4 class="smallSectionTitle">ВЛАДЕНИЕ</h4><p><strong>Инструменты:</strong> нет</p>
<h4 class="smallSectionTitle">СНАРЯЖЕНИЕ</h4>
<ul>
<li>а) <a href="https://dnd.su/articles/inventory/96-arms/#weapon.martial">воинское оружие</a> и <a href="/articles/inventory/95-armor_and_shields/#armor.shield">щит</a> или б) два <a href="https://dnd.su/articles/inventory/96-arms/#weapon.martial">воинских оружия</a></li>
<li>а) пять <a href="https://dnd.su/articles/inventory/96-arms/#weapon.javeline">метательных копий</a> или б) любое <a href="https://dnd.su/articles/inventory/96-arms/#weapon.simple">простое рукопашное оружие</a></li>
<li>а) <span tooltip-for="item.pack.entertainer" title="item.pack.entertainer">набор артиста</span> или б) <span tooltip-for="item.pack.explorer" title="item.pack.explorer">набор путешественника</span></li>
<li><a href="https://dnd.su/articles/inventory/95-armor_and_shields/#armor.scailmail">Кольчуга</a> и священный символ</li>
</ul>
</span></div></div>
<section class="comments-block"></section>''';

void main() {
  final parser = DndSuEquipmentParser();

  test('parses weapons with properties', () {
    final weapons = {for (final weapon in parser.parseWeapons(_weapons)) weapon.name: weapon};

    final dagger = weapons['Кинжал']!;
    expect(dagger.id, 'weapon.dagger');
    expect(dagger.kind, WeaponKind.simpleMelee);
    expect((dagger.damage, dagger.damageMultiplier, dagger.damageType), (Dice.k4, 1, DamageType.pricking));
    expect((dagger.isLight, dagger.isFencing, dagger.isThrown), (true, true, true));
    expect((dagger.minRange, dagger.maxRange), (20, 60));
    expect(dagger.cost, Balance.fromGold(2));
    expect(dagger.weight, 1);

    expect(weapons['Короткий лук']!.kind, WeaponKind.simpleRanged);
    expect(weapons['Короткий лук']!.type, WeaponType.twoHanded);
    expect(weapons['Короткий лук']!.isAmmunition, isTrue);

    final longsword = weapons['Длинный меч']!;
    expect(longsword.kind, WeaponKind.martialMelee);
    expect(longsword.type, WeaponType.universal);
    expect(longsword.twoHandedDamage, Dice.k10);

    final greatsword = weapons['Двуручный меч']!;
    expect(greatsword.id, isNull);
    expect((greatsword.damageMultiplier, greatsword.weaponWeight), (2, WeaponWeight.heavy));

    expect(weapons['Духовая трубка']!.fixedDamage, 1);
    expect(weapons['Духовая трубка']!.isLoading, isTrue);
    expect(weapons['Сеть']!.damage, isNull);
    expect(weapons['Сеть']!.isSpecial, isTrue);
    expect(Weapon.fromJson(dagger.toJson()), dagger);
  });

  test('parses armor and shields', () {
    final (armors, shields) = parser.parseArmor(_armor);
    final byName = {for (final armor in armors) armor.name: armor};

    expect(byName['Кожаный']!.kind, ArmorKind.light);
    expect(byName['Кожаный']!.dexterityLimit, isNull);
    expect(byName['Стёганый']!.stealthDisadvantage, isTrue);
    expect(byName['Чешуйчатый']!.dexterityLimit, 2);
    expect(byName['Кольчуга']!.dexterityLimit, 0);
    expect(byName['Кольчуга']!.strengthRequirement, 13);
    expect(byName['Латы']!.cost, Balance.fromGold(1500));
    expect(shields.single.defense, 2);
    expect(Armor.fromJson(byName['Кольчуга']!.toJson()), byName['Кольчуга']);
  });

  test('parses gear and packs', () {
    final (gear, packs) = parser.parseGear(_gear);

    expect(gear.map((e) => e.name), ['Абак', 'Стрелы (20)', 'Бочка', 'Мешок']);
    expect(gear[1].group, 'Боеприпасы');
    expect(gear[1].id, 'equipment.arrow');
    expect(gear[2].group, isNull);
    expect(gear[3].cost, Balance.fromCopper(1));

    expect(packs.first.name, 'Набор артиста');
    expect(packs.first.cost, Balance.fromGold(40));
    expect(packs.first.contents.last, 'Набор для грима');
    expect(packs.last.contents, ['Рюкзак', 'Спальник', 'Столовый набор', 'Бурдюк', '50-футовая пеньковая верёвка, закреплённая сбоку']);
  });

  test('parses tools from two-column table', () {
    final tools = {for (final tool in parser.parseTools(_tools)) tool.name: tool};

    expect(tools['Воровские инструменты']!.category, ToolCategory.thievesTool);
    expect(tools['Кости']!.category, ToolCategory.playSet);
    expect(tools['Инструменты навигатора']!.category, ToolCategory.navigatorTool);
    expect(tools['Лютня']!.category, ToolCategory.musicalInstrument);
    expect(tools['Лютня']!.price, Balance.fromGold(35));
    expect(tools['Лютня']!.description, contains('Владение музыкальным инструментом'));
    expect(tools['Набор для грима']!.category, ToolCategory.makeupKit);
    expect(tools['Инструменты алхимика']!.category, ToolCategory.craftsmenTool);
    expect(tools['Инструменты алхимика']!.description, contains('Алхимики'));
    expect(tools['Инструменты гончара']!.category, ToolCategory.craftsmenTool);
  });

  group('starting equipment', () {
    final (armors, shields) = parser.parseArmor(_armor);
    final (gear, packs) = parser.parseGear(_gear);
    final catalog = EquipmentCatalog(
      weapons: parser.parseWeapons(_weapons),
      armors: armors,
      shields: shields,
      gear: gear,
      packs: packs,
      tools: parser.parseTools(_tools),
    );
    final choices = DndSuClassParser().parseClass('/class/94-paladin/', _classEquipment).startingEquipment;

    test('parses options and quantities', () {
      expect(choices.map((e) => e.options.map((e) => e.text).toList()), [
        ['воинское оружие и щит', 'два воинских оружия'],
        ['пять метательных копий', 'любое простое рукопашное оружие'],
        ['набор артиста', 'набор путешественника'],
        ['Кольчуга и священный символ'],
      ]);
      final twoWeapons = choices[0].options[1].items.single;
      expect((twoWeapons.id, twoWeapons.quantity, twoWeapons.isChoice), ('weapon.martial', 2, true));
      expect(choices[1].options[0].items.single.quantity, 5);
    });

    test('resolves items despite wrong links on the site', () {
      Object? find(int choice, int option, [int item = 0]) => catalog.find(choices[choice].options[option].items[item]);

      expect(find(0, 0, 1), isA<Shield>());
      // Ссылка ведёт на weapon.javeline, а в таблице оружия — weapon.javelin.
      expect((find(1, 0)! as Weapon).name, 'Метательное копьё');
      expect((find(2, 0)! as EquipmentPack).name, 'Набор артиста');
      // Ссылка ведёт на чешуйчатый доспех, но в тексте — кольчуга.
      expect((find(3, 0)! as Armor).name, 'Кольчуга');
      expect(find(3, 0, 1), isNull, reason: 'Священного символа нет в таблицах — остаётся текстом');
    });

    test('offers category choices', () {
      List<String> names(int choice, int option) =>
          catalog.choicesFor(choices[choice].options[option].items.first).map(EquipmentCatalog.nameOf).toList();

      expect(names(0, 1), ['Длинный меч', 'Двуручный меч', 'Рапира', 'Духовая трубка', 'Сеть']);
      expect(names(1, 1), ['Кинжал', 'Метательное копьё']);
      expect(
        catalog.choicesFor(const EquipmentRef(id: 'tools.music', text: 'любой музыкальный инструмент', isChoice: true))
            .map(EquipmentCatalog.nameOf),
        ['Лютня'],
      );
    });
  });

  test('catalog survives json roundtrip', () {
    final (armors, shields) = parser.parseArmor(_armor);
    final (gear, packs) = parser.parseGear(_gear);
    final catalog = EquipmentCatalog(
      weapons: parser.parseWeapons(_weapons),
      armors: armors,
      shields: shields,
      gear: gear,
      packs: packs,
      tools: [Tool(category: ToolCategory.musicalInstrument, name: 'Лютня', description: '', price: Balance.fromGold(35))],
    );

    expect(EquipmentCatalog.fromJson(catalog.toJson()).toJson(), catalog.toJson());
  });
}
