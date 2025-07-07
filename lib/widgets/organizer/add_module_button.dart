import 'package:flutter/material.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:provider/provider.dart';

class AddModuleButton extends StatelessWidget {
  const AddModuleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: context.read<ThemeController>().getButtonColor(), borderRadius: BorderRadius.circular(99999), border: Border.all(color: const Color.fromARGB(30, 0, 0, 0), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icone +
          Image.asset('assets/icons/plus.png', width: 16, height: 16, color: context.read<ThemeController>().getButtonTextColor()),
          // const SizedBox(
          //   width: 12,
          // ),

          // // Texte Nouveau
          // Text(
          //   'Ajouter un module',
          //   style: TextStyle(
          //     color: context.read<ThemeController>().getButtonTextColor(),
          //     fontSize: 16,
          //     fontFamily: 'Inter',
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
        ],
      ),
    );
  }
}
