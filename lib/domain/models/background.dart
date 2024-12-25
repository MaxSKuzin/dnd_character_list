import 'package:dnd_character_list/domain/models/background_equipment.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/tools/craftsmen_tools.dart';
import 'package:dnd_character_list/domain/models/tools/fold_of_lawn.dart';
import 'package:dnd_character_list/domain/models/tools/makeup_kits.dart';
import 'package:dnd_character_list/domain/models/tools/musical_instruments.dart';
import 'package:dnd_character_list/domain/models/tools/play_sets.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

enum Background {
  entertainer,
  urchin,
  noble,
  guildArtisan,
  sailor,
  sage,
  folkHero,
  hermit,
  pirate,
  criminal,
  acolyte,
  soldier,
  outlander,
  charlatan;

  String get name => switch (this) {
        Background.entertainer => 'Артист',
        Background.urchin => 'Беспризорник',
        Background.noble => 'Благородный',
        Background.guildArtisan => 'Гильдейский ремесленник',
        Background.sailor => 'Моряк',
        Background.sage => 'Мудрец',
        Background.folkHero => 'Народный герой',
        Background.hermit => 'Отшельник',
        Background.pirate => 'Пират',
        Background.criminal => 'Преступник',
        Background.acolyte => 'Прислужник',
        Background.soldier => 'Солдат',
        Background.outlander => 'Чужеземец',
        Background.charlatan => 'Шарлатан',
      };

  List<Skill> get skills => switch (this) {
        Background.entertainer => [Skill.acrobatics, Skill.performance],
        Background.urchin => [Skill.manualDexterity, Skill.stealth],
        Background.noble => [Skill.history, Skill.conviction],
        Background.guildArtisan => [Skill.insight, Skill.conviction],
        Background.sailor => [Skill.athletics, Skill.perception],
        Background.sage => [Skill.magic, Skill.history],
        Background.folkHero => [Skill.animalTaming, Skill.surviving],
        Background.hermit => [Skill.medicine, Skill.religion],
        Background.pirate => [Skill.athletics, Skill.perception],
        Background.criminal => [Skill.fraud, Skill.stealth],
        Background.acolyte => [Skill.insight, Skill.religion],
        Background.soldier => [Skill.athletics, Skill.harassment],
        Background.outlander => [Skill.athletics, Skill.surviving],
        Background.charlatan => [Skill.fraud, Skill.manualDexterity],
      };

  Balance get balance => switch (this) {
        Background.entertainer => Balance.fromGold(15),
        Background.urchin => Balance.fromGold(10),
        Background.noble => Balance.fromGold(25),
        Background.guildArtisan => Balance.fromGold(15),
        Background.sailor => Balance.fromGold(10),
        Background.sage => Balance.fromGold(10),
        Background.folkHero => Balance.fromGold(10),
        Background.hermit => Balance.fromGold(5),
        Background.pirate => Balance.fromGold(10),
        Background.criminal => Balance.fromGold(15),
        Background.acolyte => Balance.fromGold(15),
        Background.soldier => Balance.fromGold(10),
        Background.outlander => Balance.fromGold(10),
        Background.charlatan => Balance.fromGold(15),
      };

  List<ToolCategory> get masteryOfTools => switch (this) {
        Background.entertainer => [ToolCategory.makeupKit, ToolCategory.musicalInstrument],
        Background.urchin => [ToolCategory.thievesTool, ToolCategory.makeupKit],
        Background.noble => [ToolCategory.playSet],
        Background.guildArtisan => [ToolCategory.craftsmenTool],
        Background.sailor => [ToolCategory.navigatorTool],
        Background.sage => [],
        Background.folkHero => [ToolCategory.craftsmenTool],
        Background.hermit => [ToolCategory.foldOfLawn],
        Background.pirate => [ToolCategory.navigatorTool],
        Background.criminal => [ToolCategory.thievesTool, ToolCategory.playSet],
        Background.acolyte => [],
        Background.soldier => [ToolCategory.playSet],
        Background.outlander => [ToolCategory.musicalInstrument],
        Background.charlatan => [ToolCategory.makeupKit, ToolCategory.falsificationKit],
      };

  int get additionalLangauges => switch (this) {
        Background.entertainer => 0,
        Background.urchin => 0,
        Background.noble => 1,
        Background.guildArtisan => 1,
        Background.sailor => 0,
        Background.sage => 2,
        Background.folkHero => 0,
        Background.hermit => 1,
        Background.pirate => 0,
        Background.criminal => 0,
        Background.acolyte => 2,
        Background.soldier => 0,
        Background.outlander => 1,
        Background.charlatan => 0,
      };

  BackgroundEquipment get startEquipment => switch (this) {
        Background.entertainer => BackgroundEquipment(
            availableTools: musicalInstruments,
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Костюм',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Любовное письмо',
              ),
            ],
          ),
        Background.urchin => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Маленький нож',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Карта города в котором вы выросли',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Ручная мышь',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Безделушка в память о родителях',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.noble => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Комплект отличной одежды',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Кольцо печатка',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Свиток с генеалогическом древом',
              ),
            ],
          ),
        Background.guildArtisan => BackgroundEquipment(
            availableTools: craftsmenTools,
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Рекомендательное письмо из гильдии',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комлект дорожной одежды',
              ),
            ],
          ),
        Background.sailor => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Кофель-нагель (дубинка)',
              ),
              InventoryItem(
                quantity: 50,
                item: 'Шёлковая верёвка (фут)',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Талисман',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.sage => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Бутылочка чернил',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Писчее перо',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Небольшой нож',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Письмо от мертвого коллеги',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.folkHero => BackgroundEquipment(
            availableTools: craftsmenTools,
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Лопата',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Железный горшок',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.hermit => BackgroundEquipment(
            availableTools: foldOfLawnTools,
            additionalItems: [
              InventoryItem(
                quantity: 1,
                item: 'Контейнер для свитков с молитвами',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Тёплое одеяло',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.pirate => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Кофель-нагель (дубинка)',
              ),
              InventoryItem(
                quantity: 50,
                item: 'Шёлковая верёвка (фут)',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Талисман',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.criminal => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Ломик',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект тёмной одежды с капюшоном',
              ),
            ],
          ),
        Background.acolyte => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Священный символ',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Молитвенник',
              ),
              InventoryItem(
                quantity: 5,
                item: 'Палочка благовоний',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Ряса',
              ),
              InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.soldier => BackgroundEquipment(
            availableTools: playSets,
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Знак отличия',
              ),
             InventoryItem(
                quantity: 1,
                item: 'Трофей с убитого врага',
              ),
             InventoryItem(
                quantity: 1,
                item: 'Комплект обычной одежды',
              ),
            ],
          ),
        Background.outlander => BackgroundEquipment(
            availableTools: [],
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Посох',
              ),
             InventoryItem(
                quantity: 1,
                item: 'Капкан',
              ),
             InventoryItem(
                quantity: 1,
                item: 'Трофей с убитого животного',
              ),
             InventoryItem(
                quantity: 1,
                item: 'Комплект дорожной одежды',
              ),
            ],
          ),
        Background.charlatan => BackgroundEquipment(
            availableTools: makeupKits,
            additionalItems: [
             InventoryItem(
                quantity: 1,
                item: 'Комплект отличной одежды',
              ),
             InventoryItem(
                quantity: 10,
                item: 'Запечатанный бутыль с подкрашенной жидкостью',
              ),
            ],
          ),
      };
}
