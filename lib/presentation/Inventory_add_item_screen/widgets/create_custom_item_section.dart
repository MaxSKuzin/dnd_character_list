import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CreateCustomItemSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateCustomItemSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateCustomItemSection> createState() => _CreateCustomItemSectionState();
}

class _CreateCustomItemSectionState extends State<CreateCustomItemSection>
    with CreateItemPresenter<CustomInvetoryItem> {
  final _nameController = TextEditingController(text: 'Инструмент');
  final _descriptionController = TextEditingController(text: 'Описание');

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

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
          const Gap(16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Описаение'),
          ),
        ],
      ),
    );
  }

  @override
  CustomInvetoryItem createItem() {
    return CustomInvetoryItem(
      name: _nameController.text,
      description: _descriptionController.text,
    );
  }
}
