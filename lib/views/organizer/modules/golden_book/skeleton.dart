import 'package:flutter/material.dart';

class GuestTileSkeleton extends StatelessWidget {
  const GuestTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Placeholder for the profile picture
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),

          // Placeholder for the name and message
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for the name
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),

                // Placeholder for the message
                Container(
                  width: 160,
                  height: 14,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),

          // Placeholder for the arrow icon
          Icon(
            Icons.arrow_forward_rounded,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
