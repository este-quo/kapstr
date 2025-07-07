import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class SearchBarGuest extends StatefulWidget {
  final TextEditingController searchController;

  const SearchBarGuest({super.key, required this.searchController});

  @override
  State<SearchBarGuest> createState() => _SearchBarGuestState();
}

class _SearchBarGuestState extends State<SearchBarGuest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      child: TextField(
        controller: widget.searchController,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: kDarkGrey, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          hintText: 'Chercher des invités',
          hintStyle: const TextStyle(color: kDarkGrey, fontSize: 14),
          suffixIcon: const Icon(Icons.search, color: kDarkGrey, size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kLightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kDarkGrey)),
        ),
      ),
    );
  }
}
