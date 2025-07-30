import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'contact.dart';
import 'package:image_picker/image_picker.dart';


class AddcontactScreen extends StatefulWidget {
  final List<Contact> contacts;
  const AddcontactScreen({
    super.key,
    required this.contacts,
  });

  @override
  State<AddcontactScreen> createState() => _AddcontactScreenState();
}

class _AddcontactScreenState extends State<AddcontactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _birthdate;
  String? _imagePath;
  List<LatLng> _locationData = [];

  bool _isPhoneNumberValid(String number) {
    final regExp = RegExp(r'^\d+$');
    return regExp.hasMatch(number);
  }

  bool _isEmailValid(String email) {
    final regExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regExp.hasMatch(email);
  }

  bool _doesPhoneNumberExist(String number) {
    return widget.contacts.any((contact) => contact.number == number);
  }


  void _saveContact() {
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
      locationData: _locationData,
    );

    Navigator.of(context).pop(newContact);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Contact'),
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
                        initialDate: DateTime.now(),
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
