import 'dart:convert';

import 'package:dnd_character_list/domain/models/appearance.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_layers.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_renderer.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/pixel_avatar.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Редактор облика пиксельного аватара: телосложение, причёска и цвета. Предпросмотр — с экипировкой из [look].
/// Возвращает новый облик или `null`, если редактор закрыли.
class AppearanceEditor extends StatefulWidget {
  final AvatarLook look;

  const AppearanceEditor({super.key, required this.look});

  static Future<Appearance?> show(BuildContext context, AvatarLook look) =>
      showDialog<Appearance>(context: context, builder: (_) => AppearanceEditor(look: look));

  @override
  State<AppearanceEditor> createState() => _AppearanceEditorState();
}

class _AppearanceEditorState extends State<AppearanceEditor> {
  late Appearance _appearance = widget.look.appearance;

  void _set(Appearance appearance) => setState(() => _appearance = appearance);

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.theme.textTheme.labelMedium?.copyWith(color: Colors.white70);
    return SheetDialog(
      title: 'Облик',
      subtitle: 'Доспех и оружие на рисунке — те, что надеты',
      // Персонаж остаётся на виду, пока прокручиваются настройки.
      pinned: Center(child: AvatarStage(look: widget.look.withAppearance(_appearance), size: 140)),
      child: FutureBuilder(
        future: getIt<AvatarRenderer>().palettes,
        builder: (context, snapshot) {
          final palettes = snapshot.data;
          if (palettes == null) return const Center(child: CircularProgressIndicator());
          final female = _appearance.body == BodyType.female;
          final clothColors = {for (final e in ClothColor.values) e: palettes.swatch('cloth', e.name)};
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<BodyType>(
                segments: const [
                  ButtonSegment(value: BodyType.male, label: Text('Мужчина')),
                  ButtonSegment(value: BodyType.female, label: Text('Женщина')),
                ],
                selected: {_appearance.body},
                onSelectionChanged: (value) => _set(_appearance.withBody(value.single)),
              ),
              const Gap(12),
              Text('Причёска', style: labelStyle),
              const Gap(6),
              _PreviewChoices(
                values: [for (var i = 0; i < Appearance.hairstyleCount; i++) i],
                selected: _appearance.hairstyle,
                look: (i) => AvatarLook(appearance: _appearance.copyWith(hairstyle: i), race: widget.look.race),
                focus: const Alignment(0, -0.6),
                onSelected: (i) => _set(_appearance.copyWith(hairstyle: i)),
              ),
              const Gap(12),
              Text('Кожа', style: labelStyle),
              const Gap(6),
              _Swatches(
                colors: {for (final e in SkinTone.values) e: palettes.swatch('body', snakeCase(e.name))},
                selected: _appearance.skin,
                onSelected: (value) => _set(_appearance.copyWith(skin: value)),
              ),
              const Gap(12),
              Text('Волосы', style: labelStyle),
              const Gap(6),
              _Swatches(
                colors: {for (final e in HairColor.values) e: palettes.swatch('hair', snakeCase(e.name))},
                selected: _appearance.hair,
                onSelected: (value) => _set(_appearance.copyWith(hair: value)),
              ),
              const Gap(12),
              Text('Глаза', style: labelStyle),
              const Gap(6),
              _Swatches(
                colors: {for (final e in EyeColor.values) e: palettes.swatch('eye', e.name)},
                selected: _appearance.eyes,
                onSelected: (value) => _set(_appearance.copyWith(eyes: value)),
              ),
              // Фасоны — на персонаже без доспеха: под ним их не разглядеть.
              const Gap(12),
              Text('Верх', style: labelStyle),
              const Gap(6),
              _PreviewChoices(
                values: [
                  for (final e in TopStyle.values)
                    if (female || !e.isFemaleOnly) e
                ],
                selected: _appearance.top,
                look: (e) => AvatarLook(appearance: _appearance.copyWith(top: e), race: widget.look.race),
                focus: const Alignment(0, 0.4),
                onSelected: (e) => _set(_appearance.copyWith(top: e)),
              ),
              const Gap(8),
              _Swatches(
                colors: clothColors,
                selected: _appearance.topColor,
                onSelected: (value) => _set(_appearance.copyWith(topColor: value)),
              ),
              // Платье закрывает низ.
              if (!_appearance.top.isDress) ...[
                const Gap(12),
                Text('Низ', style: labelStyle),
                const Gap(6),
                _PreviewChoices(
                  values: [
                    for (final e in BottomStyle.values)
                      if (female || !e.isFemaleOnly) e
                  ],
                  selected: _appearance.bottom,
                  look: (e) => AvatarLook(appearance: _appearance.copyWith(bottom: e), race: widget.look.race),
                  focus: const Alignment(0, 1),
                  onSelected: (e) => _set(_appearance.copyWith(bottom: e)),
                ),
                const Gap(8),
                _Swatches(
                  colors: clothColors,
                  selected: _appearance.bottomColor,
                  onSelected: (value) => _set(_appearance.copyWith(bottomColor: value)),
                ),
              ],
              const Gap(12),
              Text('Обувь', style: labelStyle),
              const Gap(6),
              _PreviewChoices(
                values: Footwear.values,
                selected: _appearance.footwear,
                look: (e) => AvatarLook(appearance: _appearance.copyWith(footwear: e), race: widget.look.race),
                focus: const Alignment(0, 1),
                onSelected: (e) => _set(_appearance.copyWith(footwear: e)),
              ),
              const Gap(8),
              _Swatches(
                colors: clothColors,
                selected: _appearance.footwearColor,
                onSelected: (value) => _set(_appearance.copyWith(footwearColor: value)),
              ),
              const Gap(16),
              FilledButton(onPressed: () => Navigator.pop(context, _appearance), child: const Text('Сохранить')),
              TextButton(onPressed: () => AvatarCredits.show(context), child: const Text('Авторы рисунков')),
            ],
          );
        },
      ),
    );
  }
}

/// Персонаж на «сцене»: тень под ногами и тёмный круг фона.
class AvatarStage extends StatelessWidget {
  final AvatarLook look;
  final double size;

  const AvatarStage({super.key, required this.look, this.size = 192});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Кадр LPC: ступни на высоте ~60 из 64 пикселей.
          Positioned(
            left: size * 0.25,
            right: size * 0.25,
            top: size * 0.88,
            height: size * 0.08,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.25, size * 0.04)),
              ),
            ),
          ),
          PixelAvatar(look: look, size: size),
        ],
      ),
    );
  }
}

/// Варианты плитками (до четырёх в ряд); в каждой — увеличенная часть персонажа с этим вариантом: [focus] — какая
/// (`Alignment` по вертикали: −1 — голова, 1 — ноги).
class _PreviewChoices<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final AvatarLook Function(T value) look;
  final Alignment focus;
  final ValueChanged<T> onSelected;

  const _PreviewChoices({
    required this.values,
    required this.selected,
    required this.look,
    required this.focus,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Больше четырёх вариантов — в два ряда.
    final columns = values.length <= 4 ? values.length : (values.length / 2).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              SizedBox(
                width: width,
                child: SheetTile(
                  onTap: () => onSelected(value),
                  borderColor: value == selected ? context.theme.colorScheme.primary : Colors.white24,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ClipRect(
                        child: Align(
                          alignment: focus,
                          widthFactor: 0.5,
                          heightFactor: 0.5,
                          child: PixelAvatar(look: look(value), size: 144),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Swatches<T> extends StatelessWidget {
  final Map<T, Color> colors;
  final T selected;
  final ValueChanged<T> onSelected;

  const _Swatches({required this.colors, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final MapEntry(key: value, value: color) in colors.entries)
          GestureDetector(
            onTap: () => onSelected(value),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: value == selected ? Colors.white : Colors.white24,
                  width: value == selected ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Авторы рисунков LPC из `assets/avatar/credits.json`. Лицензии CC-BY-SA, GPL и OGA-BY требуют указать авторов.
class AvatarCredits extends StatelessWidget {
  const AvatarCredits({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const AvatarCredits());

  static Future<List<Map<String, dynamic>>> _load() async =>
      (jsonDecode(await rootBundle.loadString('assets/avatar/credits.json')) as List).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final small = context.theme.textTheme.bodySmall;
    return SheetDialog(
      title: 'Авторы рисунков',
      subtitle: 'Liberated Pixel Cup (LPC) и Universal LPC Spritesheet Character Generator',
      child: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          final credits = snapshot.data;
          if (credits == null) return const Center(child: CircularProgressIndicator());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final credit in credits) ...[
                Text(credit['file'], style: const TextStyle(fontWeight: FontWeight.w700)),
                Text((credit['authors'] as List).join(', ')),
                Text((credit['licenses'] as List).join(', '), style: small?.copyWith(color: Colors.white60)),
                for (final url in credit['urls'] as List) Text(url, style: small?.copyWith(color: Colors.white54)),
                const Gap(10),
              ],
            ],
          );
        },
      ),
    );
  }
}
