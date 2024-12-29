import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/tools/makeup_kits.dart';

final diplomaSet = EquipmentKit(
  name: 'Набор дипломата',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Cундук',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Контейнер для карт и свитков',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Комплект отличной одежды',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бутылка чернил',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Писчее перо',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Лампа',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Фляга масла',
    ),
    InventoryItem(
      quantity: 5,
      item: 'Листов бумаги',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Флакон духов',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Воск',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Мыло',
    ),
  ],
);

final artistSet = EquipmentKit(
  name: 'Набор артиста',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Спальник',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Костюм',
    ),
    InventoryItem(
      quantity: 5,
      item: 'Свечка',
    ),
    InventoryItem(
      quantity: 5,
      item: 'Рацион',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бурдюк',
    ),
    InventoryItem(
      quantity: 1,
      item: makeupKits.first,
    ),
  ],
);

final bulgartSet = EquipmentKit(
  name: 'Набор взломщика',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Сумка с 1000 металлических шариков',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Леска (1 фут)',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Колокольчик',
    ),
    InventoryItem(
      quantity: 5,
      item: 'Свеча',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Ломик',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Молоток',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Шлямбур',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Закрытый фонарь',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Фляга',
    ),
    InventoryItem(
      quantity: 5,
      item: 'Рацион',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Трутница',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бурдюк',
    ),
    InventoryItem(
      quantity: 50,
      item: 'Пеньковая верёвка (1 фут)',
    ),
  ],
);

final dungeonExplorerSet = EquipmentKit(
  name: 'Набор исследователя подземелий',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Ломик',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Молоток',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Шлямбур',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Трутница',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Рацион',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бурдюк',
    ),
    InventoryItem(
      quantity: 50,
      item: 'Пеньковая верёвка (1 фут)',
    ),
  ],
);

final travellersSet = EquipmentKit(
  name: 'Набор путешественника',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Спальник',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Столовый набор',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Факел',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Трутница',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Рацион',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бурдюк',
    ),
    InventoryItem(
      quantity: 50,
      item: 'Пеньковая верёвка (1 фут)',
    ),
  ],
);

final priestSet = EquipmentKit(
  name: 'Набор священника',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Одеяло',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Свеча',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Трутница',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Рацион',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Коробка для пожертвований',
    ),
    InventoryItem(
      quantity: 2,
      item: 'Упаковка благовоний',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Кадило',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Облачение',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бурдюк',
    ),
  ],
);

final scientistSet = EquipmentKit(
  name: 'Набор учёного',
  items: [
    InventoryItem(
      quantity: 1,
      item: 'Рюкзак',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Научная книга',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Одеяло',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Бутылочка чернил',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Писчее перо',
    ),
    InventoryItem(
      quantity: 10,
      item: 'Лист пергамента',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Небольшая сумочка с песком',
    ),
    InventoryItem(
      quantity: 1,
      item: 'Небольшой нож',
    ),
  ],
);
