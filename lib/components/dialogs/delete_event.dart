import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class DeleteEventBottomDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteEventBottomDialog({super.key, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Confirmer la suppression', style: TextStyle(color: kBlack, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Êtes-vous sûr de vouloir quitter cet événement ? Vous pourrez toujours le rejoindre plus tard.', textAlign: TextAlign.center, style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kGrey, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: onCancel,
                child: const Text('Annuler', style: TextStyle(color: kBlack, fontWeight: FontWeight.w400, fontSize: 14)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kDanger, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: onConfirm,
                child: const Text('Supprimer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage example
Future<void> showDeleteEventDialog(BuildContext context, {required VoidCallback onConfirm}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir quitter cet événement ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
            },
          ),
          TextButton(
            child: const Text('Confirmer'),
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              onConfirm(); // Exécuter la confirmation
            },
          ),
        ],
      );
    },
  );
}
