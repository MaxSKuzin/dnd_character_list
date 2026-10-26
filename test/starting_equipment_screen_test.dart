import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_equipment_mapper.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/starting_equipment_screen/starting_equipment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/ttg_fixtures.dart';

void main() {
  testWidgets('fighter picks martial weapons and they go to inventory', (tester) async {
    final info = TtgClassMapper().map(ttgFixture('class_fighter'));
    final longbow = TtgEquipmentMapper().weapon('/weapons/longbow', ttgFixture('weapon_longbow'));
    final catalog = EquipmentCatalog(
      weapons: [longswordFixture, longbow, daggerFixture],
      armors: const [],
      shields: const [shieldFixture],
      gear: const [],
      packs: const [],
      tools: const [],
    );
    List<InventoryItem>? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: StartingEquipmentScreen(
          title: 'Снаряжение',
          // Только строка «а) воинское оружие и щит или б) два воинских оружия».
          choices: [info.startingEquipment[1]],
          catalog: catalog,
          onSelected: (items) => selected = items,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Два воинских оружия'));
    await tester.pumpAndSettle();
    final pickers = find.byType(DropdownButtonFormField<Object>);
    expect(pickers, findsNWidgets(2));

    // В списке только воинское оружие: кинжала (простое) нет.
    await tester.tap(pickers.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Кинжал'), findsNothing);
    await tester.tap(find.textContaining('Длинный меч').last);
    await tester.pumpAndSettle();
    await tester.tap(pickers.last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Длинный лук').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Далее'));
    expect(selected!.map((e) => (e.item, e.quantity)), [(longswordFixture, 1), (longbow, 1)]);
  });
}
