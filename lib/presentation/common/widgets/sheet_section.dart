import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Шапка экрана: карточка с градиентом от цвета карточек к основному цвету темы и белой рамкой.
class SheetHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SheetHeader({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.customColors?.cardColor ?? Colors.black, context.theme.colorScheme.primaryContainer],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Заголовок раздела: значок и название прописными буквами, справа — необязательное действие.
class SheetSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const SheetSectionTitle({super.key, required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const Gap(8),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: context.theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2, color: Colors.white70),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Раздел экрана: карточка с заголовком ([SheetSectionTitle]) и содержимым. Фон — [Material], чтобы у
/// `ListTile` и `InkWell` внутри были видны подсветка и нажатия.
class SheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  /// Фон; по умолчанию — цвет карточек.
  final Color? color;

  const SheetSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.customColors?.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, trailing == null ? 16 : 4, 8),
            child: SheetSectionTitle(icon: icon, title: title, trailing: trailing),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Плитка значения: подпись мелко сверху, значение под ней.
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final TextStyle? valueStyle;
  final VoidCallback? onTap;

  const InfoTile({super.key, required this.label, required this.value, this.caption, this.valueStyle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          // По центру: в ряду [TileGrid] плитка растягивается до высоты соседей.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60),
              ),
              const Gap(2),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (caption != null)
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Плитки в [columns] колонок одинаковой ширины; плитки одного ряда — одной высоты (по самой высокой).
class TileGrid extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  final double spacing;

  const TileGrid({super.key, required this.columns, required this.children, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var start = 0; start < children.length; start += columns) ...[
          if (start > 0) SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) SizedBox(width: spacing),
                  // В неполном последнем ряду пустые места сохраняют ширину колонок.
                  Expanded(child: start + column < children.length ? children[start + column] : const SizedBox()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Небольшая метка в рамке: класс, язык, состояние.
class SheetBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const SheetBadge(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Colors.white54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(text, style: context.theme.textTheme.labelMedium?.copyWith(color: color)),
      ),
    );
  }
}
