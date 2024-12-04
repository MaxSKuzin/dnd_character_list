import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class PassiveWisdomWidget extends StatelessWidget {
  final int value;

  const PassiveWisdomWidget({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white),
        ),
        color: context.customColors?.cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FittedBox(
              child: Text(
                'Восприятие',
              ),
            ),
            FittedBox(
              child: Text(
                '(Пассивное)',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: context.theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
