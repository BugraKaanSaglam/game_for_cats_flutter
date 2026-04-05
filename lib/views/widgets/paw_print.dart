import 'package:flutter/material.dart';

//* Shared paw-print glyph used across the menu and CTA surfaces.
//! Drawing this in code avoids blurry tiny assets and keeps the paw shape consistent at every size.
class PawPrint extends StatelessWidget {
  const PawPrint({
    super.key,
    required this.size,
    required this.color,
    this.rotation = 0,
  });

  final double size;
  final Color color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size.square(size),
        painter: _PawPrintPainter(color: color),
      ),
    );
  }
}

class _PawPrintPainter extends CustomPainter {
  const _PawPrintPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    void drawOval({
      required double cx,
      required double cy,
      required double w,
      required double h,
      double angle = 0,
    }) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        paint,
      );
      canvas.restore();
    }

    final width = size.width;
    final height = size.height;

    drawOval(
      cx: width * 0.24,
      cy: height * 0.24,
      w: width * 0.18,
      h: height * 0.22,
      angle: -0.35,
    );
    drawOval(
      cx: width * 0.42,
      cy: height * 0.14,
      w: width * 0.18,
      h: height * 0.24,
      angle: -0.08,
    );
    drawOval(
      cx: width * 0.60,
      cy: height * 0.14,
      w: width * 0.18,
      h: height * 0.24,
      angle: 0.08,
    );
    drawOval(
      cx: width * 0.78,
      cy: height * 0.24,
      w: width * 0.18,
      h: height * 0.22,
      angle: 0.35,
    );

    final pad = Path()
      ..moveTo(width * 0.20, height * 0.62)
      ..quadraticBezierTo(
        width * 0.18,
        height * 0.46,
        width * 0.32,
        height * 0.42,
      )
      ..quadraticBezierTo(
        width * 0.40,
        height * 0.38,
        width * 0.50,
        height * 0.46,
      )
      ..quadraticBezierTo(
        width * 0.60,
        height * 0.38,
        width * 0.68,
        height * 0.42,
      )
      ..quadraticBezierTo(
        width * 0.82,
        height * 0.46,
        width * 0.80,
        height * 0.62,
      )
      ..quadraticBezierTo(
        width * 0.78,
        height * 0.84,
        width * 0.50,
        height * 0.88,
      )
      ..quadraticBezierTo(
        width * 0.22,
        height * 0.84,
        width * 0.20,
        height * 0.62,
      )
      ..close();
    canvas.drawPath(pad, paint);
  }

  @override
  bool shouldRepaint(covariant _PawPrintPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
