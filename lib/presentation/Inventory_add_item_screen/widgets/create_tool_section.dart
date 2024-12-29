import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class CreateToolSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateToolSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateToolSection> createState() => _CreateToolSectionState();
}

class _CreateToolSectionState extends State<CreateToolSection> with CreateItemPresenter<Tool> {
  final _nameController = TextEditingController(text: 'Инструмент');
  final _kingNotifier = ValueNotifier<ToolCategory>(ToolCategory.thievesTool);
  final _descriptionController = TextEditingController(text: 'Описание');
  final _goldController = TextEditingController(text: '0');
  final _silverController = TextEditingController(text: '0');
  final _copperController = TextEditingController(text: '0');

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kingNotifier.dispose();
    _descriptionController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _copperController.dispose();

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
                children: ToolCategory.values
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
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Описаение'),
          ),
          const Gap(16),
          TextField(
            controller: _goldController,
            decoration: const InputDecoration(labelText: 'Золото'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _silverController,
            decoration: const InputDecoration(labelText: 'Серебро'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _copperController,
            decoration: const InputDecoration(labelText: 'Медь'),
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
  Tool createItem() {
    final gold = int.tryParse(_goldController.text) ?? 0;
    final silver = int.tryParse(_silverController.text) ?? 0;
    final copper = int.tryParse(_copperController.text) ?? 0;
    return Tool(
      name: _nameController.text,
      category: _kingNotifier.value,
      description: _descriptionController.text,
      price: Balance(gold * 100 + silver * 10 + copper),
    );
  }
}
