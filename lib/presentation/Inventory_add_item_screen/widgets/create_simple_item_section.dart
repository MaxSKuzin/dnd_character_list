import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:flutter/material.dart';

class CreateSimpleItemSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateSimpleItemSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateSimpleItemSection> createState() => _CreateSimpleItemSectionState();
}

class _CreateSimpleItemSectionState extends State<CreateSimpleItemSection> with CreateItemPresenter<String> {
  final _nameController = TextEditingController(text: 'Инструмент');

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();

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
        ],
      ),
    );
  }

  @override
  String createItem() {
    return _nameController.text.trim();
  }
}
