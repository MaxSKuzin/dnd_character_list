import 'dart:math';

import 'package:flutter/material.dart';

enum LabelBorderStyle {
  rectangle,
  circle,
}

class LabeledBorder extends StatelessWidget {
  final double borderRadius;
  final String text;
  final Widget child;
  final Color? backgroundColor;
  final LabelBorderStyle labelBorderStyle;
  final double? fontSize;

  const LabeledBorder({
    required this.text,
    required this.child,
    this.fontSize,
    this.backgroundColor,
    this.borderRadius = 16,
    this.labelBorderStyle = LabelBorderStyle.rectangle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text,
        style: TextStyle(
          // fontFamily: 'Inkulinati',
          color: Colors.white,
          fontSize: fontSize ?? (labelBorderStyle == LabelBorderStyle.rectangle ? 8 : 12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    textPainter.layout();
    return Padding(
      padding: EdgeInsets.only(
        bottom: textPainter.height / 2 + 4,
        top: 1,
        right: 1,
        left: 1,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: textPainter.width + 48,
        ),
        child: CustomPaint(
          painter: _Painter(
            fontSize: fontSize,
            labelBorderStyle: labelBorderStyle,
            backgroundColor: backgroundColor,
            text: text,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: textPainter.height / 2 + 4,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final double borderRadius;
  final String text;
  final Color? backgroundColor;
  final LabelBorderStyle labelBorderStyle;
  final double? fontSize;

  _Painter({
    required this.backgroundColor,
    required this.text,
    required this.borderRadius,
    required this.labelBorderStyle,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '  $text  ',
        style: TextStyle(
          // fontFamily: 'Inkulinati',
          color: Colors.white,
          fontSize: fontSize ?? (labelBorderStyle == LabelBorderStyle.rectangle ? 8 : 12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    textPainter.layout();

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, borderRadius);

    path.arcToPoint(
      Offset(borderRadius, 0),
      radius: Radius.circular(borderRadius),
    );

    //top line
    path.lineTo(size.width - borderRadius, 0);

    path.arcToPoint(
      Offset(size.width, borderRadius),
      radius: Radius.circular(borderRadius),
    );

    //right line
    path.lineTo(size.width, size.height - borderRadius);

    path.arcToPoint(
      Offset(size.width - borderRadius, size.height),
      radius: Radius.circular(borderRadius),
    );

    final Path remainingPath;

    //bottom line
    if (labelBorderStyle == LabelBorderStyle.rectangle) {
      final rightPoint = size.width / 2 + textPainter.width / 2;
      final leftPoint = size.width / 2 - textPainter.width / 2;
      final topPoint = size.height - textPainter.height / 2 - 4;
      final bottomPoint = size.height + textPainter.height / 2 + 4;
      path.lineTo(rightPoint, size.height);
      path.arcToPoint(
        Offset(
          rightPoint - 8,
          topPoint,
        ),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      path.lineTo(leftPoint + 8, topPoint);
      path.arcToPoint(
        Offset(
          leftPoint,
          size.height,
        ),
        radius: const Radius.circular(8),
        clockwise: false,
      );
      remainingPath = Path();
      remainingPath.moveTo(rightPoint, size.height);
      remainingPath.arcToPoint(
        Offset(
          rightPoint - 8,
          bottomPoint,
        ),
        radius: const Radius.circular(8),
      );
      remainingPath.lineTo(leftPoint + 8, bottomPoint);
      remainingPath.arcToPoint(
        Offset(
          leftPoint,
          size.height,
        ),
        radius: const Radius.circular(8),
      );
    } else {
      final radius = min(textPainter.width, textPainter.height);
      path.lineTo(size.width / 2 + radius, size.height);
      path.arcToPoint(
        Offset(size.width / 2 - radius, size.height),
        radius: Radius.circular(radius),
        clockwise: false,
      );
      remainingPath = Path();
      remainingPath.moveTo(size.width / 2 + radius, size.height);
      remainingPath.arcToPoint(
        Offset(size.width / 2 - radius, size.height),
        radius: Radius.circular(radius),
      );
    }
    path.lineTo(borderRadius, size.height);

    path.arcToPoint(
      Offset(0, size.height - borderRadius),
      radius: Radius.circular(borderRadius),
    );

    //left line
    path.close();

    // draw

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height - textPainter.height / 2,
      ),
    );

    if (backgroundColor != null) {
      final filledPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, filledPaint);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(remainingPath, paint);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) {
    return labelBorderStyle != oldDelegate.labelBorderStyle ||
        text != oldDelegate.text ||
        fontSize != oldDelegate.fontSize ||
        borderRadius != oldDelegate.borderRadius ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
