// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kapstr/views/organizer/account/feature.dart';
import 'package:kapstr/views/organizer/account/feature_sections.dart';
import 'package:kapstr/views/organizer/account/udpate_event.dart';
import 'package:kapstr/themes/constants.dart';

class EventSettingsPage extends StatefulWidget {
  const EventSettingsPage({super.key});

  @override
  EventSettingsPageState createState() => EventSettingsPageState();
}

class EventSettingsPageState extends State<EventSettingsPage> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: kBlack), Text('Retour', style: TextStyle(color: kBlack, fontSize: 14, fontWeight: FontWeight.w500))])),
        ),
        centerTitle: false,
        leadingWidth: 75,
        toolbarHeight: 40,
      ),
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(color: Colors.transparent, width: double.infinity, child: const Padding(padding: EdgeInsets.only(right: 20, left: 20, bottom: 12), child: Text('Mon événement', textAlign: TextAlign.left, style: TextStyle(fontSize: 24, color: kBlack, fontWeight: FontWeight.w600)))),
              const SizedBox(height: 12),
              FeaturesSection(
                children: [
                  // Account Features
                  AccountFeature(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventPage())).then((value) {
                        setState(() {});
                      });
                    },
                    title: const Text('Modifier les informations', style: TextStyle(fontSize: 14, color: kBlack, fontWeight: FontWeight.w400)),
                    icon: const Icon(Icons.edit_outlined, color: kBlack, size: 20),
                  ),

                  // Account Feature
                ],
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}
