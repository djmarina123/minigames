import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Serviço de anúncios — rewarded (dobrar moedas) e interstitial (entre partidas).
class AdsService {
  AdsService._();

  static int _gamesSinceInterstitial = 0;
  static bool _adsRemoved = false;

  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static bool _loadingRewarded = false;
  static bool _loadingInterstitial = false;

  /// Chamado pelo [PurchaseService] quando o jogador compra "remover anúncios".
  static void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
    }
  }

  static bool get adsRemoved => _adsRemoved;

  static String get _rewardedAdUnitId {
    if (kIsWeb) return AdsConfig.rewardedAdUnitIdAndroid;
    return Platform.isIOS
        ? AdsConfig.rewardedAdUnitIdIos
        : AdsConfig.rewardedAdUnitIdAndroid;
  }

  static String get _interstitialAdUnitId {
    if (kIsWeb) return AdsConfig.interstitialAdUnitIdAndroid;
    return Platform.isIOS
        ? AdsConfig.interstitialAdUnitIdIos
        : AdsConfig.interstitialAdUnitIdAndroid;
  }

  static Future<void> initialize() async {
    if (!kAdsConfigured) return;
    await MobileAds.instance.initialize();
    _preloadRewarded();
    _preloadInterstitial();
  }

  static void _preloadRewarded() {
    if (!kAdsConfigured || _loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _preloadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdsService: rewarded show failed — $error');
              ad.dispose();
              _rewardedAd = null;
              _preloadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: rewarded load failed — $error');
          _loadingRewarded = false;
        },
      ),
    );
  }

  static void _preloadInterstitial() {
    if (!kAdsConfigured ||
        _adsRemoved ||
        _loadingInterstitial ||
        _interstitialAd != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdsService: interstitial show failed — $error');
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsService: interstitial load failed — $error');
          _loadingInterstitial = false;
        },
      ),
    );
  }

  static Future<void> maybeShowInterstitial() async {
    if (!kAdsConfigured || _adsRemoved) return;
    _gamesSinceInterstitial++;
    if (_gamesSinceInterstitial < AdsConfig.interstitialEvery) return;
    _gamesSinceInterstitial = 0;

    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    _interstitialAd = null;
    await ad.show();
  }

  /// Retorna valor > 0 se o jogador assistiu ao anúncio (ou stub dev).
  static Future<int> showRewardedAd() async {
    if (!kAdsConfigured) return AdsConfig.stubRewardSuccess;

    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      return 0;
    }

    final completer = Completer<int>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        if (!completer.isCompleted) {
          completer.complete(earned ? 1 : 0);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsService: rewarded show failed — $error');
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(0);
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        earned = true;
      },
    );

    return completer.future;
  }
}
