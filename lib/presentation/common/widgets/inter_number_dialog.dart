import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InterNumberDialog extends StatefulWidget {
  static Future<int?> show(
    BuildContext context, {
    required String title,
    required String labelText,
  }) =>
      showDialog<int>(
        context: context,
        builder: (context) => Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: InterNumberDialog(
            title: title,
            labelText: labelText,
          ),
        ),
      );

  final String title;
  final String labelText;

  const InterNumberDialog({
    required this.title,
    required this.labelText,
    super.key,
  });

  @override
  State<InterNumberDialog> createState() => _InterNumberDialogState();
}

class _InterNumberDialogState extends State<InterNumberDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: context.theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          TapRegion(
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.labelText,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          const SizedBox(height: 32),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, controllerValue, child) {
              final value = int.tryParse(controllerValue.text);
              return OutlinedButton(
                onPressed: value != null ? () => Navigator.of(context).pop(value) : null,
                child: const Text('Подтвердить'),
              );
            },
          ),
        ],
      ),
    );
  }
}
