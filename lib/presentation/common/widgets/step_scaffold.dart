import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Шаг создания или повышения уровня персонажа: шапка с градиентом (назад, заголовок, пояснение, счётчик выбора),
/// содержимое и закреплённая снизу кнопка «Далее». Содержимое прокручивает себя само.
///
/// ```dart
/// StepScaffold(
///   title: 'Навыки',
///   description: 'Выберите навыки из списка класса.',
///   counter: '1 из 2',
///   onAction: isComplete ? _done : null,
///   body: ListView(...),
/// )
/// ```
class StepScaffold extends StatelessWidget {
  final String title;
  final String? description;

  /// Сколько выбрано: «1 из 2». Когда выбор закончен ([isCounterDone]), метка подсвечивается.
  final String? counter;
  final bool isCounterDone;

  /// Под пояснением в шапке: поиск, фильтры.
  final Widget? headerBottom;
  final Widget body;

  final String actionLabel;

  /// `null` — кнопка погашена: выбор не закончен.
  final VoidCallback? onAction;

  /// Идёт сохранение или загрузка: на кнопке индикатор, нажать нельзя.
  final bool isBusy;

  /// Необязательный шаг: «Пропустить» под основной кнопкой.
  final VoidCallback? onSkip;

  const StepScaffold({
    super.key,
    required this.title,
    this.description,
    this.counter,
    this.isCounterDone = false,
    this.headerBottom,
    required this.body,
    this.actionLabel = 'Далее',
    required this.onAction,
    this.isBusy = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final primary = context.theme.colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SheetHeader(
                padding: EdgeInsets.fromLTRB(canPop ? 4 : 16, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (canPop)
                          IconButton(
                            tooltip: 'Назад',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (counter != null) SheetBadge(counter!, color: isCounterDone ? primary : null),
                      ],
                    ),
                    if (description != null)
                      Padding(
                        padding: EdgeInsets.only(left: canPop ? 12 : 0, top: 4),
                        child: Text(
                          description!,
                          style: context.theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ),
                    if (headerBottom != null)
                      Padding(
                        padding: EdgeInsets.only(left: canPop ? 12 : 0, top: 12),
                        child: headerBottom!,
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: body),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: isBusy ? null : onAction,
                    child: isBusy
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(actionLabel),
                  ),
                  if (onSkip != null) ...[
                    const Gap(4),
                    TextButton(onPressed: isBusy ? null : onSkip, child: const Text('Пропустить')),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вариант выбора: карточка с отметкой слева (круг — один вариант, квадрат — несколько), названием, подписью и
/// кнопкой описания «i». Выбранная — цветом карточек с белой рамкой, невыбранная — прозрачная с тонкой рамкой.
class ChoiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Дополнительное содержимое под подписью: описание выбранной черты, её выборы.
  final Widget? child;
  final bool isSelected;

  /// Можно выбрать несколько вариантов — отметка квадратная.
  final bool isMultiple;

  /// `null` — вариант недоступен (например, не выполнено требование).
  final VoidCallback? onTap;

  /// Описание варианта по кнопке «i».
  final VoidCallback? onInfo;

  /// Своя кнопка справа вместо «i»: загрузка описания, повтор.
  final Widget? trailing;

  /// Почему вариант недоступен — красным под подписью.
  final String? unavailableReason;

  const ChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    required this.isSelected,
    this.isMultiple = false,
    required this.onTap,
    this.onInfo,
    this.trailing,
    this.unavailableReason,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    final isEnabled = onTap != null || isSelected;
    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: Material(
        color: isSelected ? context.customColors?.cardColor : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, onInfo == null && trailing == null ? 12 : 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    switch ((isMultiple, isSelected)) {
                      (false, true) => Icons.radio_button_checked,
                      (false, false) => Icons.radio_button_unchecked,
                      (true, true) => Icons.check_box,
                      (true, false) => Icons.check_box_outline_blank,
                    },
                    size: 22,
                    color: isSelected ? primary : Colors.white38,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const Gap(2),
                        Text(subtitle!, style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ],
                      if (unavailableReason != null)
                        Text(
                          unavailableReason!,
                          style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                        ),
                      if (child != null) ...[const Gap(8), child!],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onInfo != null)
                  IconButton(
                    tooltip: 'Описание',
                    visualDensity: VisualDensity.compact,
                    onPressed: onInfo,
                    icon: const Icon(Icons.info_outline, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Список карточек [ChoiceCard] с отступами, прокручивается.
class ChoiceList extends StatelessWidget {
  final List<Widget> children;

  const ChoiceList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: children.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (_, index) => children[index],
    );
  }
}
