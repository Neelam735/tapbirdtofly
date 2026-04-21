import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';

/// Loads and shows interstitial ads at a capped frequency so retention is not
/// harmed by ads after every single death.
class InterstitialAdController {
  InterstitialAdController({this.showEvery = 3});

  /// Show one interstitial every Nth game over.
  final int showEvery;

  InterstitialAd? _ad;
  bool _loading = false;
  int _gameOverCount = 0;

  void preload() {
    if (_ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Increment the game-over counter and, if the cap is hit, show the ad.
  /// Returns `true` if an ad was shown.
  Future<bool> onGameOver() async {
    _gameOverCount++;
    if (_gameOverCount % showEvery != 0) return false;

    final ad = _ad;
    if (ad == null) {
      preload();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        _ad = null;
        preload();
      },
    );

    await ad.show();
    return true;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
