import 'package:flutter/material.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class GuestSearchBar extends StatefulWidget {
  const GuestSearchBar({super.key});

  @override
  State<GuestSearchBar> createState() => _GuestSearchBarState();
}

class _GuestSearchBarState extends State<GuestSearchBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          isDense: true,
          hintText: 'Rechercher des invités',
          hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
          suffixIcon: const Icon(Icons.search, color: kLightGrey, size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kLightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kLightGrey)),
        ),
        onChanged: (contactName) {
          context.read<PlacesController>().searchQuery = contactName;
        },
      ),
    );
  }
}
