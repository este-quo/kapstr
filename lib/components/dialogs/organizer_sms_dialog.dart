import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class CoOrganizerSMSDialog extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onSkip;

  const CoOrganizerSMSDialog({super.key, required this.onSend, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Nouveau co-organisateur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: const Text("Voulez-vous envoyer un message à ce nouveau co-organisateur ?", style: TextStyle(fontSize: 16)),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary, // Couleur de fond pour "Envoyer"
                  ),
                  onPressed: onSend,
                  child: const Text('Envoyer', style: TextStyle(color: kWhite, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimary), // Bordure pour "Passer"
                  ),
                  onPressed: onSkip,
                  child: const Text('Passer', style: TextStyle(color: kPrimary, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
