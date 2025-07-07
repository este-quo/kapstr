import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class InAppController extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> availablePlans = [];
  int credits = 0;
  bool _isTransactionInProgress = false; // Empêche les transactions multiples
  bool transactionSuccess = false; // Indique si un achat a réussi

  InAppController() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onError: (error) {
        print("Erreur lors de l'achat : $error");
        _isTransactionInProgress = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> reset() async {}

  /// Récupère le nombre de crédits de l'utilisateur
  Future<int> getUserCredits(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        credits = userData['credits'] ?? 0;
        notifyListeners();
        return credits;
      }
    } catch (e) {
      print("Erreur lors de la récupération des crédits: $e");
    }
    return 0;
  }

  /// Met à jour les crédits dans Firestore
  Future<void> setUserCredits(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'credits': credits});
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour des crédits : $e");
    }
  }

  bool useCredit(String userId) {
    if (credits < 1) return false;
    credits -= 1;
    setUserCredits(userId);
    return true;
  }

  Future<void> addCredits(int creditsNumber, String userId) async {
    credits += creditsNumber;
    await setUserCredits(userId);
  }

  Future<void> getPlans() async {
    const Set<String> _productIds = {'credits_1', 'credits_10', 'credits_20'};
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      print('In-app purchases non disponible.');
      return;
    }

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

    if (response.error != null) {
      print('Erreur lors de la récupération des produits : ${response.error}');
      return;
    }

    if (response.productDetails.isEmpty) {
      print('Aucun produit disponible.');
      return;
    }

    availablePlans = response.productDetails;
    notifyListeners();
  }

  /// Gère l'achat d'un plan (évite les achats simultanés)
  Future<void> buyPlan(ProductDetails productDetails, String userId) async {
    _isTransactionInProgress = true;
    transactionSuccess = false;
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Erreur lors de l\'achat : $e');
      _isTransactionInProgress = false;
      notifyListeners();
    }
  }

  /// Gère les transactions en cours et ajoute les crédits si achat validé
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("Achat en attente...");
      } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
        _deliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print("Erreur d'achat : ${purchaseDetails.error}");
        _isTransactionInProgress = false;
        transactionSuccess = false;
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print("Achat annulé");
        _isTransactionInProgress = false;
        transactionSuccess = false;
        notifyListeners();
      }

      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  /// Ajoute les crédits après validation de l'achat
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    String productId = purchaseDetails.productID;
    int creditsToAdd = (productId == "credits_1")
        ? 1
        : (productId == "credits_10")
            ? 10
            : 20;

    if (creditsToAdd > 0) {
      await addCredits(creditsToAdd, purchaseDetails.purchaseID ?? '');
      transactionSuccess = true;
      print("Crédits ajoutés : $creditsToAdd");
    } else {
      transactionSuccess = false;
      print("Erreur: Produit inconnu.");
    }

    _isTransactionInProgress = false;
    notifyListeners();
  }
}
