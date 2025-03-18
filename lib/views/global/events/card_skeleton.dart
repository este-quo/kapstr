import 'package:flutter/material.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

class CardSkeleton extends StatelessWidget {
  final int count;
  const CardSkeleton({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: LoadingSkeleton(
              colors: const [Color.fromARGB(12, 0, 0, 0), Color.fromARGB(34, 0, 0, 0), Color.fromARGB(6, 0, 0, 0)],
              width: MediaQuery.of(context).size.width - 40,
              height: 140,
            ),
          ),
        );
      }),
    );
  }
}
