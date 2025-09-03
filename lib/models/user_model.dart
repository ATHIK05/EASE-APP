import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { wasteProvider, wasteCollector, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final int points;
  final String level;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isVerified;
  final Map<String, dynamic>? collectorData;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.points = 0,
    this.level = 'Beginner',
    this.achievements = const [],
    required this.createdAt,
    required this.lastActive,
    this.isVerified = false,
    this.collectorData,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.wasteProvider,
      ),
      profileImageUrl: data['profileImageUrl'],
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      points: data['points'] ?? 0,
      level: data['level'] ?? 'Beginner',
      achievements: List<String>.from(data['achievements'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      isVerified: data['isVerified'] ?? false,
      collectorData: data['collectorData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'points': points,
      'level': level,
      'achievements': achievements,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isVerified': isVerified,
      'collectorData': collectorData,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    String? address,
    String? city,
    String? state,
    String? pincode,
    int? points,
    String? level,
    List<String>? achievements,
    DateTime? lastActive,
    bool? isVerified,
    Map<String, dynamic>? collectorData,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      points: points ?? this.points,
      level: level ?? this.level,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      collectorData: collectorData ?? this.collectorData,
    );
  }
}