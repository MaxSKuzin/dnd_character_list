import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
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
  var _toolCategory = ToolCategory.thievesTool;
  Tool? _selectedTool;

  @override
  void initState() {
    widget.onControllerReady(CreateItemController(this));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Тип',
            textAlign: TextAlign.center,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ToolCategory.values
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _toolCategory = e;
                        }),
                        child: Chip(
                          label: Text(e.name),
                          color: WidgetStatePropertyAll(
                            _toolCategory == e ? context.customColors?.cardColor : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Gap(8),
          ..._toolCategory.tools.map(
            (tool) => GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedTool == tool) {
                    _selectedTool = null;
                  } else {
                    _selectedTool = tool;
                  }
                });
              },
              child: Card(
                color: _selectedTool == tool ? context.customColors?.cardColor : null,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tool.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      TextParses(
                        tool.description,
                      ),
                      const Gap(8),
                      Text(
                        'Цена: ${tool.price.toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Tool createItem() {
    return _selectedTool!;
  }
}
