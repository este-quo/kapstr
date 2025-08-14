import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kapstr/themes/constants.dart';

class MessageEditorDialog extends StatefulWidget {
  final String initialMessage;

  const MessageEditorDialog({super.key, required this.initialMessage});

  @override
  _MessageEditorDialogState createState() => _MessageEditorDialogState();
}

class _MessageEditorDialogState extends State<MessageEditorDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: kWhite,
      surfaceTintColor: kWhite,
      title: const Text('Modifier le message', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      content: Container(
        decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12.0), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(0, 2))]),
        child: TextField(
          controller: _controller,
          maxLines: null,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            hintText: "Tapez votre message ici...",
            prefixIcon: const Icon(Icons.edit, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kPrimary, width: 2.0)),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Annuler l'envoi
          },
          child: const Text('Annuler', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _controller.text));
            Navigator.of(context).pop(_controller.text); // Valider le message modifié
          },
          child: const Text('Copier', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }
}
