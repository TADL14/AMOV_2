import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_contact_screen.dart';
import 'contact.dart';
import 'contact_details_screen.dart';
import 'list_contact_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (context) => const MyHomePage(title: 'Contacts')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  static const String routeName = '/main_screen';

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<Contact> _contacts = [];

  bool expand = false;

  Future<File> _getLocalFile() async {
    final directory = Directory.systemTemp;
    final path = '${directory.path}/contacts.json';
    return File(path);
  }

  Future<void> _saveContacts() async {
    try {
      final file = await _getLocalFile();
      final jsonContacts = jsonEncode(
        _contacts.map((contact) => contact.toJson()).toList(),
      );
      await file.writeAsString(jsonContacts);
    } catch (e) {
      print('Error saving contacts: $e');
    }
  }

  Future<void> _loadContacts() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonContacts = jsonDecode(jsonString);
        setState(() {
          _contacts.clear();
          _contacts.addAll(jsonContacts.map((json) => Contact.fromJson(json)));
        });
      }
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // _clearLastModified();
    _loadContacts();
  }

  Future<void> _clearLastModified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastModified');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              setState(() {
                expand = !expand;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LastModifiedContactsScreen(
                  contacts: _contacts
                )),
              );
            },
            tooltip: 'Last Modified Contacts',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newContact = await Navigator.of(context).push<Contact>(
                MaterialPageRoute(
                  builder: (context) => AddcontactScreen(contacts: _contacts),
                ),
              );
              if (newContact != null) {
                setState(() {
                  _contacts.add(newContact);
                });
                _saveContacts();
              }
            },
            tooltip: 'Add Contact',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _contacts.isEmpty
          ? const Center(
        child: Text(
          'No contacts available. Add a contact!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          if (!expand) {
            return ContactCard(
              contact: contact,
              onTap: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ContactDetailsScreen(
                          contact: contact,
                          contacts: _contacts,
                          onUpdate: (updatedContact) {
                            setState(() {
                              final index = _contacts.indexOf(contact);
                              if (index != -1) {
                                _contacts[index] = updatedContact;
                              }
                            });
                            _saveContacts();
                          },
                        )
                    )
                );
              },
            );
          } else {
            return ContactCardExpanded(
              contact: contact,
              onTap: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ContactDetailsScreen(
                          contact: contact,
                          contacts: _contacts,
                          onUpdate: (updatedContact) {
                            setState(() {
                              final index = _contacts.indexOf(contact);
                              if (index != -1) {
                                _contacts[index] = updatedContact;
                              }
                            });
                            _saveContacts();
                          },
                        )
                    )
                );
              },
            );
          }
        },
      ),
    );
  }

}

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactCard({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.orange, width: 1.5),
        ),
        child: Text(
          contact.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class ContactCardExpanded extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactCardExpanded({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.orange, width: 1.5),
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
            const SizedBox(height: 4),
            Text(
              contact.email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            if (contact.birthdate != null)
            Text(
              contact.birthdate!.toLocal().toString().split(' ')[0],
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
