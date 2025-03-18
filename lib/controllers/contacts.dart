import 'package:flutter/material.dart';
import 'package:kapstr/models/contact.dart';

class ContactsController extends ChangeNotifier {
  final List<Contact> _contacts;
  final List<Contact> selectedContacts = [];

  ContactsController(List<Contact> contacts) : _contacts = contacts;

  List<Contact> get contacts => _contacts;

  void addContacts(List<Contact> contacts) {
    _contacts.clear();
    _contacts.addAll(contacts);
    notifyListeners();
  }

  void clear() {
    _contacts.clear();
    selectedContacts.clear();
    notifyListeners();
  }

  void toggleContacts(Contact contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
    notifyListeners();
  }
}
