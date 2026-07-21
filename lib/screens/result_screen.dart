import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../data/fruit_data.dart';
import '../widgets/pop_button.dart';
import '../widgets/icons.dart';
import '../widgets/mascot.dart';
import '../widgets/fruits/fruit_painters.dart';
import '../widgets/coupang_banner.dart';
import '../widgets/coupang_affiliate_button.dart';
import '../data/coupang_config.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int previousBest;
  final int maxFruitId;
  final int combo;
  final int merges;
  final String time;
  final bool isNewBest;
  final int coinsEarned;
  final bool challengeCompleted;
  final int challengeRewardCoins;
  const ResultScreen({
    super.key,
    required this.score,
    required this.previousBest,
    required this.maxFruitId,
    required this.combo,
    required this.merges,
    required this.time,
    required this.isNewBest,
    this.coinsEarned = 0,
    this.challengeCompleted = false,
    this.challengeRewardCoins = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Container(
          color: AppColors.ink.withValues(alpha: 0.45),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  Expanded(child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 50, bottom: 8),
                    child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      WhiteCard(
                        padding: const EdgeInsets.fromLTRB(22, 60, 22, 18),
                        child: Column(children: [
                          if (isNewBest)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.candyYellow, AppColors.candyPeach]),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: const Text('🎉 신기록 달성!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7A4A1A))),
                            ),
                          const SizedBox(height: 10),
                          const Text('FINAL SCORE', style: TextStyle(fontSize: 13, color: AppColors.inkLight, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(_fmt(score), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700, color: Color(0xFFD9588A), height: 1, shadows: [Shadow(color: AppColors.candyPinkLight, offset: Offset(0, 4))])),
                          const SizedBox(height: 4),
                          Text('이전 최고: ${_fmt(previousBest)}', style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                          const SizedBox(height: 20),
                          // 통계
                          Row(children: [
                            _stat('시간', time),
                            const SizedBox(width: 8),
                            _stat('콤보', '×$combo'),
                            const SizedBox(width: 8),
                            _stat('합치기', '$merges'),
                          ]),
                          const SizedBox(height: 18),
                          // 도달 과일
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.candyYellowLight, AppColors.candyPinkLight]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('🏆 가장 큰 과일', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                              const SizedBox(height: 8),
                              Row(children: [
                                FruitWidget(id: maxFruitId, size: 56),
                                const SizedBox(width: 10),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(_fruitName(maxFruitId), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                                  Text(_fruitSubtitle(maxFruitId), style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                                ]),
                              ]),
                              const SizedBox(height: 10),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                for (final id in [6, 7, 8, 9, 10])
                                  Opacity(
                                    opacity: id <= maxFruitId ? 1 : 0.3,
                                    child: FruitWidget(id: id, size: id == maxFruitId ? 34 : 24),
                                  ),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: 14),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('+ $coinsEarned🪙', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                          ]),
                          if (challengeCompleted) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.candyMint, AppColors.mintBot]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Text('🎯', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text('데일리 챌린지 완료! +$challengeRewardCoins🪙', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mintText)),
                              ]),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const CoupangBanner(),
                        ]),
                      ),
                      const Positioned(top: -50, left: 0, right: 0, child: Center(child: Mascot(size: 110, mood: MascotMood.wow))),
                    ],
                  ))),
                  const SizedBox(height: 8),
                  PopButton(
                    height: 60, width: double.infinity,
                    onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      AppIcon(IconKind.refresh, size: 22, color: Colors.white),
                      SizedBox(width: 10),
                      Text('다시 도전', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: PopButton(
                      variant: PopButtonVariant.ghost, height: 48,
                      onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                        AppIcon(IconKind.home, size: 18),
                        SizedBox(width: 6),
                        Text('홈으로', style: TextStyle(fontSize: 13)),
                      ]),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: PopButton(
                      variant: PopButtonVariant.ghost, height: 48,
                      onTap: () => _shareScore(context),
                      child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                        AppIcon(IconKind.share, size: 18),
                        SizedBox(width: 6),
                        Text('공유', style: TextStyle(fontSize: 13)),
                      ]),
                    )),
                  ]),
                  const SizedBox(height: 10),
                  CoupangAffiliateButton(
                    showDisclosure: !CoupangConfig.hasBannerAd,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String k, String v) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.candyPinkLight, width: 1.5),
        ),
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(k, style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Future<void> _shareScore(BuildContext context) async {
    final text = '🍉 Fruit Pop\n'
        '점수: ${_fmt(score)}\n'
        '가장 큰 과일: ${_fruitName(maxFruitId)}\n'
        '콤보 ×$combo · 합치기 $merges · 시간 $time';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('점수 요약을 클립보드에 복사했어요')),
    );
  }

  String _fruitName(int id) {
    if (id < 0 || id >= fruits.length) return '-';
    return fruits[id].name;
  }

  String _fruitSubtitle(int id) {
    final remain = (fruits.length - 1) - id;
    if (remain <= 0) return '최종 과일에 도달했어요!';
    return '수박까지 $remain단계 남음!';
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
