import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Хиты, владения, снаряжение и умения 1 уровня класса — как в разделе «Классовые умения» на ttg.club.
class ClassInfoDialog extends StatelessWidget {
  final ClassInfo info;

  const ClassInfoDialog({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Быстрое создание': info.quickBuildHtml,
      'Хиты': info.hitPointsHtml,
      'Владение': info.proficienciesHtml,
      'Снаряжение': info.equipmentHtml,
      for (final feature in info.featuresAt(1)) feature.name: feature.descriptionHtml,
    };
    return SheetDialog(
      title: info.name,
      subtitle: 'Классовые умения 1 уровня',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in sections.entries)
            if (section.value != null && section.value!.isNotEmpty) ...[
              SheetSectionTitle(icon: Icons.bookmark_outline, title: section.key),
              const Gap(4),
              HtmlContent(section.value!),
              const Gap(16),
            ],
        ],
      ),
    );
  }
}
