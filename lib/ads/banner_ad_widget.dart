import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';

/// A self-managing adaptive banner ad anchored at a fixed height so the game
/// layout does not jump when the ad finishes loading.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.reservedHeight = 60});

  final double reservedHeight;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requestInFlight = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad == null && !_requestInFlight) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    _requestInFlight = true;
    try {
      final width = MediaQuery.of(context).size.width.truncate();
      final size = await AdSize
          .getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (!mounted || size == null) return;

      final ad = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('Banner ad failed to load: $error');
          },
        ),
      );

      await ad.load();
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _ad = ad);
    } catch (e) {
      debugPrint('Banner ad request skipped: $e');
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: widget.reservedHeight,
      alignment: Alignment.center,
      child: (_ad != null && _loaded)
          ? SizedBox(
              width: _ad!.size.width.toDouble(),
              height: _ad!.size.height.toDouble(),
              child: AdWidget(ad: _ad!),
            )
          : const SizedBox.shrink(),
    );
  }
}
