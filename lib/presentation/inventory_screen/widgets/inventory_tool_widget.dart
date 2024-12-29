import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';

class InventoryToolWidget extends StatelessWidget {
  const InventoryToolWidget({
    super.key,
    required this.item,
    required this.quantity,
  });

  final Tool item;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showDialog(
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
            child: SingleChildScrollView(
              child: TextParses(item.description),
            ),
          ),
        ),
      ),
      title: Text(item.name),
      trailing: Text('x$quantity'),
    );
  }
}
