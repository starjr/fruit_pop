import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_store.dart';
import '../theme/app_colors.dart';
import '../widgets/fruits/fruit_painters.dart';
import '../widgets/mascot.dart';
import '../widgets/pop_button.dart';
import 'home_screen.dart';

/// 첫 실행 시 1회 표시되는 온보딩.
///
/// 닉네임을 입력 → "시작하기" 누르면 [LocalStore.setNickname] 과
/// [LocalStore.completeOnboarding] 을 호출하고 [HomeScreen] 으로 교체된다.
/// 데이터 초기화 후에도 다시 표시된다.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _maxLen = 12;
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  String get _trimmed => _controller.text.trim();
  bool get _canStart => _trimmed.isNotEmpty && !_saving;

  Future<void> _start() async {
    if (!_canStart) return;
    setState(() => _saving = true);
    final store = LocalStore.I;
    await store.setNickname(_trimmed);
    await store.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 30,
                left: -20,
                child: Opacity(
                  opacity: 0.55,
                  child: FruitWidget(id: 2, size: 70),
                ),
              ),
              const Positioned(
                top: 90,
                right: -10,
                child: Opacity(
                  opacity: 0.5,
                  child: FruitWidget(id: 1, size: 60),
                ),
              ),
              const Positioned(
                bottom: 60,
                left: -25,
                child: Opacity(
                  opacity: 0.45,
                  child: FruitWidget(id: 4, size: 90),
                ),
              ),
              const Positioned(
                bottom: 100,
                right: -30,
                child: Opacity(
                  opacity: 0.5,
                  child: FruitWidget(id: 5, size: 100),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'WELCOME',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkSoft,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Fruit Pop 에 오신 걸\n환영합니다!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD9588A),
                                height: 1.15,
                                shadows: [
                                  Shadow(
                                    color: AppColors.candyPinkLight,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '먼저 게임에서 사용할 닉네임을 알려주세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Mascot(size: 150),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WhiteCard(
                              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '닉네임',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkSoft,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _controller,
                                    autofocus: true,
                                    maxLength: _maxLen,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _start(),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'\s{2,}'),
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '예: 수박왕',
                                      hintStyle: TextStyle(
                                        color: AppColors.inkLight
                                            .withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      counterText: '',
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_trimmed.characters.length}/$_maxLen',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.inkLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '나중에 설정 화면에서 언제든 바꿀 수 있어요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkLight,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Opacity(
                              opacity: _canStart ? 1.0 : 0.5,
                              child: PopButton(
                                height: 64,
                                width: double.infinity,
                                onTap: _canStart ? _start : () {},
                                child: const Text(
                                  '시작하기',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
