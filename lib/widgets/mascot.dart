import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 수박 마스코트 캐릭터
enum MascotMood { happy, sad, wow }

class Mascot extends StatelessWidget {
  final double size;
  final MascotMood mood;
  const Mascot({super.key, this.size = 120, this.mood = MascotMood.happy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MascotPainter(mood)),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotMood mood;
  _MascotPainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s);
    // 그림자
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60,100), width: 64, height: 12),
      Paint()..color = AppColors.ink.withValues(alpha: 0.12),
    );
    // 외곽 (수박 껍질)
    canvas.drawCircle(const Offset(60,58), 48, Paint()..color = const Color(0xFF3C9A4E));
    // 빨간 속살
    canvas.drawCircle(const Offset(60,58), 42, Paint()..color = const Color(0xFFE84266));
    // 씨
    const seedPositions = [[45,52],[60,46],[75,52],[50,68],[70,68],[60,76]];
    for (int i=0;i<seedPositions.length;i++) {
      final p = seedPositions[i];
      canvas.save();
      canvas.translate(p[0].toDouble(), p[1].toDouble());
      canvas.rotate(i*18 * 3.14159/180);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 4.4, height: 6.4), Paint()..color = const Color(0xFF3D2419));
      canvas.restore();
    }
    // 눈
    canvas.drawCircle(const Offset(48,56), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(72,56), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(49,57), 3, Paint()..color = const Color(0xFF2C1810));
    canvas.drawCircle(const Offset(73,57), 3, Paint()..color = const Color(0xFF2C1810));
    canvas.drawCircle(const Offset(50,56), 1.2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(74,56), 1.2, Paint()..color = Colors.white);
    // 볼
    canvas.drawOval(Rect.fromCenter(center: const Offset(42,68), width: 10, height: 6), Paint()..color = AppColors.candyPink.withValues(alpha: 0.6));
    canvas.drawOval(Rect.fromCenter(center: const Offset(78,68), width: 10, height: 6), Paint()..color = AppColors.candyPink.withValues(alpha: 0.6));
    // 입
    final mouth = Paint()..color = const Color(0xFF2C1810)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    if (mood == MascotMood.happy) {
      canvas.drawPath(Path()..moveTo(54,70)..quadraticBezierTo(60,76,66,70), mouth);
    } else if (mood == MascotMood.sad) {
      canvas.drawPath(Path()..moveTo(54,74)..quadraticBezierTo(60,68,66,74), mouth);
    } else {
      canvas.drawOval(Rect.fromCenter(center: const Offset(60,73), width: 6, height: 8), Paint()..color = const Color(0xFF2C1810));
    }
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.mood != mood;
}
