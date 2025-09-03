import 'package:cloud_firestore/cloud_firestore.dart';

enum FacilityType { recycling, wte, compost, biogas, scrapShop }
enum FacilityStatus { operational, maintenance, construction, closed }

class FacilityModel {
  final String id;
  final String name;
  final FacilityType type;
  final FacilityStatus status;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String capacity;
  final String contact;
  final String? email;
  final List<String> acceptedWasteTypes;
  final Map<String, String> operatingHours;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.contact,
    this.email,
    this.acceptedWasteTypes = const [],
    this.operatingHours = const {},
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FacilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FacilityModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: FacilityType.values.firstWhere(
        (e) => e.toString() == 'FacilityType.${data['type']}',
        orElse: () => FacilityType.recycling,
      ),
      status: FacilityStatus.values.firstWhere(
        (e) => e.toString() == 'FacilityStatus.${data['status']}',
        orElse: () => FacilityStatus.operational,
      ),
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      capacity: data['capacity'] ?? '',
      contact: data['contact'] ?? '',
      email: data['email'],
      acceptedWasteTypes: List<String>.from(data['acceptedWasteTypes'] ?? []),
      operatingHours: Map<String, String>.from(data['operatingHours'] ?? {}),
      rating: data['rating']?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'contact': contact,
      'email': email,
      'acceptedWasteTypes': acceptedWasteTypes,
      'operatingHours': operatingHours,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}