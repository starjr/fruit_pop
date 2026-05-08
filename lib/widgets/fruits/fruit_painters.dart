import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 11종 과일 CustomPainter
/// 각 painter는 100x100 좌표계에서 그리고, scale로 size에 맞춤.
///
/// 각 painter는 본체의 시각 중심(visualCenter)과 반지름(visualRadius)을
/// 노출한다. paint() 단계에서 이 값을 사용해 모든 과일이 size 박스의
/// 정확한 중심에 같은 시각적 반지름으로 정렬되도록 정규화한다.

class FruitVisual {
  const FruitVisual({
    required this.cx,
    required this.cy,
    required this.r,
    this.topReach = 0,
  });

  final double cx;
  final double cy;
  final double r;
  // 본체 위로 추가로 그려지는 줄기/잎의 세로 길이.
  // FruitWidget에서 박스 안에 잎까지 모두 담을 때 사용한다.
  final double topReach;
}

abstract class _FruitPainter extends CustomPainter {
  FruitVisual get visual;
  void drawFruit(Canvas canvas);

  /// 게임 보드용: 본체 바닥을 박스 바닥에 정렬. 줄기/잎은 박스 위로 삐져나갈 수 있다.
  @override
  void paint(Canvas canvas, Size size) {
    final v = visual;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = (size.width / 100) * (50 / v.r);
    canvas.scale(scale);
    canvas.translate(-v.cx, -v.cy);
    drawFruit(canvas);
    canvas.restore();
  }

  /// 아이콘/카드용: 본체 + 줄기/잎이 모두 박스 안에 들어오도록 축소하고
  /// 세로 중앙에 배치한다.
  void paintFitted(Canvas canvas, Size size) {
    final v = visual;
    final contentHeight = 2 * v.r + v.topReach;
    final contentWidth = 2 * v.r;
    final scale = math.min(
      size.width / contentWidth,
      size.height / contentHeight,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    final contentCenterY = v.cy - v.topReach / 2;
    canvas.translate(-v.cx, -contentCenterY);
    drawFruit(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void highlight(Canvas c, double cx, double cy, double rx, double ry, [double op = 0.55]) {
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.white.withValues(alpha: op),
    );
  }
}

// ── 0. 체리 ──
// body 너비 = 76 (x=12~88), 본체 박스 y=14~90, bodyBottom=90.
class CherryPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 52, r: 38, topReach: 8);
  @override
  void drawFruit(Canvas c) {
    final stem = Paint()..color = const Color(0xFF7B4A2B)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    c.drawPath(Path()..moveTo(50, 18)..quadraticBezierTo(38, 8, 28, 14), stem);
    c.drawPath(Path()..moveTo(50, 18)..quadraticBezierTo(62, 10, 72, 16), stem);
    final leaf = Paint()..color = const Color(0xFF7DC97F);
    c.drawPath(Path()..moveTo(28,14)..quadraticBezierTo(18,6,12,18)..quadraticBezierTo(18,28,30,22)..close(), leaf);
    final cherry = Paint()..color = const Color(0xFFC32A3F);
    c.drawCircle(const Offset(34,62), 22, cherry);
    c.drawCircle(const Offset(66,68), 22, cherry);
    final shine = Paint()..shader = const RadialGradient(center: Alignment(-0.2,-0.3), colors:[Color(0xB3FF6680), Color(0x00FF4D6D)]).createShader(const Rect.fromLTWH(12,40,44,44));
    c.drawCircle(const Offset(34,62), 22, shine);
    c.drawCircle(const Offset(66,68), 22, shine);
    highlight(c, 28, 54, 6, 4);
    highlight(c, 60, 60, 6, 4);
  }
}

// ── 1. 딸기 ──
// body 70×56 (세로로 긴 하트형). v.r=35 로 두어 박스에 본체 전체가 들어오게 한다.
class StrawberryPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 57, r: 35, topReach: 22);
  @override
  void drawFruit(Canvas c) {
    final body = Paint()..color = const Color(0xFFE84266);
    c.drawPath(Path()..moveTo(50,22)..quadraticBezierTo(22,28,22,56)..quadraticBezierTo(22,88,50,92)..quadraticBezierTo(78,88,78,56)..quadraticBezierTo(78,28,50,22)..close(), body);
    const seeds = [[38,42],[52,40],[66,44],[34,54],[48,52],[62,56],[42,66],[56,64],[40,78],[54,78],[68,68]];
    final seedP = Paint()..color = const Color(0xFFFFF1B8);
    for (var i=0; i<seeds.length; i++) {
      final s = seeds[i];
      c.save();
      c.translate(s[0].toDouble(), s[1].toDouble());
      c.rotate(((i*23)%60-30) * math.pi/180);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: 4.4, height: 6), seedP);
      c.restore();
    }
    // 잎
    final leaf = Paint()..color = const Color(0xFF6FBF73);
    c.save();
    c.translate(50, 22);
    final leafPath = Path()
      ..moveTo(0,0)..lineTo(-18,-6)..lineTo(-8,-2)..lineTo(-16,-14)..lineTo(-4,-6)..lineTo(-8,-20)
      ..lineTo(0,-8)..lineTo(8,-20)..lineTo(4,-6)..lineTo(16,-14)..lineTo(8,-2)..lineTo(18,-6)..close();
    c.drawPath(leafPath, leaf);
    c.drawCircle(const Offset(0,-2), 3, Paint()..color=const Color(0xFF4D9551));
    c.restore();
    highlight(c, 36, 42, 8, 4, 0.35);
  }
}

// ── 2. 포도 ──
// body 64×66, bodyBottom=84.
class GrapePainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 51, r: 33, topReach: 10);
  @override
  void drawFruit(Canvas c) {
    c.drawPath(Path()..moveTo(50,26)..lineTo(50,14), Paint()..color=const Color(0xFF7B4A2B)..strokeWidth=2.5..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    c.drawPath(Path()..moveTo(50,18)..quadraticBezierTo(38,10,32,14)..quadraticBezierTo(36,22,50,22)..close(), Paint()..color=const Color(0xFF6FBF73));
    const positions = [[50,28],[38,38],[62,38],[28,50],[50,50],[72,50],[38,62],[62,62],[50,74]];
    final dark = Paint()..color = const Color(0xFF5A3D8C);
    final light = Paint()..color = const Color(0xFF7B5AB8);
    final shine = Paint()..color = const Color(0xFFB49EE0).withValues(alpha: 0.7);
    for (final p in positions) {
      c.drawCircle(Offset(p[0].toDouble(), p[1].toDouble()), 10, dark);
      c.drawCircle(Offset(p[0].toDouble(), p[1].toDouble()), 9, light);
      c.drawOval(Rect.fromCenter(center: Offset(p[0]-2.5, p[1]-3), width: 6, height: 4), shine);
    }
  }
}

// ── 3. 데코폰 ──
// body 72×68 (가로로 약간 더 김), bodyBottom=92. v.r=36 (가로 기준).
class DekoponPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 56, r: 36, topReach: 14);
  @override
  void drawFruit(Canvas c) {
    c.drawCircle(const Offset(50,22), 8, Paint()..color=const Color(0xFFFFA53E));
    c.drawPath(Path()..moveTo(50,16)..quadraticBezierTo(42,8,38,14)..quadraticBezierTo(44,22,50,22)..close(), Paint()..color=const Color(0xFF7DC97F));
    c.drawPath(Path()..moveTo(50,16)..quadraticBezierTo(58,8,62,14)..quadraticBezierTo(56,22,50,22)..close(), Paint()..color=const Color(0xFF6FBF73));
    c.drawOval(const Rect.fromLTWH(14,24,72,68), Paint()..color=const Color(0xFFFF8E1F));
    const dots = [[30,50],[42,46],[58,46],[70,50],[28,62],[44,60],[60,60],[72,64],[38,76],[58,76]];
    final dot = Paint()..color = const Color(0xFFD9701B).withValues(alpha: 0.5);
    for (final d in dots) {
      c.drawCircle(Offset(d[0].toDouble(), d[1].toDouble()), 1.2, dot);
    }
    highlight(c, 36, 46, 10, 6, 0.45);
  }
}

// ── 4. 감 ──
// body 64×68, bodyBottom=92. v.r=34 (세로 기준).
class PersimmonPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 58, r: 34, topReach: 14);
  @override
  void drawFruit(Canvas c) {
    c.drawPath(Path()..moveTo(50,24)..quadraticBezierTo(18,24,18,56)..quadraticBezierTo(18,92,50,92)..quadraticBezierTo(82,92,82,56)..quadraticBezierTo(82,24,50,24)..close(), Paint()..color=const Color(0xFFFF6A1F));
    c.drawPath(Path()..moveTo(30,62)..quadraticBezierTo(50,70,70,62), Paint()..color=const Color(0xFFD44A0A).withValues(alpha: 0.4)..strokeWidth=1.5..style=PaintingStyle.stroke);
    c.save();
    c.translate(50,26);
    c.drawPath(Path()..moveTo(0,0)..lineTo(-16,-4)..quadraticBezierTo(-18,4,-8,6)..close(), Paint()..color=const Color(0xFF6B8E5A));
    c.drawPath(Path()..moveTo(0,0)..lineTo(16,-4)..quadraticBezierTo(18,4,8,6)..close(), Paint()..color=const Color(0xFF7B9E66));
    c.drawPath(Path()..moveTo(0,0)..lineTo(-8,-14)..quadraticBezierTo(0,-16,4,-8)..close(), Paint()..color=const Color(0xFF83A66E));
    c.drawPath(Path()..moveTo(0,0)..lineTo(10,-12)..quadraticBezierTo(4,-18,-2,-10)..close(), Paint()..color=const Color(0xFF8FAE74));
    c.drawCircle(Offset.zero, 4, Paint()..color=const Color(0xFF5C7A4F));
    c.restore();
    highlight(c, 32, 42, 10, 6, 0.4);
  }
}

// ── 5. 사과 ──
// body 63×66, bodyBottom=90. v.r=33 (세로 기준).
class ApplePainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 57, r: 33, topReach: 18);
  @override
  void drawFruit(Canvas c) {
    final body = Path()
      ..moveTo(50,24)
      ..quadraticBezierTo(30,20,22,36)..quadraticBezierTo(14,56,24,78)
      ..quadraticBezierTo(34,92,50,90)..quadraticBezierTo(66,92,76,78)
      ..quadraticBezierTo(86,56,78,36)..quadraticBezierTo(70,20,50,24)..close();
    c.drawPath(body, Paint()..color=const Color(0xFFD8333A));
    c.drawPath(Path()..moveTo(50,24)..quadraticBezierTo(50,14,56,10), Paint()..color=const Color(0xFF5A3A1F)..strokeWidth=3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    c.drawPath(Path()..moveTo(54,14)..quadraticBezierTo(66,8,72,16)..quadraticBezierTo(64,22,54,16)..close(), Paint()..color=const Color(0xFF7DC97F));
    highlight(c, 34, 42, 10, 14, 0.4);
  }
}

// ── 6. 배 ──
// body 56×72 (세로로 긴 배 모양), bodyBottom=90. v.r=36 으로 본체가 박스에 들어오게.
class PearPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 54, r: 36, topReach: 16);
  @override
  void drawFruit(Canvas c) {
    final body = Path()
      ..moveTo(50,18)
      ..quadraticBezierTo(42,18,40,26)..quadraticBezierTo(36,36,32,42)
      ..quadraticBezierTo(22,52,22,66)..quadraticBezierTo(22,88,50,90)
      ..quadraticBezierTo(78,88,78,66)..quadraticBezierTo(78,52,68,42)
      ..quadraticBezierTo(64,36,60,26)..quadraticBezierTo(58,18,50,18)..close();
    c.drawPath(body, Paint()..color=const Color(0xFFD9B845));
    const dots = [[36,52],[60,48],[44,64],[56,72],[68,60],[28,68],[48,80]];
    final p = Paint()..color = const Color(0xFF9C8530).withValues(alpha: 0.5);
    for (final d in dots) {
      c.drawCircle(Offset(d[0].toDouble(), d[1].toDouble()), 0.8, p);
    }
    c.drawPath(Path()..moveTo(50,18)..quadraticBezierTo(50,10,54,6), Paint()..color=const Color(0xFF5A3A1F)..strokeWidth=2.5..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    c.drawPath(Path()..moveTo(52,10)..quadraticBezierTo(60,4,64,10)..quadraticBezierTo(60,16,52,12)..close(), Paint()..color=const Color(0xFF7DC97F));
    highlight(c, 36, 52, 8, 14, 0.45);
  }
}

// ── 7. 복숭아 ──
// body 64×70, bodyBottom=92. v.r=35 (세로 기준).
class PeachPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 57, r: 35, topReach: 14);
  @override
  void drawFruit(Canvas c) {
    final body = Path()
      ..moveTo(50,26)..quadraticBezierTo(38,18,30,28)..quadraticBezierTo(18,36,18,56)
      ..quadraticBezierTo(18,84,50,92)..quadraticBezierTo(82,84,82,56)
      ..quadraticBezierTo(82,36,70,28)..quadraticBezierTo(62,18,50,26)..close();
    c.drawPath(body, Paint()..color=const Color(0xFFFFB5A0));
    c.drawPath(Path()..moveTo(50,28)..quadraticBezierTo(48,60,50,90), Paint()..color=const Color(0xFFE89580).withValues(alpha: 0.5)..strokeWidth=1.5..style=PaintingStyle.stroke);
    c.drawPath(Path()..moveTo(50,26)..quadraticBezierTo(56,14,68,16)..quadraticBezierTo(64,26,52,28)..close(), Paint()..color=const Color(0xFF6FBF73));
    c.drawOval(const Rect.fromLTWH(48,34,28,20), Paint()..color=const Color(0xFFFF8A6B).withValues(alpha: 0.35));
    highlight(c, 34, 42, 10, 14, 0.5);
  }
}

// ── 8. 파인애플 ──
// body 64×68, bodyBottom=94. v.r=34 (세로 기준).
class PineapplePainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 60, r: 34, topReach: 28);
  @override
  void drawFruit(Canvas c) {
    // 잎
    c.drawPath(Path()..moveTo(50,28)..lineTo(36,4)..lineTo(44,16)..lineTo(32,8)..lineTo(42,22)..close(), Paint()..color=const Color(0xFF5FAF5F));
    c.drawPath(Path()..moveTo(50,28)..lineTo(64,4)..lineTo(56,16)..lineTo(68,8)..lineTo(58,22)..close(), Paint()..color=const Color(0xFF6FBF73));
    c.drawPath(Path()..moveTo(50,26)..lineTo(50,0)..lineTo(46,14)..lineTo(50,4)..lineTo(54,14)..close(), Paint()..color=const Color(0xFF7DC97F));
    // 몸체
    c.drawOval(const Rect.fromLTWH(18,26,64,68), Paint()..color=const Color(0xFFE8B23D));
    final grid = Paint()..color=const Color(0xFFA8771F).withValues(alpha: 0.6)..strokeWidth=1..style=PaintingStyle.stroke;
    c.drawPath(Path()..moveTo(20,50)..quadraticBezierTo(35,40,50,50)..quadraticBezierTo(65,40,80,50), grid);
    c.drawPath(Path()..moveTo(20,65)..quadraticBezierTo(35,55,50,65)..quadraticBezierTo(65,55,80,65), grid);
    c.drawPath(Path()..moveTo(20,80)..quadraticBezierTo(35,70,50,80)..quadraticBezierTo(65,70,80,80), grid);
    const dots = [[35,50],[50,50],[65,50],[28,65],[42,65],[58,65],[72,65],[35,80],[50,80],[65,80]];
    final dot = Paint()..color=const Color(0xFF5C3F12);
    for (final d in dots) {
      c.drawCircle(Offset(d[0].toDouble(), d[1].toDouble()), 1.2, dot);
    }
    highlight(c, 32, 42, 8, 6, 0.35);
  }
}

// ── 9. 멜론 ──
// body 84×84 (원), bodyBottom=94.
class MelonPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 52, r: 42, topReach: 12);
  @override
  void drawFruit(Canvas c) {
    c.drawCircle(const Offset(50,52), 42, Paint()..color=const Color(0xFF9DCD63));
    final net = Paint()..color=Colors.white.withValues(alpha: 0.6)..strokeWidth=0.7..style=PaintingStyle.stroke;
    for (int i=0;i<8;i++) {
      c.drawPath(Path()..moveTo(10.0+i*10,30)..quadraticBezierTo(20.0+i*5,40.0+i*4,15.0+i*8,70), net);
    }
    for (int i=0;i<6;i++) {
      c.drawPath(Path()..moveTo(12,22.0+i*10)..quadraticBezierTo(50,28.0+i*9,88,22.0+i*10), net);
    }
    c.drawPath(Path()..moveTo(50,10)..quadraticBezierTo(50,4,56,2), Paint()..color=const Color(0xFF5A3A1F)..strokeWidth=2.5..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    c.drawPath(Path()..moveTo(54,4)..quadraticBezierTo(64,0,66,8)..quadraticBezierTo(60,12,54,8)..close(), Paint()..color=const Color(0xFF7DC97F));
    highlight(c, 34, 36, 10, 8, 0.45);
  }
}

// ── 10. 수박 ──
// body 84×84 (원), bodyBottom=94.
class WatermelonPainter extends _FruitPainter {
  @override
  FruitVisual get visual =>
      const FruitVisual(cx: 50, cy: 52, r: 42, topReach: 8);
  @override
  void drawFruit(Canvas c) {
    c.drawCircle(const Offset(50,52), 42, Paint()..color=const Color(0xFF3C9A4E));
    final stripe = Paint()..color=const Color(0xFF1F6B30).withValues(alpha: 0.55);
    c.drawPath(Path()..moveTo(50,10)..quadraticBezierTo(30,30,24,80)..quadraticBezierTo(26,84,30,86)..quadraticBezierTo(38,36,56,12)..quadraticBezierTo(54,10,50,10)..close(), stripe);
    c.drawPath(Path()..moveTo(70,14)..quadraticBezierTo(60,36,76,84)..quadraticBezierTo(80,82,84,78)..quadraticBezierTo(76,40,76,16)..quadraticBezierTo(74,12,70,14)..close(), stripe);
    c.drawPath(Path()..moveTo(14,40)..quadraticBezierTo(38,50,34,84)..quadraticBezierTo(30,84,26,82)..quadraticBezierTo(30,56,12,46)..quadraticBezierTo(12,42,14,40)..close(), stripe);
    c.drawPath(Path()..moveTo(86,40)..quadraticBezierTo(70,56,78,84)..quadraticBezierTo(82,82,84,78)..quadraticBezierTo(80,60,88,46)..quadraticBezierTo(88,42,86,40)..close(), stripe);
    c.drawPath(Path()..moveTo(50,10)..quadraticBezierTo(52,4,58,4), Paint()..color=const Color(0xFF5A3A1F)..strokeWidth=2.5..style=PaintingStyle.stroke..strokeCap=StrokeCap.round);
    highlight(c, 34, 32, 12, 8, 0.35);
  }
}

/// id로 painter 가져오기
CustomPainter fruitPainter(int id) {
  switch (id) {
    case 0: return CherryPainter();
    case 1: return StrawberryPainter();
    case 2: return GrapePainter();
    case 3: return DekoponPainter();
    case 4: return PersimmonPainter();
    case 5: return ApplePainter();
    case 6: return PearPainter();
    case 7: return PeachPainter();
    case 8: return PineapplePainter();
    case 9: return MelonPainter();
    case 10: return WatermelonPainter();
    default: return CherryPainter();
  }
}

/// 캔버스에 직접 정규화된 과일을 그리는 헬퍼.
/// (center 기준, radius = 본체 시각 반지름)
///
/// 줄기/잎이 인접한 다른 과일을 침범하지 않도록 자기 박스 + 매우 작은
/// 위쪽 여유에만 그려지도록 클립한다. (본체는 v.r 가 max(half-width,
/// half-height) 로 설정되어 있어 박스 안에 모두 들어온다.)
void paintFruitOnCanvas(Canvas canvas, int id, Offset center, double radius) {
  final p = fruitPainter(id);
  canvas.save();
  // 줄기·잎의 일부만 살짝 보일 수 있게 매우 작은 여유만 둔다.
  final topPad = radius * 0.08;
  canvas.clipRect(
    Rect.fromLTWH(
      center.dx - radius,
      center.dy - radius - topPad,
      radius * 2,
      radius * 2 + topPad,
    ),
  );
  canvas.translate(center.dx - radius, center.dy - radius);
  p.paint(canvas, Size(radius * 2, radius * 2));
  canvas.restore();
}

/// HUD/카드/리스트 등 UI에서 과일 아이콘으로 사용할 때, 본체와 잎/줄기가
/// 모두 박스 안에 들어오도록 정렬한다.
class _FruitDisplayPainter extends CustomPainter {
  _FruitDisplayPainter(this.delegate);
  final _FruitPainter delegate;

  @override
  void paint(Canvas canvas, Size size) {
    delegate.paintFitted(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _FruitDisplayPainter oldDelegate) =>
      oldDelegate.delegate.runtimeType != delegate.runtimeType;
}

/// 과일 위젯 — id와 size로 사용
class FruitWidget extends StatelessWidget {
  final int id;
  final double size;
  final double rotation;
  const FruitWidget({super.key, required this.id, required this.size, this.rotation = 0});

  @override
  Widget build(BuildContext context) {
    final painter = fruitPainter(id) as _FruitPainter;
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FruitDisplayPainter(painter)),
      ),
    );
  }
}
