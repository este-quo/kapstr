import 'package:flutter/material.dart';
import 'package:kapstr/configuration/navigation/app_router.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/views/global/login/create_or_join.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:provider/provider.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationController>();

    if (authProvider.user != null) {
      // User is authenticated, redirect to AppRouter
      return const AppRouter();
    } else {
      // User is not authenticated, show LogIn
      return const CreateOrJoinPage();
    }
  }
}
