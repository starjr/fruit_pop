import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// Android ADID / iOS IDFA. 쿠팡 관심사 배너 `deviceId` 용.
///
/// 사용자가 추적/광고 ID를 끄면 빈 문자열을 반환한다(배너는 deviceId 없이 로드).
abstract final class AdIdService {
  static String? _cached;
  static bool _requestedAtt = false;

  /// 가능하면 광고 ID를 읽고 캐시한다. 실패·거부 시 `''`.
  static Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;
    if (kIsWeb) {
      _cached = '';
      return _cached!;
    }
    try {
      if (Platform.isIOS) {
        await _ensureAttIfNeeded();
      }
      final id = await AdvertisingId.id(true);
      final limit = await AdvertisingId.isLimitAdTrackingEnabled;
      if (limit == true || id == null || id.isEmpty) {
        _cached = '';
      } else {
        _cached = id;
      }
    } catch (_) {
      _cached = '';
    }
    return _cached!;
  }

  static Future<void> _ensureAttIfNeeded() async {
    if (_requestedAtt) return;
    _requestedAtt = true;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // ATT 미지원·시뮬레이터 등은 무시하고 ADID 조회를 이어간다.
    }
  }
}
