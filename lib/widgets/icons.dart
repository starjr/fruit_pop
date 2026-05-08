import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum IconKind {
  back, settings, trophy, shop, pause, play, home, refresh, share,
  bomb, clock, check, lock, star
}

/// 커스텀 SVG 스타일 아이콘
class AppIcon extends StatelessWidget {
  final IconKind kind;
  final double size;
  final Color? color;
  const AppIcon(this.kind, {super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IconPainter(kind, color ?? AppColors.ink)),
    );
  }
}

class _IconPainter extends CustomPainter {
  final IconKind kind;
  final Color color;
  _IconPainter(this.kind, this.color);

  @override
  void paint(Canvas c, Size s) {
    c.scale(s.width / 24);
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color..style = PaintingStyle.fill;

    switch (kind) {
      case IconKind.back:
        c.drawPath(Path()..moveTo(15, 18)..lineTo(9, 12)..lineTo(15, 6),
            stroke..strokeWidth = 2.5);
        break;

      case IconKind.settings:
        c.drawCircle(const Offset(12, 12), 3, stroke);
        // 8개 톱니 (단순화)
        final gear = Path();
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final x = 12 + 8 * math.cos(a);
          final y = 12 + 8 * math.sin(a);
          if (i == 0) {
            gear.moveTo(x, y);
          } else {
            gear.lineTo(x, y);
          }
        }
        gear.close();
        c.drawPath(gear, stroke);
        break;

      case IconKind.trophy:
        c.drawPath(
            Path()..moveTo(6, 9)..lineTo(4, 9)..lineTo(2, 9)
              ..lineTo(2, 5)..lineTo(6, 5),
            stroke);
        c.drawPath(
            Path()..moveTo(18, 9)..lineTo(20, 9)..lineTo(22, 9)
              ..lineTo(22, 5)..lineTo(18, 5),
            stroke);
        c.drawPath(
            Path()..moveTo(6, 5)..lineTo(6, 11)
              ..cubicTo(6, 14, 8, 16, 12, 16)
              ..cubicTo(16, 16, 18, 14, 18, 11)
              ..lineTo(18, 5)..close(),
            stroke);
        c.drawPath(
            Path()..moveTo(12, 16)..lineTo(12, 19)
              ..moveTo(8, 22)..lineTo(16, 22)
              ..moveTo(10, 19)..lineTo(14, 19)
              ..lineTo(15, 22)..lineTo(9, 22)..close(),
            stroke);
        break;

      case IconKind.shop:
        c.drawPath(
            Path()..moveTo(3, 9)..lineTo(21, 9)..lineTo(19, 20)
              ..lineTo(5, 20)..close(),
            stroke);
        c.drawPath(
            Path()..moveTo(8, 9)
              ..cubicTo(8, 5, 10, 3, 12, 3)
              ..cubicTo(14, 3, 16, 5, 16, 9),
            stroke);
        break;

      case IconKind.pause:
        c.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(6, 5, 10, 19), const Radius.circular(1.5)),
            fill);
        c.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(14, 5, 18, 19), const Radius.circular(1.5)),
            fill);
        break;

      case IconKind.play:
        c.drawPath(
            Path()..moveTo(7, 5)..lineTo(19, 12)..lineTo(7, 19)..close(),
            fill);
        break;

      case IconKind.home:
        c.drawPath(Path()..moveTo(3, 12)..lineTo(12, 3)..lineTo(21, 12), stroke);
        c.drawPath(
            Path()..moveTo(5, 10)..lineTo(5, 20)..lineTo(19, 20)..lineTo(19, 10),
            stroke);
        break;

      case IconKind.refresh:
        c.drawPath(
            Path()..moveTo(3, 12)
              ..cubicTo(3, 7, 7, 3, 12, 3)
              ..cubicTo(15, 3, 17, 4.5, 18, 5.3)
              ..lineTo(21, 8),
            stroke);
        c.drawPath(Path()..moveTo(21, 3)..lineTo(21, 8)..lineTo(16, 8), stroke);
        c.drawPath(
            Path()..moveTo(21, 12)
              ..cubicTo(21, 17, 17, 21, 12, 21)
              ..cubicTo(9, 21, 7, 19.5, 6, 18.7)
              ..lineTo(3, 16),
            stroke);
        c.drawPath(Path()..moveTo(3, 21)..lineTo(3, 16)..lineTo(8, 16), stroke);
        break;

      case IconKind.share:
        c.drawCircle(const Offset(18, 5), 3, stroke);
        c.drawCircle(const Offset(6, 12), 3, stroke);
        c.drawCircle(const Offset(18, 19), 3, stroke);
        c.drawPath(
            Path()..moveTo(8.5, 10.5)..lineTo(15.5, 6.5)
              ..moveTo(8.5, 13.5)..lineTo(15.5, 17.5),
            stroke);
        break;

      case IconKind.bomb:
        c.drawCircle(const Offset(11, 14), 7, fill);
        c.drawPath(
            Path()..moveTo(16, 9)..lineTo(19, 6),
            Paint()
              ..color = const Color(0xFFFFB800)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round);
        c.drawCircle(const Offset(9, 12), 1.5, Paint()..color = Colors.white);
        break;

      case IconKind.clock:
        c.drawCircle(const Offset(12, 12), 9, stroke);
        c.drawPath(
            Path()..moveTo(12, 7)..lineTo(12, 12)..lineTo(15, 14), stroke);
        break;

      case IconKind.check:
        c.drawPath(Path()..moveTo(5, 12)..lineTo(10, 17)..lineTo(20, 7),
            stroke..strokeWidth = 3);
        break;

      case IconKind.lock:
        c.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTRB(5, 11, 19, 21), const Radius.circular(2)),
            stroke);
        c.drawPath(
            Path()..moveTo(8, 11)..lineTo(8, 7)
              ..cubicTo(8, 4.8, 9.8, 3, 12, 3)
              ..cubicTo(14.2, 3, 16, 4.8, 16, 7)
              ..lineTo(16, 11),
            stroke);
        break;

      case IconKind.star:
        c.drawPath(
            Path()..moveTo(12, 2)..lineTo(15.09, 8.26)..lineTo(22, 9.27)
              ..lineTo(17, 14.14)..lineTo(18.18, 21.02)..lineTo(12, 17.77)
              ..lineTo(5.82, 21.02)..lineTo(7, 14.14)..lineTo(2, 9.27)
              ..lineTo(8.91, 8.26)..close(),
            fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.kind != kind || old.color != color;
}
