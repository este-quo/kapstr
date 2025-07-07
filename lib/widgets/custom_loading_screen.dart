import 'package:flutter/material.dart';
import 'package:kapstr/widgets/pulse.dart';

class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => Scaffold(body: Container(height: double.infinity, width: double.infinity, color: Theme.of(context).scaffoldBackgroundColor, child: Center(child: SpinKitPulse(color: Theme.of(context).primaryColor)))));
  }
}
