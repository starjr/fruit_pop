import 'package:flutter/material.dart';

/// 상점/설정/게임 보드에서 공통으로 쓰는 스킨 메타.
abstract final class SkinCatalog {
  static const Map<String, String> displayNames = {
    'classic': '클래식',
    'neon': '네온 파티',
    'pastel': '파스텔 드림',
    'pixel': '8비트 픽셀',
    'sushi': '스시 셰프',
    'winter': '겨울 동화',
  };

  static String label(String id) => displayNames[id] ?? id;

  /// 장착 스킨에 맞는 보드 색감 오버레이. null 이면 추가 레이어 없음.
  static LinearGradient? boardOverlay(String id) {
    switch (id) {
      case 'neon':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C4DFF).withValues(alpha: 0.14),
            const Color(0xFFFF4081).withValues(alpha: 0.10),
          ],
        );
      case 'pastel':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE0F0).withValues(alpha: 0.50),
            const Color(0xFFE0F7FA).withValues(alpha: 0.32),
          ],
        );
      case 'pixel':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF7043).withValues(alpha: 0.12),
            const Color(0xFFFFD54F).withValues(alpha: 0.10),
          ],
        );
      case 'sushi':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF80AB).withValues(alpha: 0.12),
            const Color(0xFF69F0AE).withValues(alpha: 0.09),
          ],
        );
      case 'winter':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF81D4FA).withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.14),
          ],
        );
      default:
        return null;
    }
  }
}
