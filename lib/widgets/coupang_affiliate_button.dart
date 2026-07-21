import 'package:flutter/material.dart';

import '../data/coupang_config.dart';
import '../services/coupang_service.dart';
import '../theme/app_colors.dart';
import 'pop_button.dart';

/// 결과 화면 등에서 쓰는 쿠팡 제휴 딥링크 CTA.
class CoupangAffiliateButton extends StatelessWidget {
  const CoupangAffiliateButton({super.key, this.showDisclosure = true});

  final bool showDisclosure;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopButton(
          variant: PopButtonVariant.secondary,
          height: 48,
          width: double.infinity,
          onTap: () async {
            final ok = await CoupangService.openAffiliateLanding();
            if (!context.mounted) return;
            if (!ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('쿠팡 페이지를 열 수 없어요')),
              );
            }
          },
          child: const Text(
            '쿠팡에서 더 보기',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        if (showDisclosure) ...[
          const SizedBox(height: 6),
          Text(
            CoupangConfig.disclosureKo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              height: 1.3,
              color: AppColors.inkLight.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
