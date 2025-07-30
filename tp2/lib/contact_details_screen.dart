import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact.dart';
import 'edit_contact_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;
  final List<Contact> contacts;
  final Function(Contact updatedContact) onUpdate;

  const ContactDetailsScreen({
    super.key,
    required this.contact,
    required this.contacts,
    required this.onUpdate,
  });

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {

  late Contact _currentContact;

  @override
  void initState() {
    super.initState();
    _currentContact = widget.contact;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _getCurrentLocation() async {
    bool ServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!ServiceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _getCurrentLocation().then((position) async {
                setState(() {
                  bool locationExists = _currentContact.locationData!.any((latLng) =>
                  latLng.latitude == position.latitude &&
                      latLng.longitude == position.longitude);
                  if (!locationExists) {
                    _currentContact.locationData!.add(LatLng(position.latitude, position.longitude));
                  }
                });

                final prefs = await SharedPreferences.getInstance();
                List<String> modifiedContacts = prefs.getStringList('lastModified') ?? [];
                final contactJson = jsonEncode(_currentContact.toJson());
                modifiedContacts.insert(0, contactJson);
                if (modifiedContacts.length > 10) {
                  modifiedContacts = modifiedContacts.sublist(0, 10);
                }
                widget.onUpdate(_currentContact);
                await prefs.setStringList('lastModified', modifiedContacts);
              });
            },

          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedContact = await Navigator.of(context).push<Contact>(
                MaterialPageRoute(
                  builder: (context) => EditContactScreen(
                      contact: _currentContact,
                      contacts: widget.contacts
                  ),
                ),
              );
              if (updatedContact != null) {
                setState(() {
                  _currentContact = updatedContact;
                });
                widget.onUpdate(updatedContact);
                final index = widget.contacts.indexOf(widget.contact);
                if (index != -1) {
                  widget.contacts[index] = updatedContact;
                }
              }
            },
            tooltip: 'Edit Contact',
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child:
                SizedBox(
                  width: 300,
                  height: 300,
                  child: ClipRect(
                    child: _currentContact.imagePath != null
                        ? Image.file(
                      File(_currentContact.imagePath!),
                      fit: BoxFit.cover,
                    )
                        : Image.network('https://t3.ftcdn.net/jpg/02/01/33/54/360_F_201335438_CNpY0iWaXXAV95Gj8BPB0tEJlMcxWeaZ.jpg', fit: BoxFit.cover,)
                  ),
                ),
              ),
              Text(
                'Name:',
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                )
              ),
              Text(
                _currentContact.name,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Phone:',
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                  )
              ),
              Text(
                _currentContact.number,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Email:',
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                  )
              ),
              Text(
                _currentContact.email,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 8.0),
              if (_currentContact.birthdate != null)
                Text(
                  'Birthdate:',
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    )
                ),
              if (_currentContact.birthdate != null)
                Text(
                  _currentContact.birthdate!.toLocal().toString().split(' ')[0],
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              const SizedBox(height: 8.0),
              if (_currentContact.locationData!.isNotEmpty)
                Center(
                  child: SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentContact.locationData!.isNotEmpty ? _currentContact.locationData!.last : LatLng(0, 0),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                          "https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=AIzaSyDdCWSi7didWdBAML7OD8iZu5jusvnvp5I",
                          subdomains: const ['0', '1', '2', '3'],
                        ),
                        MarkerLayer(
                          markers: _currentContact.locationData!.isNotEmpty
                              ? _currentContact.locationData!.map((latLng) {
                            return Marker(
                              point: latLng,
                              width: 20.0,
                              height: 20.0,
                              child: const Icon(
                                Icons.location_on,
                                size: 20.0,
                                color: Colors.red,
                              ),
                            );
                          }).toList()
                              : [],
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
