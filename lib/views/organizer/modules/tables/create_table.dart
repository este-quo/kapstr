import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class CreateTableDialog extends StatefulWidget {
  const CreateTableDialog({super.key});

  @override
  _CreateTableDialogState createState() => _CreateTableDialogState();
}

class _CreateTableDialogState extends State<CreateTableDialog> {
  TextEditingController tableNameController = TextEditingController();
  bool isLoading = false;
  String? errorMessage; // Gérer les erreurs de validation

  Future<void> _createTable() async {
    // Validation du champ
    if (tableNameController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Le nom de la table ne peut pas être vide.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null; // Réinitialiser les erreurs en cas de nouvelle tentative
    });

    try {
      // Créer une nouvelle table via le TablesController
      await context.read<TablesController>().createTable(TableModel(name: tableNameController.text.trim()));
      Navigator.pop(context); // Fermer le dialog après succès
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la création de la table : $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une table', style: TextStyle(color: kBlack, fontSize: 20, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tableNameController,
              decoration: InputDecoration(
                labelText: 'Nom de la table',
                border: const OutlineInputBorder(),
                errorText: errorMessage, // Afficher le message d'erreur si nécessaire
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    errorMessage = null; // Supprimer l'erreur si le champ est rempli
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createTable,
                style: ElevatedButton.styleFrom(backgroundColor: kBlack, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: isLoading ? const CircularProgressIndicator(color: kWhite) : const Text('Valider', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCreateTableDialog(BuildContext context) async {
  showDialog(context: context, builder: (context) => const CreateTableDialog());
}
