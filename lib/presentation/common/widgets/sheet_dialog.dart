import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Диалог в стиле листа: шапка с градиентом (название, подпись, крестик) и прокручиваемое содержимое.
/// Как у подробностей заклинания.
class SheetDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SheetDialog({super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.customColors?.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        if (subtitle != null)
                          Text(subtitle!, style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(4, 12, 4, 4), child: child),
          ],
        ),
      ),
    );
  }
}
