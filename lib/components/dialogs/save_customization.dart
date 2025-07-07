import 'package:flutter/material.dart';
import 'package:kapstr/components/buttons/primary_button.dart';
import 'package:kapstr/components/buttons/secondary_button.dart';
import 'package:kapstr/controllers/customization.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:provider/provider.dart';

class SaveCustomizationDialog extends StatelessWidget {
  final Module module;

  const SaveCustomizationDialog({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    Future updateAll() async {
      await context.read<CustomizationController>().updateAllCustomizations(context: context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }

    Future update() async {
      await context.read<CustomizationController>().updateCustomization(context: context, moduleId: module.id);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Voulez-vous appliquer ce style à tous vos modules ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
          const SizedBox(height: 32),
          PrimaryButton(onPressed: updateAll, text: "Appliquer partout"),
          const SizedBox(height: 16),
          SecondaryButton(onPressed: update, text: "Uniquement ce module"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
