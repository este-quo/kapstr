import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/credits/credits.dart';

class CreditDisplay extends StatelessWidget {
  final int credits;

  const CreditDisplay({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Redirection vers la page des crédits
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsPage(isCreditsEmpty: true)));
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 12.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Text('$credits', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimary)), const SizedBox(width: 15), Text(credits > 1 ? 'Crédits restants' : 'Crédit restant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black))]),
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 24)),
          ],
        ),
      ),
    );
  }
}
