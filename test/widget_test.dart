import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fruit_pop/main.dart';
import 'package:fruit_pop/services/local_store.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.init();
  });

  testWidgets('first launch shows onboarding screen', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(430, 932));

    await LocalStore.I.clearAll();
    expect(LocalStore.I.isOnboarded, isFalse);

    await tester.pumpWidget(const FruitMergeApp());
    await tester.pumpAndSettle();

    expect(find.text('환영합니다!', skipOffstage: false), findsNothing,
        reason: '두 줄 헤더라 정확 매칭이 아닐 수 있음');
    expect(find.textContaining('환영합니다'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('게임 시작'), findsNothing);

    await binding.setSurfaceSize(null);
  });

  testWidgets('after onboarding shows home screen', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(430, 932));

    await LocalStore.I.clearAll();
    await LocalStore.I.setNickname('테스터');
    await LocalStore.I.completeOnboarding();
    expect(LocalStore.I.isOnboarded, isTrue);

    await tester.pumpWidget(const FruitMergeApp());
    await tester.pumpAndSettle();

    expect(find.text('Fruit Pop'), findsOneWidget);
    expect(find.text('게임 시작'), findsOneWidget);
    expect(find.text('테스터님'), findsOneWidget);

    await binding.setSurfaceSize(null);
  });

  test('LocalStore records a game and updates best score / coins', () async {
    final s = LocalStore.I;
    await s.clearAll();
    expect(s.bestScore, 0);
    expect(s.recentGames, isEmpty);
    final initialCoins = s.coins;

    final outcome = await s.recordGame(
      score: 1000,
      maxFruitId: 6,
      combo: 4,
      merges: 12,
      elapsedSec: 30,
      mergesByOutputId: const {5: 2, 6: 1},
    );

    expect(outcome.score, 1000);
    expect(outcome.previousBest, 0);
    expect(outcome.isNewBest, true);
    expect(outcome.coinsEarned, 100); // 1000 / 10
    expect(s.bestScore, 1000);
    expect(s.recentGames.length, 1);
    expect(s.coins, initialCoins + 100);
    expect(s.bestMaxFruitReached, 6);
  });

  test('LocalStore bestMaxFruitReached keeps peak across games', () async {
    final s = LocalStore.I;
    await s.clearAll();
    expect(s.bestMaxFruitReached, 0);
    await s.recordGame(
      score: 500,
      maxFruitId: 8,
      combo: 2,
      merges: 8,
      elapsedSec: 60,
      mergesByOutputId: const {8: 1},
    );
    expect(s.bestMaxFruitReached, 8);
    await s.recordGame(
      score: 300,
      maxFruitId: 4,
      combo: 1,
      merges: 4,
      elapsedSec: 20,
      mergesByOutputId: const {},
    );
    expect(s.bestMaxFruitReached, 8);
  });

  test('completeOnboarding persists across reads', () async {
    final s = LocalStore.I;
    await s.clearAll();
    expect(s.isOnboarded, isFalse);
    await s.completeOnboarding();
    expect(s.isOnboarded, isTrue);
    await s.clearAll();
    expect(s.isOnboarded, isFalse);
  });
}
