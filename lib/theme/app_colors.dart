import 'package:flutter/material.dart';

/// 캔디 컬러 팔레트 — 디자인 시스템과 1:1 매칭
class AppColors {
  // 캔디 컬러
  static const candyPink = Color(0xFFFF8FB1);
  static const candyPinkLight = Color(0xFFFFD6E4);
  static const candyPinkSoft = Color(0xFFFFF0F5);
  static const candyPeach = Color(0xFFFFB088);
  static const candyYellow = Color(0xFFFFD66B);
  static const candyYellowLight = Color(0xFFFFF1B8);
  static const candyMint = Color(0xFF8FE3C8);
  static const candySky = Color(0xFFA5D8FF);
  static const candyLilac = Color(0xFFC7B8F0);
  static const candyCream = Color(0xFFFFF8E7);

  // 게임 보드
  static const boardBg = Color(0xFFFFF6E0);
  static const boardBgLight = Color(0xFFFFFBF0);
  static const boardRim = Color(0xFFF4C77E);
  static const boardRimDark = Color(0xFFC9924B);

  // 배경 그라데이션
  static const bgSkyTop = Color(0xFFFFE5F1);
  static const bgSkyMid = Color(0xFFFFEFD6);
  static const bgSkyBot = Color(0xFFDCF4FF);

  // 텍스트
  static const ink = Color(0xFF4A2E2A);
  static const inkSoft = Color(0xFF7A5A55);
  static const inkLight = Color(0xFFB89E97);
  static const cream = Color(0xFFFFF8E7);

  // 강조
  static const accentCoral = Color(0xFFFF6B6B);
  static const accentGold = Color(0xFFFFB800);
  static const accentPurple = Color(0xFF9B7BD8);

  // 버튼 그라데이션
  static const primaryTop = Color(0xFFFF9DBE);
  static const primaryBot = Color(0xFFFF7BA8);
  static const primaryShadow = Color(0xFFD9588A);

  static const secondaryTop = Color(0xFFFFE4A3);
  static const secondaryBot = Color(0xFFFFD06B);
  static const secondaryShadow = Color(0xFFD9A040);
  static const secondaryText = Color(0xFF7A4A1A);

  static const mintTop = Color(0xFFB5EED8);
  static const mintBot = Color(0xFF7DD9B5);
  static const mintShadow = Color(0xFF4FAB87);
  static const mintText = Color(0xFF1F5C44);

  static LinearGradient bgGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgSkyTop, bgSkyMid, bgSkyBot],
  );

  // Legacy alias used by existing theme setup.
  static const bg = bgSkyTop;
}
