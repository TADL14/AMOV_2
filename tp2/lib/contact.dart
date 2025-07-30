import 'package:latlong2/latlong.dart';

class Contact {
  final String name;
  final String number;
  final String email;
  final DateTime? birthdate;
  final String? imagePath;
  List<LatLng>? locationData;

  Contact({
    required this.name,
    required this.number,
    required this.email,
    this.birthdate,
    this.imagePath,
    this.locationData,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'email': email,
      'birthdate': birthdate?.toIso8601String(),
      'imagePath': imagePath,
      'locationData': locationData?.map((latLng) {
        return {'latitude': latLng.latitude, 'longitude': latLng.longitude};
      }).toList(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      number: json['number'],
      email: json['email'],
      birthdate: json['birthdate'] != null
          ? DateTime.tryParse(json['birthdate'])
          : null,
      imagePath: json['imagePath'],
      locationData: json['locationData'] != null
          ? (json['locationData'] as List<dynamic>).map((location) {
        return LatLng(
          location['latitude'] as double,
          location['longitude'] as double,
        );
      }).toList()
          : [],
    );
  }
}
