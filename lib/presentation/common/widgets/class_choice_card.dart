import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';

/// Класс в сетке выбора: картинка класса, название и подпись внизу на затемнении. Выбранный — с белой рамкой и
/// отметкой, недоступный — приглушён. «i» — описание класса.
class ClassChoiceCard extends StatelessWidget {
  final ClassKind classKind;
  final bool isSelected;

  /// «Уровень 3», «Пока недоступен».
  final String? subtitle;

  /// `null` — класс недоступен.
  final VoidCallback? onTap;
  final VoidCallback? onInfo;

  const ClassChoiceCard({
    super.key,
    required this.classKind,
    required this.isSelected,
    this.subtitle,
    required this.onTap,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: isSelected ? context.customColors?.cardColor : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? Colors.white : Colors.white24, width: isSelected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 44),
                // Невыбранные классы чуть приглушены, чтобы выбранный выделялся.
                child: Opacity(opacity: isSelected ? 1 : 0.7, child: ClassImage(classType: classKind)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          classKind.localizedName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSelected) Positioned(left: 8, top: 8, child: Icon(Icons.check_circle, color: primary)),
              if (onInfo != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    tooltip: 'Описание класса',
                    onPressed: onInfo,
                    icon: const Icon(Icons.info_outline, color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Сетка карточек классов в две колонки, прокручивается.
class ClassChoiceGrid extends StatelessWidget {
  final List<Widget> children;

  const ClassChoiceGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: children,
    );
  }
}
