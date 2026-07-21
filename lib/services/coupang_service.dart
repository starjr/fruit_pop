import 'package:url_launcher/url_launcher.dart';

import '../data/coupang_config.dart';

/// 쿠팡 파트너스 제휴 링크 오픈.
abstract final class CoupangService {
  static Future<bool> openAffiliateLanding() async {
    final uri = Uri.parse(CoupangConfig.effectiveAffiliateUrl);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
