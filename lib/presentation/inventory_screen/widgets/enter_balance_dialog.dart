import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class EnterBalanceDialog extends StatefulWidget {
  final String title;

  const EnterBalanceDialog({
    super.key,
    required this.title,
  });

  @override
  State<EnterBalanceDialog> createState() => _EnterBalanceDialogState();
}

class _EnterBalanceDialogState extends State<EnterBalanceDialog> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _copperController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title),
          const Gap(16),
          TextField(
            controller: _goldController,
            decoration: const InputDecoration(
              labelText: 'Золото',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _silverController,
            decoration: const InputDecoration(
              labelText: 'Серебро',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _copperController,
            decoration: const InputDecoration(
              labelText: 'Медь',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              final gold = int.tryParse(_goldController.text) ?? 0;
              final silver = int.tryParse(_silverController.text) ?? 0;
              final copper = int.tryParse(_copperController.text) ?? 0;

              Navigator.of(context).pop(gold * 100 + silver * 10 + copper);
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}
