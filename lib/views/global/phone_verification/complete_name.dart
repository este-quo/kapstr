import 'package:flutter/material.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/global/events/events.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';

class CompleteNameFormPage extends StatefulWidget {
  const CompleteNameFormPage({super.key});

  @override
  State<CompleteNameFormPage> createState() => _CompleteNameFormPageState();
}

class _CompleteNameFormPageState extends State<CompleteNameFormPage> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signIn() async {
      if (_isLoading) return;
      if (!formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      context.read<UsersController>().updateUserFields({'name': '${firstnameController.text} ${lastnameController.text}'});

      setState(() {
        _isLoading = false;
      });

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyEvents()), (route) => false);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MainButton(onPressed: signIn, child: _isLoading ? const PulsatingLogo(svgPath: 'assets/icons/app/svg_dark.svg', size: 64) : const Text('Suivant', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w400))),
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text('Nom et prénom', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kBlack)),
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
                        textCapitalization: TextCapitalization.sentences,
                        controller: firstnameController,
                        decoration: _inputDecoration('Prénom'),
                        keyboardType: TextInputType.name,
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: lastnameController,
                        decoration: _inputDecoration('Nom'),
                        style: const TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w400),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
