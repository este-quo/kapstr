import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/login/mail/signin.dart';
import 'package:kapstr/views/global/phone_verification/request.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) return; // Already loading
    if (!_formKey.currentState!.validate()) return; // Form is not valid

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthenticationController>().registerWithEmail(_emailController.text, _passwordController.text, _firstNameController.text, _lastNameController.text);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberRequestUI()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur d\'inscription: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MainButton(onPressed: _register, child: _isLoading ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 32) : const Text('Valider', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))),
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text('Inscription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
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
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _firstNameController,
                        decoration: _inputDecoration('Entrez votre prénom'),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _lastNameController,
                        decoration: _inputDecoration('Entrez votre nom'),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _emailController, decoration: _inputDecoration('Entrez votre adresse email'), keyboardType: TextInputType.emailAddress, validator: (value) => _validateEmail(value), style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Entrez votre mot de passe', isPassword: true),
                        obscureText: _isObscured,
                        validator: (value) => _validatePassword(value),
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: _inputDecoration('Confirmez le mot de passe', isPassword: true),
                        obscureText: _isObscured,
                        validator: (value) => _validateConfirmPassword(value),
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 24),
                      const Text('Nous utiliserons votre adresse mail pour vous avertir des mises à jours importantes et problèmes que vous pourriez rencontrer.', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmailSignIn()));
                        },
                        child: const Text('J\'ai déjà un compte', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un email';
    }
    if (!value.contains('@')) {
      return 'Veuillez entrer un email valide';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
