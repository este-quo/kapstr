import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/tables.dart';
import 'package:kapstr/helpers/vibration.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/organizer/modules/tables/edit_table.dart';
import 'package:provider/provider.dart';

class TableCard extends StatelessWidget {
  final TableModel tableModel;
  final Module module;
  final int guestsNumber;

  const TableCard({super.key, required this.tableModel, required this.module, required this.guestsNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.table_chart, color: kPrimary),
        title: Text(tableModel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBlack)),
        subtitle: guestsNumber != 0 ? Text('$guestsNumber invités', style: const TextStyle(fontSize: 14, color: kGrey)) : SizedBox(),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (BuildContext context) {
            return [const PopupMenuItem(value: 'edit', child: Text('Modifier')), const PopupMenuItem(value: 'delete', child: Text('Supprimer'))];
          },
          icon: const Icon(Icons.more_vert, color: kBlack),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditTable(table: tableModel)));
        },
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditTable(table: tableModel)));
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cette table'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette table ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteTable(context);
              },
              child: const Text('Supprimer', style: TextStyle(color: kDanger)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTable(BuildContext context) async {
    triggerShortVibration();
    await context.read<TablesController>().removeTable(tableModel.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Table supprimée avec succès'), backgroundColor: kSuccess));
  }
}
