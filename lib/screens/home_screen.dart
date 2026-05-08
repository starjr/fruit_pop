import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pop_button.dart';
import '../widgets/icons.dart';
import '../widgets/mascot.dart';
import '../widgets/fruits/fruit_painters.dart';
import '../services/local_store.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  Future<void> _open(Widget Function() builder) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => builder()));
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.I;
    final nickname = store.nickname;
    final initial = store.nicknameInitial;
    final coins = store.coins;
    final best = store.bestScore;
    final ch = store.dailyChallenge;
    final progressFrac = ch.target == 0
        ? 0.0
        : (ch.progress / ch.target).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(top: 30, left: -20, child: Opacity(opacity: 0.55, child: FruitWidget(id: 2, size: 70))),
              const Positioned(top: 90, right: -10, child: Opacity(opacity: 0.5, child: FruitWidget(id: 1, size: 60))),
              const Positioned(top: 510, left: -25, child: Opacity(opacity: 0.45, child: FruitWidget(id: 4, size: 90))),
              const Positioned(top: 470, right: -30, child: Opacity(opacity: 0.5, child: FruitWidget(id: 5, size: 100))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    Row(children: [
                      SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [AppColors.candyPeach, AppColors.candyPink]),
                            ),
                            alignment: Alignment.center,
                            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            const Text('안녕하세요', style: TextStyle(fontSize: 11, color: AppColors.inkLight, height: 1)),
                            Text('$nickname님', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                          ]),
                        ]),
                      ),
                      const Spacer(),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 18, height: 18, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFFFE38A), Color(0xFFFFB800)]))),
                          const SizedBox(width: 6),
                          Text(_fmt(coins), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7A4A1A))),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(999)),
                      child: const Text('FRUIT POP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkSoft, letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Fruit Pop', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: Color(0xFFD9588A), height: 1, shadows: [Shadow(color: AppColors.candyPinkLight, offset: Offset(0, 4))])),
                    const SizedBox(height: 8),
                    const Text('합치고 또 합쳐서 수박을 만들어요', style: TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Mascot(size: 170),
                        const SizedBox(height: 12),
                        SoftCard(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const AppIcon(IconKind.trophy, size: 20),
                            const SizedBox(width: 14),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('BEST SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.inkLight, height: 1, letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              Text(_fmt(best), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1)),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                    PopButton(
                      height: 64,
                      width: double.infinity,
                      onTap: () => _open(() => const GameScreen()),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                        AppIcon(IconKind.play, size: 22, color: Colors.white),
                        SizedBox(width: 10),
                        Text('게임 시작', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: PopButton(
                        variant: PopButtonVariant.secondary, height: 52,
                        onTap: () => _open(() => const LeaderboardScreen()),
                        child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          AppIcon(IconKind.trophy, size: 18, color: Color(0xFF7A4A1A)),
                          SizedBox(width: 6),
                          Text('내 기록', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ]),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: PopButton(
                        variant: PopButtonVariant.secondary, height: 52,
                        onTap: () => _open(() => const ShopScreen()),
                        child: const Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          AppIcon(IconKind.shop, size: 18, color: Color(0xFF7A4A1A)),
                          SizedBox(width: 6),
                          Text('상점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ]),
                      )),
                      const SizedBox(width: 10),
                      PopButton(
                        variant: PopButtonVariant.ghost, height: 52, width: 52, padding: EdgeInsets.zero,
                        onTap: () => _open(() => const SettingsScreen()),
                        child: const AppIcon(IconKind.settings, size: 22),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.candyPinkLight, AppColors.candyYellowLight]),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
                        boxShadow: [BoxShadow(color: AppColors.candyPink.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [AppColors.candyPink, AppColors.candyPeach])),
                          alignment: Alignment.center,
                          child: const Text('🎯', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Text('오늘의 챌린지', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                            const SizedBox(width: 6),
                            if (ch.completed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.mintShadow, borderRadius: BorderRadius.circular(99)),
                                child: const Text('완료', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                          ]),
                          Text('${ch.title} · 보상 ${ch.reward}🪙', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: progressFrac, minHeight: 5,
                              backgroundColor: Colors.white.withValues(alpha: 0.7),
                              valueColor: const AlwaysStoppedAnimation(AppColors.candyPink),
                            ),
                          ),
                        ])),
                        const SizedBox(width: 8),
                        Text('${ch.progress}/${ch.target}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
