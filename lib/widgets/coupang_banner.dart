import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/coupang_config.dart';
import '../services/ad_id_service.dart';
import '../theme/app_colors.dart';

/// 쿠팡 파트너스 배너. [CoupangConfig.bannerAdUnitId] 가 없으면 그리지 않는다.
/// ADID/IDFA 를 읽어 관심사 배너용 `deviceId` 로 전달한다.
class CoupangBanner extends StatefulWidget {
  const CoupangBanner({super.key, this.showDisclosure = true});

  final bool showDisclosure;

  @override
  State<CoupangBanner> createState() => _CoupangBannerState();
}

class _CoupangBannerState extends State<CoupangBanner> {
  WebViewController? _controller;
  bool _failed = false;
  bool _loaded = false;
  bool _preparing = true;

  @override
  void initState() {
    super.initState();
    if (!CoupangConfig.hasBannerAd) {
      _preparing = false;
      return;
    }
    _prepare();
  }

  Future<void> _prepare() async {
    final deviceId = await AdIdService.getDeviceId();
    if (!mounted) return;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _failed = true);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (_shouldOpenExternally(url)) {
              _openExternal(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
        CoupangConfig.bannerHtml(deviceId: deviceId),
        baseUrl: 'https://ads-partners.coupang.com/',
      );

    setState(() {
      _controller = controller;
      _preparing = false;
    });
  }

  bool _shouldOpenExternally(String url) {
    if (url.startsWith('data:') || url.startsWith('about:')) return false;
    if (url.contains('ads-partners.coupang.com/g.js')) return false;
    if (url.contains('ads-partners.coupang.com') &&
        !url.contains('coupang.com/vp') &&
        !url.contains('link.coupang')) {
      return false;
    }
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!CoupangConfig.hasBannerAd || _failed) {
      return const SizedBox.shrink();
    }

    final bannerH = CoupangConfig.bannerHeight.toDouble();
    final controller = _controller;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: bannerH,
            child: Stack(
              children: [
                if (controller != null) WebViewWidget(controller: controller),
                if (_preparing || !_loaded)
                  const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.showDisclosure) ...[
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
