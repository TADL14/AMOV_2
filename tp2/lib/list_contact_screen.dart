import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact.dart';
import 'contact_details_screen.dart';

class LastModifiedContactsScreen extends StatefulWidget {
  final List<Contact> contacts;
  const LastModifiedContactsScreen({
        super.key,
        required this.contacts,
      });

  @override
  _LastModifiedContactsScreenState createState() =>
      _LastModifiedContactsScreenState();
}

class _LastModifiedContactsScreenState
    extends State<LastModifiedContactsScreen> {
  List<Contact> _lastModifiedContacts = [];

  @override
  void initState() {
    super.initState();
    _loadLastModifiedContacts();
  }

  Future<void> _loadLastModifiedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final modifiedContactsJson = prefs.getStringList('lastModified') ?? [];
    final uniqueContacts = <String, Contact>{};

    for (final json in modifiedContactsJson.reversed) {
      final contact = Contact.fromJson(jsonDecode(json));
      uniqueContacts[contact.number] = contact;
    }

    setState(() {
      _lastModifiedContacts = uniqueContacts.values.toList().reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Modified Contacts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _lastModifiedContacts.isEmpty
          ? const Center(
        child: Text(
          'No recently modified contacts.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _lastModifiedContacts.length,
        itemBuilder: (context, index) {
          final contact = _lastModifiedContacts[index];
          return ModifiedContactCard(
            contact: contact,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ContactDetailsScreen(
                    contact: contact,
                    contacts: _lastModifiedContacts,
                    onUpdate: (updatedContact) {
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}

class ModifiedContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ModifiedContactCard({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.blue, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact.number,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

