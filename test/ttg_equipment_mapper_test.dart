import 'package:dnd_character_list/data/ttg/ttg_equipment_mapper.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

void main() {
  final mapper = TtgEquipmentMapper();

  test('maps weapons with properties', () {
    final dagger = mapper.weapon('/weapons/dagger', ttgFixture('weapon_dagger'));
    expect(dagger.id, '/weapons/dagger');
    expect(dagger.name, 'Кинжал');
    expect((dagger.damage, dagger.damageMultiplier, dagger.damageType), (Dice.k4, 1, DamageType.pricking));
    expect(dagger.kind, WeaponKind.simpleMelee);
    expect(dagger.weaponWeight, WeaponWeight.light);
    expect((dagger.isFencing, dagger.isThrown, dagger.minRange, dagger.maxRange), (true, true, 20, 60));
    expect(dagger.cost, Balance.fromGold(2));

    final staff = mapper.weapon('/weapons/quarterstaff', ttgFixture('weapon_quarterstaff'));
    expect((staff.type, staff.twoHandedDamage), (WeaponType.universal, Dice.k8));
    expect(staff.cost, Balance.fromSilver(2));

    final longbow = mapper.weapon('/weapons/longbow', ttgFixture('weapon_longbow'));
    expect(longbow.kind, WeaponKind.martialRanged);
    expect(
        (longbow.type, longbow.weaponWeight, longbow.isAmmunition), (WeaponType.twoHanded, WeaponWeight.heavy, true));

    // Фиксированный урон и оружие без урона.
    final blowgun = mapper.weapon('/weapons/blowgun', ttgFixture('weapon_blowgun'));
    expect(blowgun.getRawDamageString(), '1');
    final net = mapper.weapon('/weapons/net', ttgFixture('weapon_net'));
    expect((net.damage, net.damageType, net.isSpecial), (null, null, true));
  });

  test('maps armor and shield', () {
    final hide = mapper.armor('/armors/hide_armor', ttgFixture('armor_hide')) as Armor;
    expect((hide.kind, hide.protection, hide.dexterityLimit), (ArmorKind.medium, 12, 2));

    final plate = mapper.armor('/armors/plate_armor', ttgFixture('armor_plate')) as Armor;
    expect((plate.kind, plate.protection, plate.dexterityLimit), (ArmorKind.heavy, 18, 0));
    expect((plate.strengthRequirement, plate.stealthDisadvantage, plate.weight), (15, true, 65));
    expect(plate.cost, Balance.fromGold(1500));

    final shield = mapper.armor('/armors/shield', ttgFixture('armor_shield')) as Shield;
    expect((shield.name, shield.defense), ('Щит', 2));
  });

  test('maps pack contents and tools', () {
    final pack = mapper.pack("/items/explorer's_pack", ttgFixture('item_explorers_pack'));
    expect(pack.name, 'Набор путешественника');
    expect(pack.cost, Balance.fromGold(10));
    expect(pack.contents.map((e) => (e.id, e.quantity)), [
      ('/items/backpack', 1),
      ('/items/bedroll', 1),
      ('/items/mess_kit', 1),
      ('/items/tinderbox', 1),
      ('/items/torch', 10),
      ('/items/rations_(1_day)', 10),
      ('/items/waterskin', 1),
      ('/items/hempen_rope', 1),
    ]);
    expect(pack.contents[4].text, '10 факелов');
    expect(pack.contents[5].text, 'Рационы на 10 дней');
    expect(pack.contents.last.text, '50-футовая пеньковая верёвка, закреплённая сбоку');

    expect(TtgEquipmentMapper.toolCategory("/items/Thieves’_Tools", 'TOOL'), ToolCategory.thievesTool);
    expect(TtgEquipmentMapper.toolCategory('/items/lute', 'MUSICAL_INSTRUMENTS'), ToolCategory.musicalInstrument);
    expect(TtgEquipmentMapper.toolCategory('/items/backpack', 'CONTAINER'), isNull);
    final tool = mapper.tool(ttgFixture('item_thieves_tools'), ToolCategory.thievesTool);
    expect((tool.name, tool.price), ('Воровские инструменты', Balance.fromGold(25)));
  });

  test('catalog finds starting equipment by link and offers choices', () {
    final catalog = EquipmentCatalog(
      weapons: [
        mapper.weapon('/weapons/dagger', ttgFixture('weapon_dagger')),
        mapper.weapon('/weapons/longbow', ttgFixture('weapon_longbow')),
      ],
      armors: const [],
      shields: const [],
      gear: [
        mapper.gear({
          'name': {'rus': 'Жезл', 'eng': 'Rod'},
          'url': '/items/rod',
        }, group: 'Магическая фокусировка'),
        mapper.gear({
          'name': {'rus': 'Рюкзак', 'eng': 'Backpack'},
          'url': '/items/backpack',
        }),
      ],
      packs: const [],
      tools: const [],
    );

    // Название в ссылке в другом падеже, поэтому предмет находится по ссылке.
    final dagger = catalog.find(const EquipmentRef(id: '/weapons/dagger', text: 'Два кинжала', quantity: 2));
    expect(EquipmentCatalog.nameOf(dagger!), 'Кинжал');
    expect(
      catalog
          .choicesFor(const EquipmentRef(id: null, text: 'любое простое оружие', isChoice: true))
          .map(EquipmentCatalog.nameOf),
      ['Кинжал'],
    );
    expect(
      catalog
          .choicesFor(const EquipmentRef(id: null, text: 'магическая фокусировка', isChoice: true))
          .map(EquipmentCatalog.nameOf),
      ['Жезл'],
    );
  });

  test('pack is unpacked into countable items', () {
    Gear gear(String name, String url) => mapper.gear({
          'name': {'rus': name, 'eng': name},
          'url': url,
        });
    final catalog = EquipmentCatalog(
      weapons: const [],
      armors: const [],
      shields: const [],
      gear: [gear('Факел', '/items/torch'), gear('Рационы (1 день)', '/items/rations_(1_day)')],
      packs: const [],
      tools: const [],
    );
    const pack = EquipmentPack(
      name: 'Набор',
      contents: [
        EquipmentRef(id: '/items/torch', text: '10 факелов', quantity: 10),
        EquipmentRef(id: '/items/rations_(1_day)', text: 'Рационы на 5 дней', quantity: 5),
        EquipmentRef(id: null, text: '2 упаковки благовоний', quantity: 2),
        EquipmentRef(id: null, text: '10 футов лески'),
      ],
    );

    final items = catalog.inventoryItems(pack);
    expect(items.map((e) => (ItemTexts.name(e.item), e.quantity)), [
      ('Факел', 10),
      ('Рационы (1 день)', 5),
      ('Упаковки благовоний', 2),
      ('10 футов лески', 1),
    ]);

    // Вещи двух наборов складываются, количество меняется и обнуляется.
    var inventory = Inventory(items: [], balance: const Balance(0));
    for (final item in [...items, ...catalog.inventoryItems(pack)]) {
      inventory = inventory.addItem(item);
    }
    final torches = inventory.items.firstWhere((e) => e.item == catalog.gear.first);
    expect(torches.quantity, 20);
    inventory = inventory.setItemQuantity(torches, 7);
    expect(inventory.items.firstWhere((e) => e.item == catalog.gear.first).quantity, 7);
    inventory = inventory.setItemQuantity(inventory.items.firstWhere((e) => e.item == catalog.gear.first), 0);
    expect(inventory.items.any((e) => e.item == catalog.gear.first), isFalse);
  });
}
