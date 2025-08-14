import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/organizer/guest_manager/display_all_contacts.dart';
import 'package:kapstr/views/organizer/guest_manager/display_module_contacts.dart';

class ModuleFiltersTab extends StatelessWidget {
  const ModuleFiltersTab({super.key});

  bool shouldFilterModule(Module module) {
    return kNonEventModules.contains(module.type);
  }

  @override
  Widget build(BuildContext context) {
    List<Module> modules = Event.instance.modules.where((module) => !shouldFilterModule(module)).toList();

    return DefaultTabController(
      length: modules.length + 1,
      initialIndex: 0,
      child: Column(
        children: <Widget>[
          TabBar(
            dividerColor: kWhite,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            isScrollable: true,
            indicatorColor: kYellow,
            labelColor: kYellow,
            unselectedLabelColor: kGrey,
            unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: [const Tab(text: 'Tous'), for (var module in modules) Tab(text: module.name)],
          ),
          Container(
            height: MediaQuery.of(context).size.height - (Platform.isIOS ? 46 : 58) - 48 - 92,
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
            child: TabBarView(children: <Widget>[const DisplayAllContacts(), for (var module in modules) DisplayModuleContacts(moduleName: module.name, moduleId: module.id)]),
          ),
        ],
      ),
    );
  }
}
