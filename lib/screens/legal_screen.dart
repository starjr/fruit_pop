import 'package:flutter/material.dart';
import '../data/legal_text.dart';
import '../theme/app_colors.dart';
import '../widgets/icons.dart';
import '../widgets/pop_button.dart';

/// 개인정보처리방침 / 약관 등 정적 법적 문서를 보여주는 단순 뷰어.
class LegalScreen extends StatelessWidget {
  final String title;
  final String body;
  const LegalScreen({super.key, required this.title, required this.body});

  /// 기본 — 개인정보처리방침.
  factory LegalScreen.privacy({Key? key}) =>
      LegalScreen(key: key, title: '개인정보처리방침', body: privacyPolicyText);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                PopButton(
                  variant: PopButtonVariant.ghost,
                  height: 40, width: 40, padding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context),
                  child: const AppIcon(IconKind.back),
                ),
                Expanded(
                  child: Center(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ),
                ),
                const SizedBox(width: 40),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
