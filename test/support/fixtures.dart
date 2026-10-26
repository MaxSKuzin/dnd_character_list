import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';

// Персонаж и предметы для тестов, с характеристиками из «Книги игрока».
final rapierFixture = Weapon(
  id: '/weapons/rapier',
  name: 'Рапира',
  damage: Dice.k8,
  damageType: DamageType.pricking,
  kind: WeaponKind.martialMelee,
  type: WeaponType.oneHanded,
  isFencing: true,
);
final daggerFixture = Weapon(
  id: '/weapons/dagger',
  name: 'Кинжал',
  damage: Dice.k4,
  damageType: DamageType.pricking,
  kind: WeaponKind.simpleMelee,
  type: WeaponType.oneHanded,
  weaponWeight: WeaponWeight.light,
  isFencing: true,
  isThrown: true,
  minRange: 20,
  maxRange: 60,
);
final longswordFixture = Weapon(
  id: '/weapons/longsword',
  name: 'Длинный меч',
  damage: Dice.k8,
  twoHandedDamage: Dice.k10,
  damageType: DamageType.chopping,
  kind: WeaponKind.martialMelee,
  type: WeaponType.universal,
);
final greatswordFixture = Weapon(
  name: 'Двуручный меч',
  damage: Dice.k6,
  damageMultiplier: 2,
  damageType: DamageType.chopping,
  kind: WeaponKind.martialMelee,
  type: WeaponType.twoHanded,
  weaponWeight: WeaponWeight.heavy,
);
const leatherFixture = Armor(name: 'Кожаный', kind: ArmorKind.light, protection: 11, dexterityLimit: null, weight: 10);
const scaleFixture = Armor(name: 'Чешуйчатый', kind: ArmorKind.medium, protection: 14, dexterityLimit: 2, weight: 45);
const chainmailFixture = Armor(
  name: 'Кольчуга',
  kind: ArmorKind.heavy,
  protection: 16,
  dexterityLimit: 0,
  strengthRequirement: 13,
  stealthDisadvantage: true,
  weight: 55,
);
const shieldFixture = Shield(name: 'Щит', defense: 2, weight: 6);

Player playerFixture({
  Specialization? spec,
  int dexterity = 16,
  List<InventoryItem>? items,
}) =>
    Player(
      knownLanguages: const [],
      personality: Personality(
        name: 'Тест',
        age: 20,
        height: 170,
        weight: 60,
        story: '',
      ),
      race: Race.tiefling,
      strength: 8,
      dexterity: dexterity,
      constitution: 14,
      intelligence: 10,
      wisdom: 10,
      charisma: 15,
      classes: [
        spec ?? Bard(level: 1, isMain: true, knownSpells: const [], features: const [], inspirationDice: Dice.k6)
      ],
      chosenSkills: const [],
      armor: null,
      shield: null,
      mainWeapon: null,
      secondWeapon: null,
      mainRangeWeapon: null,
      secondRangeWeapon: null,
      inventory: Inventory(
        items: items ??
            [
              InventoryItem(quantity: 1, item: rapierFixture),
              InventoryItem(quantity: 2, item: daggerFixture),
              InventoryItem(quantity: 1, item: longswordFixture),
              InventoryItem(quantity: 1, item: greatswordFixture),
              InventoryItem(quantity: 1, item: leatherFixture),
              InventoryItem(quantity: 1, item: scaleFixture),
              InventoryItem(quantity: 1, item: chainmailFixture),
              InventoryItem(quantity: 1, item: shieldFixture),
            ],
        balance: const Balance(0),
      ),
      background: const Background(
        id: 1,
        link: '',
        name: 'Артист',
        nameEn: 'Entertainer',
        descriptionHtml: '',
        skills: [],
        tools: [],
        languagesCount: 0,
        equipment: [],
        gold: 0,
        featureName: null,
        featureHtml: null,
        tables: [],
      ),
      raceSpells: const {},
    );
