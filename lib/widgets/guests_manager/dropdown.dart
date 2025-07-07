// Add a callback function in the DropDownAvailability widget
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class DropDownAvailability extends StatefulWidget {
  final Function(String) onAvailabilityChanged;

  const DropDownAvailability({super.key, required this.onAvailabilityChanged});

  @override
  State<DropDownAvailability> createState() => _DropDownAvailabilityState();
}

class _DropDownAvailabilityState extends State<DropDownAvailability> {
  String dropdownValue = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        dropdownColor: kWhite,
        elevation: 16,
        style: const TextStyle(color: kBlack),
        underline: Container(
          height: 1,
          color: dropdownColors[dropdownValue] ?? Colors.black, // Ensure there's a fallback color
        ),
        items: [
          DropdownMenuItem(
            value: 'Tous',
            child: Row(
              children: [
                Text('Tous'),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kWhite, // Couleur pour 'Tous'
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Accepté',
            child: Row(
              children: [
                Text('Confirmé(s)'),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Couleur pour 'Confirmé(s)'
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'En attente',
            child: Row(
              children: [
                Text('En attente'),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange, // Couleur pour 'En attente'
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Absent',
            child: Row(
              children: [
                Text('Absent(s)'),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Couleur pour 'Absent(s)'
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
          // Call the provided callback function with the new value
          widget.onAvailabilityChanged(newValue!);
        },
      ),
    );
  }
}
