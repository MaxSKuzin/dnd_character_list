import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class CreateWeaponSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateWeaponSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateWeaponSection> createState() => _CreateWeaponSectionState();
}

class _CreateWeaponSectionState extends State<CreateWeaponSection> with CreateItemPresenter<Weapon> {
  final _nameController = TextEditingController(text: 'Оружие');
  final _damageNotifier = ValueNotifier<Dice>(Dice.k4);
  final _damageTypeNotifier = ValueNotifier<DamageType>(DamageType.pricking);
  final _kindNotifier = ValueNotifier<WeaponKind>(WeaponKind.simpleMelee);
  final _typeNotifier = ValueNotifier<WeaponType>(WeaponType.oneHanded);
  final _damageMultiplierController = TextEditingController(text: '1');
  final _fixedDamageController = TextEditingController();
  final _isFencingNotifier = ValueNotifier<bool>(false);
  final _maxRangeController = TextEditingController();
  final _minRangeController = TextEditingController();
  final _twoHandedDamageController = ValueNotifier<Dice>(Dice.k4);
  final _weaponWeightNotifier = ValueNotifier<WeaponWeight>(WeaponWeight.light);
  final _elementalDamageNotifier = ValueNotifier<List<ElementalDamage>>([]);

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _damageNotifier.dispose();
    _damageTypeNotifier.dispose();
    _kindNotifier.dispose();
    _typeNotifier.dispose();
    _damageMultiplierController.dispose();
    _fixedDamageController.dispose();
    _isFencingNotifier.dispose();
    _maxRangeController.dispose();
    _minRangeController.dispose();
    _twoHandedDamageController.dispose();
    _weaponWeightNotifier.dispose();
    _elementalDamageNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          Row(
            children: [
              const Text('Фехтовальное'),
              ValueListenableBuilder(
                valueListenable: _isFencingNotifier,
                builder: (context, value, child) => Checkbox(
                  value: value,
                  onChanged: (value) => _isFencingNotifier.value = value ?? false,
                ),
              ),
            ],
          ),
          const Text(
            'Урон',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _damageNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: Dice.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _damageNotifier.value = e,
                          child: Chip(
                            label: Text(e.name),
                            color: WidgetStatePropertyAll(
                              value == e ? context.customColors?.cardColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          TextField(
            controller: _damageMultiplierController,
            decoration: const InputDecoration(labelText: 'Множитель урона'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _fixedDamageController,
            decoration: const InputDecoration(labelText: 'Бонус урона'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          ValueListenableBuilder(
            valueListenable: _elementalDamageNotifier,
            builder: (context, value, child) => Column(
              children: [
                const Text('Элементальный урон'),
                ...value.mapIndexed(
                  (index, item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.customColors?.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Множитель урона',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final oldList = [...value];
                                      oldList[index] = ElementalDamage(
                                        count: max(item.count - 1, 1),
                                        type: item.type,
                                        damage: item.damage,
                                      );
                                      _elementalDamageNotifier.value = oldList;
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    item.count.toString(),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final oldList = [...value];
                                      oldList[index] = ElementalDamage(
                                        count: item.count + 1,
                                        type: item.type,
                                        damage: item.damage,
                                      );
                                      _elementalDamageNotifier.value = oldList;
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                              const Gap(16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: ElementalType.values
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              final oldList = [...value];
                                              oldList[index] = ElementalDamage(
                                                count: item.count,
                                                type: e,
                                                damage: item.damage,
                                              );
                                              _elementalDamageNotifier.value = oldList;
                                            },
                                            child: Chip(
                                              label: Text(e.name),
                                              color: WidgetStatePropertyAll(
                                                item.type == e ? context.customColors?.cardColor : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const Gap(16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: Dice.values
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              final oldList = [...value];
                                              oldList[index] = ElementalDamage(
                                                count: item.count,
                                                type: item.type,
                                                damage: e,
                                              );
                                              _elementalDamageNotifier.value = oldList;
                                            },
                                            child: Chip(
                                              label: Text(e.name),
                                              color: WidgetStatePropertyAll(
                                                item.damage == e ? context.customColors?.cardColor : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                final oldList = [...value];
                                oldList.removeAt(index);
                                _elementalDamageNotifier.value = oldList;
                              },
                              icon: const Icon(Icons.close),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    _elementalDamageNotifier.value = [
                      ...value,
                      ElementalDamage(
                        count: 1,
                        type: ElementalType.fire,
                        damage: Dice.k4,
                      ),
                    ];
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _typeNotifier,
            builder: (context, value, child) => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: value == WeaponType.universal
                  ? Column(
                      children: [
                        const Gap(16),
                        const Text('Урон в двух руках'),
                        ValueListenableBuilder(
                          valueListenable: _twoHandedDamageController,
                          builder: (context, value, child) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: Dice.values
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: GestureDetector(
                                        onTap: () => _twoHandedDamageController.value = e,
                                        child: Chip(
                                          label: Text(e.name),
                                          color: WidgetStatePropertyAll(
                                            value == e ? context.customColors?.cardColor : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
          const Gap(16),
          const Text(
            'Тип урона',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _damageTypeNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: DamageType.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _damageTypeNotifier.value = e,
                          child: Chip(
                            label: Text(e.name),
                            color: WidgetStatePropertyAll(
                              value == e ? context.customColors?.cardColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          const Text(
            'Вид оружия',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _kindNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: WeaponKind.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _kindNotifier.value = e,
                          child: Chip(
                            label: Text(e.name),
                            color: WidgetStatePropertyAll(
                              value == e ? context.customColors?.cardColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          const Text(
            'Хват оружия',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _typeNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: WeaponType.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _typeNotifier.value = e,
                          child: Chip(
                            label: Text(e.name),
                            color: WidgetStatePropertyAll(
                              value == e ? context.customColors?.cardColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          const Text(
            'Вес оружия',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _weaponWeightNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: WeaponWeight.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _weaponWeightNotifier.value = e,
                          child: Chip(
                            label: Text(e.name),
                            color: WidgetStatePropertyAll(
                              value == e ? context.customColors?.cardColor : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Gap(16),
          const Text('(Для метательного и стрелкового оружия)'),
          TextField(
            controller: _minRangeController,
            decoration: const InputDecoration(labelText: 'Минимальная дистанция'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          const Text('(Для метательного и стрелкового оружия)'),
          TextField(
            controller: _maxRangeController,
            decoration: const InputDecoration(labelText: 'Максимальная дистанция'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }

  @override
  Weapon createItem() {
    return Weapon(
      name: _nameController.text,
      damage: _damageNotifier.value,
      damageType: _damageTypeNotifier.value,
      kind: _kindNotifier.value,
      type: _typeNotifier.value,
      damageMultiplier: int.tryParse(_damageMultiplierController.text) ?? 1,
      fixedDamage: int.tryParse(_fixedDamageController.text) ?? 0,
      isFencing: _isFencingNotifier.value,
      maxRange: int.tryParse(_maxRangeController.text),
      minRange: int.tryParse(_minRangeController.text),
      twoHandedDamage: _typeNotifier.value == WeaponType.universal ? _twoHandedDamageController.value : null,
      weaponWeight: _weaponWeightNotifier.value,
      elementalDamage: _elementalDamageNotifier.value.toList(),
    );
  }
}
