import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';

class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late bool _available;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];

  Future<void> initialize(BuildContext context) async {
    _available = await _iap.isAvailable();
    if (_available) {
      await _loadProducts(context); // Charger les produits disponibles
      await _clearPendingPurchases();
      listenToPurchaseUpdated(context); // Démarrer l'écoute des mises à jour
    }
  }

  Future<void> _clearPendingPurchases() async {
    if (Platform.isIOS || isMacOS) {
      try {
        final transactions = await SKPaymentQueueWrapper().transactions();
        for (final transaction in transactions) {
          try {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
          } catch (e) {
            debugPrint("Error clearing pending purchases::in::loop");
            debugPrint(e.toString());
            rethrow;
          }
        }
      } catch (e) {
        debugPrint("Error clearing pending purchases");
        debugPrint(e.toString());
        rethrow;
      }
    }
  }

  void listenToPurchaseUpdated(BuildContext context) {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          // Vérifier et compléter les transactions achetées ou restaurées
          _handlePurchaseUpdates([purchase], context);
        } else if (purchase.status == PurchaseStatus.pending) {
          // Traiter les transactions en attente avec un délai avant de les annuler
        } else if (purchase.status == PurchaseStatus.error) {
          // Gérer les erreurs de transaction et les terminer
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur pendant la transaction : ${purchase.error?.message}')));
        }
      }
    });
  }

  Future<void> _loadProducts(BuildContext context) async {
    try {
      const Set<String> kIds = {'kapstr_basic_plan', 'kapstr_premium_plan', 'kapstr_premium_plus_plan', 'kapstr_unlimited_plan'};

      final ProductDetailsResponse response = await _iap.queryProductDetails(kIds);
      if (response.error == null) {
        final Map<String, ProductDetails> productsMap = {for (var product in response.productDetails) product.id: product};

        _products = kIds.map((id) => productsMap[id]).where((product) => product != null).whereType<ProductDetails>().toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while loading the products. Please try again later. $e')));
      printOnDebug('Error loading products: $e');
    }
  }

  Future<void> buyProduct(ProductDetails product, BuildContext context) async {
    try {
      await _clearPendingPurchases();
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while purchasing the product. Please try again later. ' + e.toString())));
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases, BuildContext context) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Vérifier et finaliser l'achat
        await _updateEventAfterPurchase(purchase, context);
        await _iap.completePurchase(purchase); // Marquer la transaction comme complétée
      } else if (purchase.status == PurchaseStatus.restored) {
        // Si la transaction est restaurée, la marquer comme complétée
      }
    }
  }

  Future<void> _updateEventAfterPurchase(PurchaseDetails purchase, BuildContext context) async {
    String plan;
    DateTime planEndAt;
    if (purchase.productID == 'kapstr_basic_plan') {
      plan = 'kapstr_basic_plan';
    } else if (purchase.productID == 'kapstr_premium_plan') {
      plan = 'kapstr_premium_plan';
    } else if (purchase.productID == 'kapstr_premium_plus_plan') {
      plan = 'kapstr_premium_plus_plan';
    } else if (purchase.productID == 'kapstr_unlimited_plan') {
      plan = 'kapstr_unlimited_plan';
    } else {
      plan = 'free';
    }

    planEndAt = DateTime.now().add(const Duration(days: 365));

    Event.instance.plan = plan;
    Event.instance.planEndAt = planEndAt;

    context.read<EventsController>().updateEvent(Event.instance);
    context.read<EventsController>().updateEventField(key: 'plan', value: plan);
    context.read<EventsController>().updateEventField(key: 'plan_end_at', value: planEndAt);
  }

  List<ProductDetails> get products => _products;
}
