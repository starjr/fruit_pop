import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pop_button.dart';
import '../widgets/icons.dart';
import '../widgets/fruits/fruit_painters.dart';
import '../data/fruit_data.dart';
import '../services/local_store.dart';

/// 본 게임은 오프라인이므로 글로벌 랭킹 대신 “내 기록” 으로 동작한다.
/// 두 개의 탭을 제공한다:
///   • 베스트 — 점수 기준 상위 10판
///   • 최근  — 시간 역순 최근 20판
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0;

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _fmtTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmtDate(int ts) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.I;
    final best = store.bestScore;
    final games = _tab == 0 ? store.topScores(n: 10) : store.recentGames.take(20).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                PopButton(variant: PopButtonVariant.ghost, height: 40, width: 40, padding: EdgeInsets.zero, onTap: () => Navigator.pop(context), child: const AppIcon(IconKind.back)),
                const Expanded(child: Center(child: Text('내 기록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)))),
                const SizedBox(width: 40),
              ]),
            ),
            const SizedBox(height: 12),
            // 베스트 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.candyYellow, AppColors.candyPeach]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('BEST SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7A4A1A), letterSpacing: 0.5)),
                  Text(_fmtNum(best), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF7A4A1A), height: 1.1)),
                ])),
                Text('${games.length}판', style: const TextStyle(fontSize: 12, color: Color(0xFF7A4A1A), fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 14),
            // 탭
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(99)),
                padding: const EdgeInsets.all(4),
                child: Row(children: [
                  _tabBtn('베스트', 0),
                  _tabBtn('최근', 1),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: games.isEmpty
                ? _empty()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: games.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final g = games[i];
                      final rank = _tab == 0 ? (i + 1) : null;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))]),
                        child: Row(children: [
                          if (rank != null) ...[
                            Container(
                              width: 32, height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: rank == 1
                                    ? const LinearGradient(colors: [AppColors.candyYellow, AppColors.accentGold])
                                    : rank == 2
                                        ? const LinearGradient(colors: [AppColors.candyPinkLight, AppColors.candyPink])
                                        : rank == 3
                                            ? const LinearGradient(colors: [AppColors.candyPeach, AppColors.candyYellow])
                                            : const LinearGradient(colors: [Color(0xFFEDEDED), Color(0xFFD8D8D8)]),
                              ),
                              child: Text('$rank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: rank <= 3 ? Colors.white : AppColors.inkSoft)),
                            ),
                            const SizedBox(width: 12),
                          ],
                          FruitWidget(id: g.maxFruitId, size: 40),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_fmtNum(g.score), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.1)),
                            const SizedBox(height: 2),
                            Text('${_fruitNameSafe(g.maxFruitId)} · 콤보 ×${g.combo} · ${_fmtTime(g.elapsedSec)}', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                          ])),
                          Text(_fmtDate(g.timestamp), style: const TextStyle(fontSize: 10, color: AppColors.inkLight, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    },
                  ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final selected = _tab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.candyPink : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected ? [BoxShadow(color: AppColors.candyPink.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.inkSoft)),
      ),
    ));
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🍒', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text('아직 기록이 없어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
          SizedBox(height: 4),
          Text('한 판 끝내면 여기에 기록이 쌓입니다.', style: TextStyle(fontSize: 12, color: AppColors.inkSoft), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  String _fruitNameSafe(int id) {
    if (id < 0 || id >= fruits.length) return '-';
    return fruits[id].name;
  }
}
