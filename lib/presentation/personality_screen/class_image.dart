import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Completer<ImageInfo> completer = Completer();
Future<ui.Image> getImage() async {
  if (completer.isCompleted) {
    return completer.future.then((e) => e.image);
  }
  var img = const AssetImage('assets/images/sprite_class.png');
  img.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info);
  }));
  ImageInfo imageInfo = await completer.future;
  return imageInfo.image;
}

final sprites = {
  'Bard': const Rect.fromLTWH(101, 376, 185, 163),
  'Barbarian': const Rect.fromLTWH(406, 192, 188, 167),
  'Warrior': const Rect.fromLTWH(725, 386, 164, 158),
  'Wizard': const Rect.fromLTWH(106, 728, 194, 176),
  'Driud': const Rect.fromLTWH(720, 185, 184, 172),
  'Cliric': const Rect.fromLTWH(734, 0, 168, 175),
  'Inventor': const Rect.fromLTWH(138, 214, 146, 148),
  'Witch': const Rect.fromLTWH(1005, 546, 201, 172),
  'Monk': const Rect.fromLTWH(110, 568, 187, 154),
  'Paladin': const Rect.fromLTWH(410, 551, 194, 174),
  'Thief': const Rect.fromLTWH(1045, 5, 145, 172),
  'Ranger': const Rect.fromLTWH(698, 549, 200, 175),
  'Sorcerer': const Rect.fromLTWH(1001, 364, 205, 177),
};

class ClassImage extends StatelessWidget {
  final String classType;

  const ClassImage({
    super.key,
    required this.classType,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImage(),
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? CustomPaint(
              painter: SpritePainter(
                spriteRect: sprites[classType]!,
                image: snapshot.data!,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return const SizedBox.expand();
              }),
            )
          : const SizedBox(),
    );
  }
}

class SpritePainter extends CustomPainter {
  final Rect spriteRect;
  final ui.Image image;

  SpritePainter({
    super.repaint,
    required this.spriteRect,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;
    final height = size.width * spriteRect.height / spriteRect.width;
    if (height <= size.height) {
      canvas.drawImageRect(
        image,
        spriteRect,
        Rect.fromLTWH(
          0,
          (size.height - height) / 2,
          size.width,
          height,
        ),
        paint,
      );
    } else {
      final width = size.height * spriteRect.width / spriteRect.height;
      canvas.drawImageRect(
        image,
        spriteRect,
        Rect.fromLTWH(
          (size.width - width) / 2,
          0,
          width,
          size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return image != oldDelegate.image || spriteRect != oldDelegate.spriteRect;
  }
}
