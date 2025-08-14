import 'package:flutter/material.dart';
import 'package:kapstr/components/buttons/secondary_button.dart';
import 'package:kapstr/views/global/events/joining/enter_code.dart';

import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';

class CreateOrJoinPage extends StatefulWidget {
  const CreateOrJoinPage({super.key});

  @override
  State<CreateOrJoinPage> createState() => _CreateOrJoinPageState();
}

class _CreateOrJoinPageState extends State<CreateOrJoinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Center(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 164),

                // Logo Kapstr
                Image.asset('assets/logos/kapstr_logo.png', width: MediaQuery.of(context).size.width * 0.4),

                // Introduction text
                SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: const Text('Créez votre faire part 100% mobile et partagez chaque moment.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))),

                const Spacer(),
                // Buttons
                MainButton(
                  child: const Text('Créer mon événement', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LogIn()));
                  },
                ),

                const SizedBox(height: 8),

                // 'ou' with lines
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Expanded(child: Divider(color: kLightGrey)), SizedBox(width: 12), Text('ou', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kLightGrey)), SizedBox(width: 12), Expanded(child: Divider(color: kLightGrey))],
                ),

                const SizedBox(height: 8),

                MainButton(
                  backgroundColor: kPrimary,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EnterGuestCode()));
                  },
                  child: const Text('Rejoindre', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                ),

                const SizedBox(height: 16),

                SecondaryButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LogIn()));
                  },
                  text: "Me connecter",
                  icon: Icons.login,
                ),

                const SizedBox(height: 116),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
