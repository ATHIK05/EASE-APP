import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardType { physical, digital, discount, certificate }
enum RewardCategory { ecoFriendly, educational, lifestyle, community }

class RewardModel {
  final String id;
  final String title;
  final String description;
  final RewardType type;
  final RewardCategory category;
  final int pointsCost;
  final String imageUrl;
  final bool isAvailable;
  final int stockQuantity;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.pointsCost,
    required this.imageUrl,
    this.isAvailable = true,
    this.stockQuantity = 0,
    this.metadata = const {},
    required this.createdAt,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: RewardType.values.firstWhere(
        (e) => e.toString() == 'RewardType.${data['type']}',
        orElse: () => RewardType.physical,
      ),
      category: RewardCategory.values.firstWhere(
        (e) => e.toString() == 'RewardCategory.${data['category']}',
        orElse: () => RewardCategory.ecoFriendly,
      ),
      pointsCost: data['pointsCost'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      stockQuantity: data['stockQuantity'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'pointsCost': pointsCost,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class RewardRedemptionModel {
  final String id;
  final String userId;
  final String rewardId;
  final int pointsUsed;
  final DateTime redeemedAt;
  final String status; // pending, approved, delivered, cancelled
  final String? deliveryAddress;
  final String? trackingNumber;

  RewardRedemptionModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.pointsUsed,
    required this.redeemedAt,
    this.status = 'pending',
    this.deliveryAddress,
    this.trackingNumber,
  });

  factory RewardRedemptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardRedemptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      rewardId: data['rewardId'] ?? '',
      pointsUsed: data['pointsUsed'] ?? 0,
      redeemedAt: (data['redeemedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      deliveryAddress: data['deliveryAddress'],
      trackingNumber: data['trackingNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'rewardId': rewardId,
      'pointsUsed': pointsUsed,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
      'status': status,
      'deliveryAddress': deliveryAddress,
      'trackingNumber': trackingNumber,
    };
  }
}