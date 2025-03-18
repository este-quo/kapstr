// import 'package:flutter/material.dart';
// import 'package:kapstr/configuration/navigation/navigation_service.dart';
// import 'package:kapstr/controllers/themes.dart';
// import 'package:kapstr/helpers/debug_helper.dart';
// import 'package:kapstr/widgets/custom_svg_picture.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   AnimationController? _controller;
//   Animation<double>? _animation;

//   @override
//   void initState() {
//     super.initState();
//     initThemes();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..addListener(() => setState(() {}));
//     _animation = Tween(begin: 0.0, end: 1.0).animate(_controller!);
//     _controller!.forward();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(seconds: 1), () {
//         if (mounted) {
//           NavigationService.instance.navigate('/entry');
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     if (_controller != null) {
//       _controller!.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> initThemes() async {
//     printOnDebug('Fetching themes');
//     await context.read<ThemeController>().fetchAllThemes();
//     printOnDebug('Themes fetched');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(color: Colors.white),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FadeTransition(
//               opacity: _animation!,
//               child: const CustomAssetSvgPicture(
//                 'assets/splashscreen.svg',
//                 width: 250,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
