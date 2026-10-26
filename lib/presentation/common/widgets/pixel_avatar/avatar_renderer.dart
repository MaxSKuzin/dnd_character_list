import 'dart:convert';
import 'dart:ui' as ui;

import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_layers.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Сторона кадра LPC в пикселях.
const avatarFrameSide = 64;

/// Палитры LPC: материал → имя → цвета от тени к блику (`0xRRGGBB`). Палитры `all` подходят любому материалу.
class AvatarPalettes {
  final Map<String, Map<String, List<int>>> _palettes;

  AvatarPalettes(this._palettes);

  factory AvatarPalettes.fromJson(Map<String, dynamic> json) => AvatarPalettes({
        for (final MapEntry(key: material, value: palettes) in json.entries)
          material: {
            for (final MapEntry(key: name, value: colors) in (palettes as Map<String, dynamic>).entries)
              name: [for (final color in colors as List) int.parse((color as String).substring(1, 7), radix: 16)],
          },
      });

  List<int> colors(String material, String name) {
    final colors = _palettes[material]?[name] ?? _palettes['all']?[name];
    if (colors == null) throw ArgumentError('Нет палитры $material.$name');
    return colors;
  }

  /// Средний тон палитры — для образца цвета в редакторе облика.
  Color swatch(String material, String name) {
    final colors = this.colors(material, name);
    return Color(0xFF000000 | colors[colors.length * 2 ~/ 3]);
  }
}

/// Собирает аватар из слоёв `assets/avatar`: перекрашивает кадры палитрами и накладывает по порядку.
/// Готовые изображения кэшируются: облик меняется редко, а экранов с аватаром несколько.
@lazySingleton
class AvatarRenderer {
  static const _cacheSize = 32;

  final AssetBundle _bundle;

  AvatarRenderer({@ignoreParam AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  late final Future<AvatarPalettes> palettes = () async {
    final json = jsonDecode(await _bundle.loadString('assets/avatar/palettes.json')) as Map<String, dynamic>;
    return AvatarPalettes.fromJson(json);
  }();

  final _pixels = <String, Future<Uint8List>>{};
  final _images = <String, Future<ui.Image>>{};

  Future<ui.Image> render(List<AvatarLayer> layers) {
    final key = layers.join('|');
    // Удаление и повторная вставка держат недавние изображения в конце очереди.
    final cached = _images.remove(key);
    if (cached != null) return _images[key] = cached;
    if (_images.length >= _cacheSize) _images.remove(_images.keys.first);
    return _images[key] = _render(layers);
  }

  Future<ui.Image> _render(List<AvatarLayer> layers) async {
    final palettes = await this.palettes;
    final sources = await Future.wait(layers.map((e) => _pixels[e.asset] ??= _load(e.asset)));
    final pixels = composeAvatar([
      for (final (index, layer) in layers.indexed)
        (
          layer.mirrored ? mirrorFrame(sources[index]) : sources[index],
          [
            for (final recolor in layer.recolors)
              ...zipPalettes(
                palettes.colors(recolor.material, recolor.from),
                palettes.colors(recolor.toMaterial, recolor.to),
              ),
          ],
        ),
    ]);
    // В LPC оружие нарисовано в левой руке персонажа, щит — в правой. Отражённый кадр вкладывает основное
    // оружие в правую руку (на экране — слева), щит и второе оружие — в левую.
    final buffer = await ui.ImmutableBuffer.fromUint8List(premultiply(mirrorFrame(pixels)));
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: avatarFrameSide,
      height: avatarFrameSide,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    return (await codec.getNextFrame()).image;
  }

  Future<Uint8List> _load(String asset) async {
    final data = await _bundle.load('assets/avatar/layers/$asset.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final image = (await codec.getNextFrame()).image;
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }
}

/// Пары «цвет источника → цвет замены» по порядку тонов двух палитр.
List<(int, int)> zipPalettes(List<int> from, List<int> to) => [
      for (var i = 0; i < from.length && i < to.length; i++) (from[i], to[i]),
    ];

/// Допуск сравнения цветов по каждому каналу: в листах LPC тона одной палитры иногда отличаются на пару единиц.
const _tolerance = 6;

/// Накладывает кадры RGBA (без premultiply) друг на друга, заменяя цвета каждого слоя по его парам. Пиксель берёт
/// первую подходящую пару, остальные цвета не меняются.
Uint8List composeAvatar(List<(Uint8List, List<(int, int)>)> layers) {
  final out = Uint8List(avatarFrameSide * avatarFrameSide * 4);
  for (final (pixels, recolors) in layers) {
    for (var i = 0; i < out.length; i += 4) {
      final sa = pixels[i + 3];
      if (sa == 0) continue;
      var r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
      for (final (from, to) in recolors) {
        if ((r - (from >> 16 & 0xFF)).abs() <= _tolerance &&
            (g - (from >> 8 & 0xFF)).abs() <= _tolerance &&
            (b - (from & 0xFF)).abs() <= _tolerance) {
          r = to >> 16 & 0xFF;
          g = to >> 8 & 0xFF;
          b = to & 0xFF;
          break;
        }
      }
      final da = out[i + 3];
      if (sa == 255 || da == 0) {
        out
          ..[i] = r
          ..[i + 1] = g
          ..[i + 2] = b
          ..[i + 3] = sa;
        continue;
      }
      // Полупрозрачный пиксель поверх другого: обычное наложение «source over».
      final a = sa + da * (255 - sa) ~/ 255;
      int blend(int s, int d) => (s * sa + d * da * (255 - sa) ~/ 255) ~/ a;
      out
        ..[i] = blend(r, out[i])
        ..[i + 1] = blend(g, out[i + 1])
        ..[i + 2] = blend(b, out[i + 2])
        ..[i + 3] = a;
    }
  }
  return out;
}

/// Кадр RGBA, отражённый по горизонтали.
Uint8List mirrorFrame(Uint8List pixels) {
  final out = Uint8List(pixels.length);
  for (var y = 0; y < avatarFrameSide; y++) {
    for (var x = 0; x < avatarFrameSide; x++) {
      final from = (y * avatarFrameSide + x) * 4;
      final to = (y * avatarFrameSide + avatarFrameSide - 1 - x) * 4;
      out.setRange(to, to + 4, pixels, from);
    }
  }
  return out;
}

/// Flutter ждёт пиксели `rgba8888` с умноженной на прозрачность яркостью.
Uint8List premultiply(Uint8List pixels) {
  final out = Uint8List.fromList(pixels);
  for (var i = 0; i < out.length; i += 4) {
    final a = out[i + 3];
    if (a == 255) continue;
    out
      ..[i] = out[i] * a ~/ 255
      ..[i + 1] = out[i + 1] * a ~/ 255
      ..[i + 2] = out[i + 2] * a ~/ 255;
  }
  return out;
}
