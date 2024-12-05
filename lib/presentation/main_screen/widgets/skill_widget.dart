import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SkillWidget extends StatelessWidget {
  final String title;
  final bool isChosen;
  final int bonus;

  const SkillWidget({
    super.key,
    required this.title,
    required this.isChosen,
    required this.bonus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 24,
            ),
            child: FittedBox(
              child: IgnorePointer(
                child: Radio<bool>(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isChosen,
                  groupValue: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              bonus >= 0 ? '+$bonus' : '$bonus',
              style: context.theme.textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const Gap(4),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: context.theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
