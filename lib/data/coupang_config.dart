/// 쿠팡 파트너스 연동 설정.
///
/// 배너용 [bannerAdUnitId] 는 partners.coupang.com 에서 배너를 만든 뒤
/// 임베드 코드의 숫자 `id` 를 붙여 넣는다. 비어 있으면 배너는 숨기고
/// 제휴 딥링크만 동작한다.
abstract final class CoupangConfig {
  /// 파트너 추적코드 (AF…)
  static const String trackingCode = 'AF5332526';

  /// 배너 광고 유닛 ID. 예: `'123456'`
  /// 파트너스 → 다이나믹 배너 목록의 ID 값.
  static const String bannerAdUnitId = '1008812';

  /// 파트너스에서 복사한 추적(숏) 링크.
  /// 비어 있으면 [defaultAffiliateLandingUrl] 을 사용한다.
  static const String affiliateLandingUrl = '';

  /// 배너 표시 크기 (파트너스 배너 템플릿과 맞춤).
  static const int bannerWidth = 320;
  static const int bannerHeight = 100;

  static bool get hasBannerAd => bannerAdUnitId.trim().isNotEmpty;

  /// 제휴 딥링크로 열 URL.
  static String get effectiveAffiliateUrl {
    final custom = affiliateLandingUrl.trim();
    if (custom.isNotEmpty) return custom;
    return defaultAffiliateLandingUrl;
  }

  /// 콘솔 숏링크가 없을 때 쓰는 기본 랜딩(검색 + lptag).
  /// 수익 추적이 더 정확하려면 [affiliateLandingUrl] 에 파트너스 링크를 넣는 것을 권장.
  static String get defaultAffiliateLandingUrl =>
      'https://www.coupang.com/np/search'
      '?component=&q=%EA%B2%8C%EC%9E%84&channel=user'
      '&lptag=$trackingCode';

  static const String disclosureKo =
      '이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다.';

  /// WebView 에 로드할 Partners 배너 HTML.
  /// [deviceId] 는 Android ADID / iOS IDFA. 비어 있으면 일반(비맞춤) 배너.
  static String bannerHtml({String deviceId = ''}) {
    final id = bannerAdUnitId.trim();
    final safeDeviceId = deviceId
        .replaceAll('\\', '\\\\')
        .replaceAll("'", r"\'")
        .replaceAll('"', r'\"');
    final deviceIdField =
        safeDeviceId.isEmpty ? '' : ',"deviceId":"$safeDeviceId"';
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0"/>
<style>
  html, body { margin: 0; padding: 0; background: transparent; overflow: hidden; }
  #wrap { width: 100%; display: flex; justify-content: center; align-items: center; }
</style>
</head>
<body>
<div id="wrap"></div>
<script src="https://ads-partners.coupang.com/g.js"></script>
<script>
  new PartnersCoupang.G({
    "id": $id,
    "template": "carousel",
    "trackingCode": "$trackingCode",
    "width": "$bannerWidth",
    "height": "$bannerHeight",
    "tsource": ""
    $deviceIdField
  });
</script>
</body>
</html>
''';
  }
}
