import 'package:flutter/material.dart';

/// 11단계 과일 메타데이터.
/// radius는 화면(픽셀) 기준 시각적 반지름. 물리 엔진은 별도 스케일링.
class FruitData {
  final int id;
  final String name;
  final double radius;
  final int score;
  final Color color;
  const FruitData({
    required this.id,
    required this.name,
    required this.radius,
    required this.score,
    required this.color,
  });
}

const fruits = <FruitData>[
  FruitData(id: 0,  name: '체리',     radius: 22,  score: 1,  color: Color(0xFFFF4D6D)),
  FruitData(id: 1,  name: '딸기',     radius: 28,  score: 3,  color: Color(0xFFFF6B8A)),
  FruitData(id: 2,  name: '포도',     radius: 36,  score: 6,  color: Color(0xFF9B7BD8)),
  FruitData(id: 3,  name: '데코폰',   radius: 44,  score: 10, color: Color(0xFFFFA53E)),
  FruitData(id: 4,  name: '감',       radius: 54,  score: 15, color: Color(0xFFFF7A2B)),
  FruitData(id: 5,  name: '사과',     radius: 66,  score: 21, color: Color(0xFFE8434B)),
  FruitData(id: 6,  name: '배',       radius: 80,  score: 28, color: Color(0xFFE8C868)),
  FruitData(id: 7,  name: '복숭아',   radius: 96,  score: 36, color: Color(0xFFFFB098)),
  FruitData(id: 8,  name: '파인애플', radius: 112, score: 45, color: Color(0xFFFFD93D)),
  FruitData(id: 9,  name: '멜론',     radius: 132, score: 55, color: Color(0xFFA8D86A)),
  FruitData(id: 10, name: '수박',     radius: 156, score: 66, color: Color(0xFF4CAF50)),
];
