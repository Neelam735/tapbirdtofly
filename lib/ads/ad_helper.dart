import 'dart:io';

/// AdMob unit IDs.
///
/// While [useTestAds] is `true`, Google's official sample IDs are used so the
/// app runs out-of-the-box without an AdMob account. Flip [useTestAds] to
/// `false` and fill in your real IDs before shipping to production.
class AdHelper {
  static const bool useTestAds = true;

  // Google-provided sample unit IDs. Safe to use during development.
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // TODO: replace with your production unit IDs from the AdMob console.
  static const String _prodBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos;
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos;
    }
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIos;
  }
}
