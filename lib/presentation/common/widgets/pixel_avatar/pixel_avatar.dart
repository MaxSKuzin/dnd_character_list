import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_layers.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_renderer.dart';
import 'package:flutter/material.dart';

/// Пиксельный персонаж в полный рост: кадр 64×64 в квадрате [size] без сглаживания. Низкорослые расы сжаты
/// по высоте и стоят на той же линии, что и остальные.
class PixelAvatar extends StatefulWidget {
  final AvatarLook look;
  final double size;

  const PixelAvatar({super.key, required this.look, this.size = 192});

  @override
  State<PixelAvatar> createState() => _PixelAvatarState();
}

class _PixelAvatarState extends State<PixelAvatar> {
  late List<AvatarLayer> _layers = widget.look.layers;
  late Future<ui.Image> _image = getIt<AvatarRenderer>().render(_layers);

  /// Последнее готовое изображение: пока собирается новое, виден прежний облик, а не пустое место.
  ui.Image? _shown;

  @override
  void didUpdateWidget(PixelAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final layers = widget.look.layers;
    if (!const ListEquality<AvatarLayer>().equals(layers, _layers)) {
      _layers = layers;
      _image = getIt<AvatarRenderer>().render(layers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: FutureBuilder(
        future: _image,
        builder: (context, snapshot) {
          final image = snapshot.data ?? _shown;
          if (image == null) return const SizedBox.shrink();
          _shown = image;
          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: widget.size,
              height: widget.size * widget.look.heightFactor,
              child: RawImage(image: image, fit: BoxFit.fill, filterQuality: FilterQuality.none),
            ),
          );
        },
      ),
    );
  }
}
