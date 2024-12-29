import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class CreateArmorSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateArmorSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateArmorSection> createState() => _CreateArmorSectionState();
}

class _CreateArmorSectionState extends State<CreateArmorSection> with CreateItemPresenter<Armor> {
  final _nameController = TextEditingController(text: 'Броня');
  final _kingNotifier = ValueNotifier<ArmorKind>(ArmorKind.light);
  final _stealthDisadvantageNotifier = ValueNotifier<bool>(false);
  final _weightController = TextEditingController(text: '15');
  final _dexterityLimitController = TextEditingController();
  final _protectionController = TextEditingController(text: '11');

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kingNotifier.dispose();
    _stealthDisadvantageNotifier.dispose();
    _weightController.dispose();
    _dexterityLimitController.dispose();
    _protectionController.dispose();

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
              const Text('Помеха при скрытности'),
              ValueListenableBuilder(
                valueListenable: _stealthDisadvantageNotifier,
                builder: (context, value, child) => Checkbox(
                  value: value,
                  onChanged: (value) => _stealthDisadvantageNotifier.value = value ?? false,
                ),
              ),
            ],
          ),
          const Text(
            'Тип',
            textAlign: TextAlign.center,
          ),
          ValueListenableBuilder(
            valueListenable: _kingNotifier,
            builder: (context, value, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ArmorKind.values
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () => _kingNotifier.value = e,
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
            controller: _protectionController,
            decoration: const InputDecoration(labelText: 'Защита'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Вес'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _dexterityLimitController,
            decoration: const InputDecoration(labelText: 'Предел ловкости'),
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
  Armor createItem() {
    return Armor(
      name: _nameController.text,
      weight: int.parse(_weightController.text),
      kind: _kingNotifier.value,
      dexterityLimit: int.tryParse(_dexterityLimitController.text),
      protection: int.parse(_protectionController.text),
      stealthDisadvantage: _stealthDisadvantageNotifier.value,
    );
  }
}
