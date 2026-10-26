import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
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
    return Dialog(
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final section in sections.entries)
                      if (section.value != null && section.value!.isNotEmpty) ...[
                        Text(
                          section.key.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Gap(4),
                        HtmlContent(section.value!),
                        const Gap(16),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
