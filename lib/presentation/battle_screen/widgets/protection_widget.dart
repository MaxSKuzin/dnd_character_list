import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProtectionWidget extends StatelessWidget {
  const ProtectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final protection = PlayerModel.protection(context).toString();
    return CustomPaint(
      painter: ShieldPainter(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CustomPaint(
          painter: ShieldPainter(
            color: context.customColors?.cardColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  protection,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'КЛАСС\nБРОНИ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color? color;

  ShieldPainter({
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final height = size.height;
    final width = size.width;

    const topRadius = 16.0;

    // top border
    path.moveTo(0, height / 5);
    path.arcToPoint(
      Offset(width / 7, height / 12),
      radius: const Radius.circular(topRadius),
      clockwise: false,
    );
    path.lineTo(width / 2, 0);
    path.lineTo(width * 6 / 7, height / 12);
    path.arcToPoint(
      Offset(width, height / 5),
      radius: const Radius.circular(topRadius),
      clockwise: false,
    );

    // right border
    path.lineTo(width, height * 2 / 5);
    path.arcToPoint(
      Offset(width / 2, height),
      radius: const Radius.circular(80),
    );

    // left border
    path.arcToPoint(
      Offset(0, height * 2 / 5),
      radius: const Radius.circular(80),
    );
    path.close();

    canvas.drawPath(path, paint);
    if (color != null) {
      final Paint paint = Paint()
        ..color = color!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ShieldPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
