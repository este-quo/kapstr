import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:kapstr/configuration/in_app_purchase_service.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/in_app_purchase/selectable.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedProductId;
  final InAppPurchaseService _inAppPurchaseService = InAppPurchaseService();

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSendingEmail = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializePurchases(context);
  }

  Future<void> _initializePurchases(BuildContext context) async {
    await _inAppPurchaseService.initialize(context);
    setState(() {}); // Refresh the UI after initialization
    _inAppPurchaseService.listenToPurchaseUpdated(context);
  }

  void _handleTabChange() {
    setState(() {});
  }

  Future _purchaseProduct(BuildContext context) async {
    printOnDebug('Selected productId: $selectedProductId');

    setState(() {
      isLoading = true;
    });
    // Écouter les transactions en cours et gérer les achats en attente
    if (selectedProductId != null) {
      try {
        await _completePendingPurchases();

        final selectedProduct = _inAppPurchaseService.products.firstWhere((product) => product.id == selectedProductId);
        _inAppPurchaseService.buyProduct(selectedProduct, context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'achat du produit. Produit sélectionné : $selectedProductId, Produits disponibles : ${_inAppPurchaseService.products}')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit non disponible ou non sélectionné.')));
    }
  }

  // Fonction pour compléter ou gérer les transactions en attente
  Future<void> _completePendingPurchases() async {
    final purchaseStream = InAppPurchase.instance.purchaseStream;

    purchaseStream.listen(
      (purchases) {
        for (var purchase in purchases) {
          if (purchase.pendingCompletePurchase) {
            // Compléter ou annuler les achats non terminés
            InAppPurchase.instance.completePurchase(purchase);
            printOnDebug('Transaction complétée ou annulée pour l\'id: ${purchase.productID}');
          }
        }
      },
      onError: (error) {
        printOnDebug('Erreur lors de la gestion des achats en attente: $error');
      },
    );
  }

  Future<void> _sendContactEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSendingEmail = true;
      });

      final Email email = Email(
        body:
            'Prénom: ${_firstNameController.text}\n'
            'Nom: ${_lastNameController.text}\n'
            'Société: ${_companyController.text}\n'
            'Numéro: ${_phoneNumberController.text}\n'
            'E-mail: ${_emailController.text}',
        subject: 'Contact Professionnel',
        recipients: ['contact@kapstr.com'],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Un conseiller vous contactera dans les plus bref délais.')));
        _formKey.currentState!.reset();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'envoi du mail.')));
      } finally {
        setState(() {
          _isSendingEmail = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: kWhite,
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Image.asset('assets/inappbg.jpg', width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.45, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.45,
                    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromARGB(136, 248, 57, 114), Color.fromARGB(60, 160, 38, 74), Color.fromARGB(66, 63, 17, 30)])),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomAssetSvgPicture('assets/logos/logo.svg', height: 32, width: 32, color: kWhite),
                          SizedBox(height: 16),
                          Text('Activez votre évènement', textAlign: TextAlign.center, style: TextStyle(color: kWhite, fontSize: 24, fontWeight: FontWeight.w700)),
                          SizedBox(height: 8),
                          Text('Achat unique, payez une fois !', style: TextStyle(color: kWhite, fontSize: 20, fontWeight: FontWeight.w300)),
                          SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: TabBarView(controller: _tabController, children: [_buildIndividualTab(context), _buildProfessionalTab(context)])),
            ],
          ),
          Positioned(
            top: 24,
            left: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                height: 40,
                width: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: kBlack.withValues(alpha: 0.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 20)]),
                child: const Icon(Icons.close_rounded, color: kWhite, size: 20),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45 - 28,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(color: Color.fromARGB(255, 240, 240, 240), borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Theme(
                data: Theme.of(context).copyWith(tabBarTheme: TabBarTheme(indicator: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(8)), indicatorSize: TabBarIndicatorSize.tab)),
                child: TabBar(
                  dividerColor: const Color.fromARGB(255, 240, 240, 240),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  controller: _tabController,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  indicatorColor: const Color.fromARGB(255, 240, 240, 240),
                  labelColor: kWhite,
                  unselectedLabelColor: kBlack,
                  tabs: const [Tab(text: 'Particulier'), Tab(text: 'Professionnel')],
                ),
              ),
            ),
          ),
          // Floating Action Button for purchase
          if (_tabController.index == 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Visibility(
                visible: selectedProductId != null,
                child: Center(
                  child: MainButton(
                    height: 64,
                    backgroundColor: const Color(0xFFF83972),
                    onPressed: () => _purchaseProduct(context),
                    child: isLoading ? Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg')) : const Text('Activez mon évènement', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  SingleChildScrollView _buildIndividualTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Container(
              width: double.infinity,
              height: 64,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.transparent, border: Border.all(color: kBlack, width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [Text('1 à 30 invités', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w600)), Spacer(), Text('Gratuit', style: TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w700))]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SelectableBox(
              productId: 'kapstr_basic_plan',
              selectedProductId: selectedProductId,
              onChanged: (productId) => setState(() => selectedProductId = productId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('31 à 100 invités', style: TextStyle(color: selectedProductId == 'kapstr_basic_plan' ? kWhite : kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      RichText(text: TextSpan(text: '59,90€', style: TextStyle(color: selectedProductId == 'kapstr_basic_plan' ? kWhite : kBlack, fontSize: 20, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SelectableBox(
              productId: 'kapstr_premium_plan',
              selectedProductId: selectedProductId,
              onChanged: (productId) => setState(() => selectedProductId = productId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('101 à 150 invités', style: TextStyle(color: selectedProductId == 'kapstr_premium_plan' ? kWhite : kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      RichText(text: TextSpan(text: '89,90€', style: TextStyle(color: selectedProductId == 'kapstr_premium_plan' ? kWhite : kBlack, fontSize: 20, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SelectableBox(
              productId: 'kapstr_premium_plus_plan',
              selectedProductId: selectedProductId,
              onChanged: (productId) => setState(() => selectedProductId = productId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('151 à 300 invités', style: TextStyle(color: selectedProductId == 'kapstr_premium_plus_plan' ? kWhite : kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      RichText(text: TextSpan(text: '139,90€', style: TextStyle(color: selectedProductId == 'kapstr_premium_plus_plan' ? kWhite : kBlack, fontSize: 20, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SelectableBox(
              productId: 'kapstr_unlimited_plan',
              selectedProductId: selectedProductId,
              onChanged: (productId) => setState(() => selectedProductId = productId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text('Invités Illimités', style: TextStyle(color: selectedProductId == 'kapstr_unlimited_plan' ? kWhite : kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      RichText(text: TextSpan(text: '299,90€', style: TextStyle(color: selectedProductId == 'kapstr_unlimited_plan' ? kWhite : kBlack, fontSize: 20, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Paiement unique, valable 1 an', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: kBlack, fontWeight: FontWeight.w400))]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _showPrivacyPolicy(context);
                  },
                  child: const Text('Conditions générales de vente (CGV)', style: TextStyle(color: kGrey, fontSize: 12, fontWeight: FontWeight.w400, decoration: TextDecoration.underline, decorationColor: kGrey)),
                ),
              ],
            ),
            const SizedBox(height: 92),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            const Text('Vous organisez plusieurs évenements à l\'année ?', style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Nous pourrons vous proposez des formules adaptées remplissez ce formulaire', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w300)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Prénom',
                hintText: 'Entrez votre prénom',
                hintStyle: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre prénom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
                hintStyle: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Société',
                hintText: 'Entrez le nom de votre société',
                hintStyle: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom de votre société';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Numéro de téléphone',
                hintText: '06 12 34 56 78',
                hintStyle: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre numéro de téléphone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Email',
                hintText: 'exemple@kapstr.com',
                hintStyle: TextStyle(color: kGrey, fontSize: 14, fontWeight: FontWeight.w400),
                border: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Veuillez entrer une adresse email valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: MainButton(
                backgroundColor: kBlack,
                onPressed: _isSendingEmail ? null : () => _sendContactEmail(),
                child: _isSendingEmail ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2)) : const Text('Envoyer', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      elevation: 10,
      builder: (context) {
        return FutureBuilder<String>(
          future: _loadAsset('assets/CGV KAPSTR francais.txt'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading privacy policy'));
            } else {
              return DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.5,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Scrollbar(child: SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Text(snapshot.data ?? 'No data', style: const TextStyle(fontSize: 14), textAlign: TextAlign.justify)));
                },
              );
            }
          },
        );
      },
    );
  }

  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }
}
