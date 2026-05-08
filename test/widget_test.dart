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

  testWidgets('app boots and shows home title', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const ui.Size(430, 932));

    await tester.pumpWidget(const FruitMergeApp());
    await tester.pumpAndSettle();

    expect(find.text('Fruit Pop'), findsOneWidget);
    expect(find.text('게임 시작'), findsOneWidget);

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
  });
}
