import 'package:flutter/material.dart';
import 'package:kapstr/controllers/event_data.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/views/global/events/create/layout.dart';
import 'package:kapstr/views/global/events/create/text_field.dart';
import 'package:kapstr/views/global/events/create/woman/woman_infos.dart';
import 'package:provider/provider.dart';

class ManInfosUI extends StatefulWidget {
  const ManInfosUI({super.key});

  @override
  GetManInfosState createState() => GetManInfosState();
}

class GetManInfosState extends State<ManInfosUI> {
  final nameFormKey = GlobalKey<FormState>();
  final _manFirstNameFieldFocusNode = FocusNode();
  final _manSecondNameFieldFocusNode = FocusNode();
  final _surnameFieldFocusNode = FocusNode();

  TextEditingController firstNameManController = TextEditingController();
  TextEditingController lastNameManController = TextEditingController();

  @override
  void dispose() {
    firstNameManController.dispose();
    lastNameManController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = context.read<EventDataController>();

    Future<void> confirm() async {
      if (nameFormKey.currentState!.validate()) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WomanInfosUI()));
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: OnBoardingLayout(
        title: 'Informations mariés',
        confirm: confirm,
        children: [
          const SizedBox(height: 20),
          Form(
            key: nameFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingTextField(
                  focusNode: _manFirstNameFieldFocusNode,
                  suffixIcon: const SizedBox(),
                  isPassword: false,
                  keyboardType: TextInputType.text,
                  validateInput: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez renseigner le prénom du marié';
                    }
                    onboardingData.manFirstName = value;
                    return null;
                  },
                  title: 'Prénom du marié',
                  controller: firstNameManController,
                  onValidatedInput: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(_manSecondNameFieldFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                OnboardingTextField(
                  focusNode: _manSecondNameFieldFocusNode,
                  key: const Key('lastNameMan'),
                  suffixIcon: const SizedBox(),
                  isPassword: false,
                  keyboardType: TextInputType.text,
                  validateInput: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez renseigner le nom de famille du marié';
                    }
                    onboardingData.manLastName = value;
                    return null;
                  },
                  title: 'Nom de famille du marié',
                  controller: lastNameManController,
                  onValidatedInput: () {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(_surnameFieldFocusNode);
                  },
                ),
                mediumSpacerH(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
