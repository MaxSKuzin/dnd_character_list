import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectWeaponsScreen extends StatefulWidget {
  final StartEquipment startEquip;

  const SelectWeaponsScreen({
    super.key,
    required this.startEquip,
  });

  @override
  State<SelectWeaponsScreen> createState() => _SelectWeaponsScreenState();
}

class _SelectWeaponsScreenState extends State<SelectWeaponsScreen> {
  late final _selectedItems = widget.startEquip.items
      .mapIndexed(
        (index, e) => MapEntry(index, e.quantity == e.items.length ? [...e.items] : <InventoryItem>[]),
      )
      .toList();
  EquipmentKit? _selectedKit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < _selectedItems.length; i++)
                  Column(
                    children: [
                      Text(
                        'Выберите ${widget.startEquip.items[i].quantity} предмет',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      ...[
                        for (int j = 0; j < widget.startEquip.items[i].items.length; j++) ...[
                          EquipmentWidget(
                            widget.startEquip.items[i].items[j],
                            isSelected: _selectedItems[i].value.contains(widget.startEquip.items[i].items[j]),
                            onTap: (isSelected, item) {
                              final items = _selectedItems[i].value;
                              if (isSelected) {
                                items.remove(item);
                              } else {
                                if (items.length >= widget.startEquip.items[i].quantity) {
                                  items.removeAt(0);
                                }
                                items.add(item);
                              }
                              setState(() {});
                            },
                          ),
                          const Gap(8),
                        ],
                      ],
                      const Gap(16),
                    ],
                  ),
                for (final kit in widget.startEquip.kits) ...[
                  EquipmentKitWidget(
                    kit: kit,
                    isSelected: _selectedKit == kit,
                    onTap: (isSelected) {
                      if (isSelected) {
                        _selectedKit = null;
                      } else {
                        _selectedKit = kit;
                      }
                      setState(() {});
                    },
                  ),
                  const Gap(8),
                ],
                const Gap(16),
                OutlinedButton(
                  onPressed: _selectedKit != null &&
                          _selectedItems.fold(
                            (true),
                            (prev, el) => prev && widget.startEquip.items[el.key].quantity == el.value.length,
                          )
                      ? () {
                          final items = [
                            ..._selectedItems.expand((e) => e.value),
                            ..._selectedKit!.items,
                          ];
                          context.read<CreateCharacterCubit>().setInventoryItems(items);
                          final newLanguagesCount =
                              context.read<CreateCharacterCubit>().race!.additionalLanguagesCount +
                                  context.read<CreateCharacterCubit>().background!.additionalLangauges;
                          if (newLanguagesCount > 0) {
                            context.pushRoute(
                              SelectLanguagesRoute(
                                knownLanguages: context.read<CreateCharacterCubit>().race!.knownLanguages,
                                maxLanguages: newLanguagesCount,
                              ),
                            );
                          } else {
                            context.pushRoute(const SetPersonalityRoute());
                          }
                        }
                      : null,
                  child: const Text('Далее'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EquipmentWidget extends StatelessWidget {
  final InventoryItem inventoryItem;
  final bool isSelected;
  final Function(bool isSelected, InventoryItem item) onTap;

  const EquipmentWidget(
    this.inventoryItem, {
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final item = inventoryItem.item;
    Widget child;
    child = switch (item) {
      Weapon item => WeaponWidget(
          weapon: item,
        ),
      Armor item => LabeledBorder(
          text: 'ДОСПЕХ',
          backgroundColor: context.customColors?.cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      Shield item => Row(
          children: [
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'Имя',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'Защита',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(
                      '+${item.defense}',
                    ),
                  ),
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'Вес',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Center(
                    child: Text(item.weight.toString()),
                  ),
                ),
              ),
            ),
          ],
        ),
      CustomInvetoryItem item => GestureDetector(
          onLongPress: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                child: TextParses(item.description),
              ),
            ),
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: context.customColors?.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: Text(
              item.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      Tool item => Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: context.customColors?.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white,
            ),
          ),
          child: Text(
            item.name,
          ),
        ),
      _ => Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: context.customColors?.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white,
            ),
          ),
          child: Text(
            item.toString(),
          ),
        ),
    };
    if (inventoryItem.quantity > 1) {
      child = Row(
        children: [
          Expanded(child: child),
          const Gap(8),
          Text('x${inventoryItem.quantity}'),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(isSelected, inventoryItem),
      child: ImageFiltered(
        imageFilter: ColorFilter.mode(
          isSelected ? Colors.transparent : Colors.black45,
          BlendMode.srcATop,
        ),
        child: child,
      ),
    );
  }
}

class WeaponWidget extends StatelessWidget {
  final Weapon weapon;

  const WeaponWidget({
    super.key,
    required this.weapon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => WeaponInfoDialog.show(context, weapon: weapon),
      child: Row(
        children: [
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.customColors?.cardColor,
              text: weapon.type.name,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    weapon.name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.customColors?.cardColor,
              text: '1${Dice.k20.name}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    weapon.isFencing ? StatKind.dexterity.name : StatKind.strength.name,
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.customColors?.cardColor,
              text: weapon.damageType.name.toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(weapon.getRawDamageString()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EquipmentKitWidget extends StatelessWidget {
  final EquipmentKit kit;
  final bool isSelected;
  final Function(bool isSelected) onTap;

  const EquipmentKitWidget({
    super.key,
    required this.kit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(isSelected),
      child: ImageFiltered(
        imageFilter: ColorFilter.mode(
          isSelected ? Colors.transparent : Colors.black45,
          BlendMode.srcATop,
        ),
        child: GestureDetector(
          onLongPress: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                child: TextParses(kit.description),
              ),
            ),
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: context.customColors?.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: Text(
              kit.name,
            ),
          ),
        ),
      ),
    );
  }
}
