import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact.dart';
import 'package:image_picker/image_picker.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact;
  final List<Contact> contacts;

  const EditContactScreen({
    super.key,
    required this.contact,
    required this.contacts,
  });

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _emailController;
  DateTime? _birthdate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _numberController = TextEditingController(text: widget.contact.number);
    _emailController = TextEditingController(text: widget.contact.email);
    _birthdate = widget.contact.birthdate;
    _imagePath = widget.contact.imagePath;
  }

  bool _isPhoneNumberValid(String number) {
    final regExp = RegExp(r'^\d+$');
    return regExp.hasMatch(number);
  }

  bool _isEmailValid(String email) {
    final regExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regExp.hasMatch(email);
  }

  bool _doesPhoneNumberExist(String number) {
    if (widget.contact.number == number) {
      return false;
    }
    return widget.contacts.any((contact) => contact.number == number);
  }


  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final number = _numberController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || number.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (!_isPhoneNumberValid(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must contain only digits.')),
      );
      return;
    }

    if (_doesPhoneNumberExist(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number already exists.')),
      );
      return;
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format.')),
      );
      return;
    }

    final newContact = Contact(
      name: name,
      number: number,
      email: email,
      birthdate: _birthdate,
      imagePath: _imagePath,
      locationData: widget.contact.locationData,
    );

    final prefs = await SharedPreferences.getInstance();
    List<String> modifiedContacts = prefs.getStringList('lastModified') ?? [];
    final contactJson = jsonEncode(newContact.toJson());
    modifiedContacts.insert(0, contactJson);
    if (modifiedContacts.length > 10) {
      modifiedContacts = modifiedContacts.sublist(0, 10);
    }
    await prefs.setStringList('lastModified', modifiedContacts);

    Navigator.of(context).pop(newContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveContact,
            tooltip: 'Save Contact',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthdate != null
                          ? 'Birthdate: ${_birthdate!.toLocal().toString().split(' ')[0]}'
                          : 'No Birthdate Selected',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _birthdate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthdate = pickedDate;
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imagePath != null
                          ? 'Image Selected'
                          : 'No Image Selected',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final pickedImage = await imagePicker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedImage != null) {
                        setState(() {
                          _imagePath = pickedImage.path;
                        });
                      }
                    },
                    child: const Text('Take Picture'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final pickedImage = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedImage != null) {
                        setState(() {
                          _imagePath = pickedImage.path;
                        });
                      }
                    },
                    child: const Text('Choose Picture'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
