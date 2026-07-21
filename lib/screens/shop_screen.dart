import 'package:flutter/material.dart';
import '../data/fruit_data.dart';
import '../theme/app_colors.dart';
import '../widgets/pop_button.dart';
import '../widgets/icons.dart';
import '../services/local_store.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _SkinDef {
  final String id;
  final String name;
  final String sub;
  final int price;
  /// null 이면 항상 구매 가능. 값이 있으면 역대 최대 과일 id가 이 값 이상일 때 해금.
  final int? unlockAfterMaxFruitId;
  final Color g1;
  final Color g2;
  final String emoji;
  const _SkinDef({
    required this.id,
    required this.name,
    required this.sub,
    required this.price,
    required this.g1,
    required this.g2,
    required this.emoji,
    this.unlockAfterMaxFruitId,
  });
}

class _ShopScreenState extends State<ShopScreen> {
  static const List<_SkinDef> _skins = [
    _SkinDef(id: 'classic', name: '클래식', sub: '기본 과일', price: 0, g1: AppColors.candyYellow, g2: AppColors.candyPeach, emoji: '🍎'),
    _SkinDef(id: 'neon', name: '네온 파티', sub: '밤하늘 컬러', price: 1200, g1: AppColors.accentPurple, g2: AppColors.candyPink, emoji: '✨'),
    _SkinDef(id: 'pastel', name: '파스텔 드림', sub: '몽글몽글', price: 800, g1: AppColors.candyPinkLight, g2: AppColors.candySky, emoji: '🌸'),
    _SkinDef(id: 'pixel', name: '8비트 픽셀', sub: '레트로 게임', price: 1500, g1: AppColors.accentCoral, g2: AppColors.candyYellow, emoji: '👾'),
    _SkinDef(id: 'sushi', name: '스시 셰프', sub: '과일 → 초밥', price: 2000, g1: AppColors.candyPink, g2: AppColors.candyMint, emoji: '🍣', unlockAfterMaxFruitId: 8),
    _SkinDef(id: 'winter', name: '겨울 동화', sub: '얼음 과일', price: 1800, g1: AppColors.candySky, g2: Colors.white, emoji: '❄️'),
  ];

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Future<void> _onTryBuy(_SkinDef s) async {
    final store = LocalStore.I;
    if (_isMasteryLocked(s, store)) return;
    final messenger = ScaffoldMessenger.of(context);
    if (store.coins < s.price) {
      messenger.showSnackBar(
        const SnackBar(content: Text('코인이 부족해요. 게임을 더 플레이해 보세요!')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${s.name} 구매'),
        content: Text('${_fmtNum(s.price)} 코인을 사용해 ${s.name} 스킨을 구매할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('구매')),
        ],
      ),
    );
    if (ok != true) return;
    final success = await store.buySkin(s.id, s.price);
    if (success) {
      await store.equipSkin(s.id);
    }
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(SnackBar(
      content: Text(success ? '${s.name} 구매 & 장착 완료' : '구매에 실패했어요.'),
    ));
  }

  Future<void> _onEquip(_SkinDef s) async {
    await LocalStore.I.equipSkin(s.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.I;
    final coins = store.coins;
    final owned = store.ownedSkins;
    final equipped = store.equippedSkin;

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
                const Expanded(child: Center(child: Text('상점', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)))),
                SoftCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFFFE38A), Color(0xFFFFB800)]))),
                    const SizedBox(width: 6),
                    Text(_fmtNum(coins), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7A4A1A))),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.candyPink, AppColors.accentPurple]),
                boxShadow: [BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: const Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('스킨 시스템 안내', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                  Text('코인으로 스킨을 모으세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('점수 10점당 1🪙 적립 · 챌린지 완료 시 보너스', style: TextStyle(fontSize: 11, color: Colors.white)),
                ])),
                Text('🪙', style: TextStyle(fontSize: 44)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
              itemCount: _skins.length,
              itemBuilder: (_, i) {
                final s = _skins[i];
                final isOwned = owned.contains(s.id);
                final isEquipped = equipped == s.id;
                final masteryLocked = _isMasteryLocked(s, store);
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))]),
                  clipBehavior: Clip.antiAlias,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [s.g1, s.g2])),
                      alignment: Alignment.center,
                      child: Stack(children: [
                        Center(child: Text(s.emoji, style: const TextStyle(fontSize: 46))),
                        if (isEquipped) Positioned(top: 6, left: 6, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.mintShadow, borderRadius: BorderRadius.circular(99)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            AppIcon(IconKind.check, size: 12, color: Colors.white),
                            SizedBox(width: 3),
                            Text('사용 중', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                          ]),
                        )),
                        if (masteryLocked) Positioned.fill(child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AppIcon(IconKind.lock, size: 22, color: Colors.white),
                                  const SizedBox(height: 6),
                                  Text(
                                    _unlockHint(s),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1.25),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        Text(s.sub, style: const TextStyle(fontSize: 10, color: AppColors.inkLight)),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: _btnFor(s, isOwned, isEquipped, masteryLocked, store)),
                      ]),
                    ),
                  ]),
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  bool _isMasteryLocked(_SkinDef s, LocalStore store) {
    final need = s.unlockAfterMaxFruitId;
    if (need == null) return false;
    return store.bestMaxFruitReached < need;
  }

  String _unlockHint(_SkinDef s) {
    final need = s.unlockAfterMaxFruitId;
    if (need == null || need < 0 || need >= fruits.length) return '조건 미충족';
    final name = fruits[need].name;
    return '$name 이상\n만들면 해금';
  }

  Widget _btnFor(_SkinDef s, bool owned, bool equipped, bool masteryLocked, LocalStore store) {
    if (equipped) {
      return PopButton(variant: PopButtonVariant.ghost, height: 30, disabled: true, onTap: () {}, child: const Text('사용 중', style: TextStyle(fontSize: 11)));
    }
    if (masteryLocked) {
      return PopButton(
        height: 30,
        disabled: true,
        onTap: () {},
        child: Text(
          '${fruits[s.unlockAfterMaxFruitId!.clamp(0, fruits.length - 1)].name} ${store.bestMaxFruitReached}/${s.unlockAfterMaxFruitId}',
          style: const TextStyle(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (owned) {
      return PopButton(variant: PopButtonVariant.mint, height: 30, onTap: () => _onEquip(s), child: const Text('장착하기', style: TextStyle(fontSize: 11)));
    }
    return PopButton(
      variant: PopButtonVariant.secondary, height: 30, onTap: () => _onTryBuy(s),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFFFE38A), Color(0xFFFFB800)]))),
        const SizedBox(width: 4),
        Text(_fmtNum(s.price), style: const TextStyle(fontSize: 11)),
      ]),
    );
  }
}
