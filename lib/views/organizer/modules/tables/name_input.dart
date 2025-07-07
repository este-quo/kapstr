import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class TableNameInput extends StatelessWidget {
  const TableNameInput({super.key, required this.tableNameController});

  final TextEditingController tableNameController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: TextField(
        controller: tableNameController,
        style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Nom de la table',
          hintStyle: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400),
          enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: const BorderSide(color: kBlack)),
          focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: const BorderSide(color: kBlack)),
        ),
        onChanged: (contactName) {},
      ),
    );
  }
}
