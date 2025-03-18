import 'package:flutter/material.dart';
import 'package:kapstr/configuration/app_initializer/app_initializer.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/views/global/login/mail/signup.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signIn() async {
      if (_isLoading) return;
      if (!formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      try {
        await context.read<AuthenticationController>().signInWithEmail(emailController.text, passwordController.text);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyEvents()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur s\'est produite. Veuillez réessayer.', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))));
      } finally {
        // Ensure loading state is reset
        setState(() => _isLoading = false);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MainButton(onPressed: signIn, child: _isLoading ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32) : const Text('Se connecter', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))),
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text('Connexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: kBlack),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration('Email'),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: _inputDecoration('Mot de passe', isPassword: true),
                        obscureText: _isObscured,
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmailSignUp()));
                        },
                        child: const Text('Je n\'ai pas de compte', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, {bool isPassword = false}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      hintText: hintText,
      hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
      border: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                iconSize: 20,
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
              : null,
    );
  }
}
