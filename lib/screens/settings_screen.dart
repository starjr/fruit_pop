import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/pop_button.dart';
import '../widgets/icons.dart';
import '../services/local_store.dart';
import 'legal_screen.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _appVersion = '1.0.0';

  Future<void> _editNickname() async {
    final store = LocalStore.I;
    final controller = TextEditingController(text: store.nickname);
    final next = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
          decoration: const InputDecoration(hintText: '플레이어'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (next != null && next.isNotEmpty) {
      await store.setNickname(next);
      if (mounted) setState(() {});
    }
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('내 데이터 초기화'),
        content: const Text(
            '닉네임·코인·베스트 점수·게임 기록·챌린지 진행도·보유 스킨·설정이 모두 초기화됩니다.\n이 작업은 되돌릴 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('초기화', style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await LocalStore.I.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.I;
    final nickname = store.nickname;
    final initial = store.nicknameInitial;

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
                const Expanded(child: Center(child: Text('설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)))),
                const SizedBox(width: 40),
              ]),
            ),
            Expanded(child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.candyPinkLight, AppColors.candyYellowLight]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [AppColors.candyPeach, AppColors.candyPink]),
                        boxShadow: [BoxShadow(color: AppColors.candyPink.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      alignment: Alignment.center,
                      child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$nickname님', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Text('베스트 ${store.bestScore} · ${store.recentGames.length}판', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                    ])),
                    PopButton(variant: PopButtonVariant.ghost, height: 32, padding: const EdgeInsets.symmetric(horizontal: 12), onTap: _editNickname, child: const Text('편집', style: TextStyle(fontSize: 11))),
                  ]),
                ),
                _section('🔊 사운드', [
                  _toggle('배경음악', store.bgmEnabled, (v) async { await store.setBgmEnabled(v); setState(() {}); }),
                  _toggle('효과음', store.sfxEnabled, (v) async { await store.setSfxEnabled(v); setState(() {}); }),
                  _toggle('진동', store.hapticEnabled, (v) async { await store.setHapticEnabled(v); setState(() {}); }),
                ]),
                _section('🎮 게임', [
                  _toggle('알림', store.pushEnabled, (v) async { await store.setPushEnabled(v); setState(() {}); }),
                  _info('조작 방식', '드래그하여 떨어뜨리기'),
                  _info('과일 스타일', '기본'),
                ]),
                _section('ℹ️ 정보', [
                  _info('언어', '한국어'),
                  _link(
                    '개인정보처리방침',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LegalScreen.privacy()),
                    ),
                  ),
                  _info('버전', _appVersion),
                ]),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _confirmReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('내 데이터 초기화', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentCoral)),
                  ),
                ),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkSoft, letterSpacing: 0.4))),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))]),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ]),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFFFEEE5)))),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink))),
        GestureDetector(
          onTap: () => onChange(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46, height: 26,
            decoration: BoxDecoration(
              gradient: value ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.mintTop, AppColors.mintShadow]) : null,
              color: value ? null : const Color(0xFFE8E0DC),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Stack(children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
                top: 2, left: value ? 22 : 2,
                child: Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))])),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  /// 단순 정보 표시(우측 chevron 없음, 탭 비활성).
  Widget _info(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFFFEEE5)))),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink))),
        Text(value, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
      ]),
    );
  }

  /// 탭 가능한 링크 행(우측 chevron 표시).
  Widget _link(String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFFFEEE5)))),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink))),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSoft),
        ]),
      ),
    );
  }
}
