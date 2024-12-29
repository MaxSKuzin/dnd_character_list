import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class CreateShieldSection extends StatefulWidget {
  final Function(CreateItemController controller) onControllerReady;

  const CreateShieldSection({
    required this.onControllerReady,
    super.key,
  });

  @override
  State<CreateShieldSection> createState() => _CreateShieldSectionState();
}

class _CreateShieldSectionState extends State<CreateShieldSection> with CreateItemPresenter<Shield> {
  final _nameController = TextEditingController(text: 'Щит');
  final _weightController = TextEditingController(text: '15');
  final _protectionController = TextEditingController(text: '2');

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
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
        ],
      ),
    );
  }

  @override
  Shield createItem() {
    return Shield(
      name: _nameController.text,
      weight: int.parse(_weightController.text),
      defense: int.parse(_protectionController.text),
    );
  }
}
