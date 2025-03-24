import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kapstr/controllers/in_app.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CreditsPage extends StatefulWidget {
  final bool isCreditsEmpty;

  const CreditsPage({super.key, required this.isCreditsEmpty});

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  String selectedPack = "";
  late InAppController inAppController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    inAppController = context.read<InAppController>();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    await inAppController.getPlans();
    if (inAppController.availablePlans.isNotEmpty) {
      setState(() {
        selectedPack = "credits_1";
      });
    }
  }

  void _showConfirmationDialog(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Achat confirmé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Fermer', style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 150,
        automaticallyImplyLeading: false,
        flexibleSpace: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset('assets/images/header_background.png', width: double.infinity, fit: BoxFit.cover, height: 200),
            Positioned(right: 16, top: 32, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())),
            Positioned(bottom: 50, width: 45, height: 45, child: SvgPicture.asset("assets/images/kapstr_white_clean.svg")),
            const Positioned(bottom: 16, child: Text("Activez votre évènement !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Packs
              Expanded(
                child: Consumer<InAppController>(
                  builder: (context, controller, child) {
                    if (controller.availablePlans.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<ProductDetails> sortedPlans = List.from(controller.availablePlans)..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          sortedPlans.map((plan) {
                            return buildPackCard(
                              id: plan.id,
                              title: plan.title,
                              description: plan.description,
                              details:
                                  plan.id == "credits_1"
                                      ? ["Activer 1 évènement", "Invités illimités", "Valable 1 an"]
                                      : plan.id == "credits_10"
                                      ? ["Activer 10 évènement", "Invités illimités"]
                                      : ["Activer 20 évènements", "Invités illimités"],
                              price: plan.price,
                              isSelected: selectedPack == plan.id,
                              economy:
                                  plan.id == "credits_1"
                                      ? ""
                                      : plan.id == "credits_10"
                                      ? "15% d’économie"
                                      : "51% d’économie",
                              catchline:
                                  plan.id == "credits_1"
                                      ? "Offre de lancement"
                                      : plan.id == "credits_10"
                                      ? "soit 59,99€/évènement"
                                      : "soit 39,90€/évènement",
                              onSelect: () {
                                setState(() {
                                  selectedPack = plan.id;
                                });
                              },
                            );
                          }).toList(),
                    );
                  },
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final selectedPlan = inAppController.availablePlans.firstWhere((plan) => plan.id == selectedPack, orElse: () => throw Exception("Plan introuvable"));

                              await inAppController.buyPlan(selectedPlan, context.read<UsersController>().user!.id);

                              if (widget.isCreditsEmpty) {
                                _showConfirmationDialog("Vous avez ajouté ${selectedPlan.title} crédits à votre compte !");
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                                _showConfirmationDialog("Vous avez ajouté ${selectedPlan.title} crédits à votre compte !");
                              }
                            } catch (e) {
                              // Gérer les erreurs éventuelles
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Activer mon évènement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                    const SizedBox(height: 8),
                    const Text("Payez une fois, sans engagement", style: TextStyle(fontSize: 14, color: kBlack)),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading) Container(color: Colors.black.withOpacity(0.4), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget buildPackCard({required String id, required String title, required String description, required List<String> details, required String price, required String catchline, required String economy, bool isSelected = false, required VoidCallback onSelect}) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.02), border: Border.all(color: isSelected ? kPrimary : Colors.black.withValues(alpha: 0.8), width: 2), borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Align(alignment: Alignment.topRight, child: Radio(value: true, groupValue: isSelected, onChanged: (_) => onSelect(), activeColor: Colors.blue)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id == "credits_1"
                      ? "Standard"
                      : id == "credits_10"
                      ? "Pack X10"
                      : "Pack X20",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 2),
                Text(
                  id == "credits_1"
                      ? "Idéal pour un mariage, anniversaire..."
                      : id == "credits_10"
                      ? "Remise de -25%"
                      : "Remise de -50%",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                ...details.map(
                  (detail) => Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.black),
                      const SizedBox(width: 8),
                      detail.contains('Activer') ? Text(detail, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w700)) : Text(detail, style: const TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: Text(economy, style: const TextStyle(fontSize: 10, color: kPrimary))),
                Align(alignment: Alignment.centerRight, child: Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimary))),
                Align(alignment: Alignment.centerRight, child: Text(catchline, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: kBlack))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
