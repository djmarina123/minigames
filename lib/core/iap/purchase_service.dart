import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../ads/ads_service.dart';
import '../storage/player_repository.dart';
import 'iap_config.dart';

/// Compras no app — remover anúncios e pacote de moedas.
class PurchaseService extends ChangeNotifier {
  PurchaseService(this._playerRepo);

  final PlayerRepository _playerRepo;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _available = false;
  bool _loading = false;
  String? _lastError;

  bool get isAvailable => _available;
  bool get loading => _loading;
  String? get lastError => _lastError;
  bool get adsRemoved => _playerRepo.profile.adsRemoved;

  ProductDetails? _removeAdsProduct;
  ProductDetails? _coinPackProduct;

  ProductDetails? get removeAdsProduct => _removeAdsProduct;
  ProductDetails? get coinPackProduct => _coinPackProduct;

  Future<void> initialize() async {
    AdsService.setAdsRemoved(_playerRepo.profile.adsRemoved);

    if (!kIapConfigured) return;

    _available = await InAppPurchase.instance.isAvailable();
    if (!_available) return;

    _subscription ??=
        InAppPurchase.instance.purchaseStream.listen(_onPurchases);
    await _queryProducts();
  }

  Future<void> _queryProducts() async {
    if (!kIapConfigured || !_available) return;
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await InAppPurchase.instance.queryProductDetails({
        IapConfig.removeAdsProductId,
        IapConfig.coinPackProductId,
      });

      if (response.error != null) {
        _lastError = response.error!.message;
      }

      for (final product in response.productDetails) {
        if (product.id == IapConfig.removeAdsProductId) {
          _removeAdsProduct = product;
        } else if (product.id == IapConfig.coinPackProductId) {
          _coinPackProduct = product;
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> buyRemoveAds() async {
    if (!kIapConfigured) {
      await _grantRemoveAds();
      return;
    }
    final product = _removeAdsProduct;
    if (product == null) {
      _lastError = 'Produto indisponível.';
      notifyListeners();
      return;
    }
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> buyCoinPack() async {
    if (!kIapConfigured) {
      await _playerRepo.addBonusCoins(IapConfig.coinPackAmount);
      return;
    }
    final product = _coinPackProduct;
    if (product == null) {
      _lastError = 'Produto indisponível.';
      notifyListeners();
      return;
    }
    await InAppPurchase.instance.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.error) {
        _lastError = purchase.error?.message ?? 'Erro na compra.';
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _deliverProduct(purchase.productID);
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(String productId) async {
    switch (productId) {
      case IapConfig.removeAdsProductId:
        await _grantRemoveAds();
      case IapConfig.coinPackProductId:
        await _playerRepo.addBonusCoins(IapConfig.coinPackAmount);
    }
  }

  Future<void> _grantRemoveAds() async {
    await _playerRepo.setAdsRemoved(true);
    AdsService.setAdsRemoved(true);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    if (!kIapConfigured) return;
    await InAppPurchase.instance.restorePurchases();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
