import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardProvider extends ChangeNotifier {
  List<RewardModel> _rewards = [];
  List<RewardRedemptionModel> _userRedemptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RewardModel> get rewards => _rewards;
  List<RewardRedemptionModel> get userRedemptions => _userRedemptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RewardProvider() {
    _initializeRewards();
  }

  void _initializeRewards() {
    _rewards = [
      RewardModel(
        id: 'eco_bag',
        title: 'Eco-Friendly Jute Bag',
        description: 'Handcrafted jute bag made from recycled materials',
        type: RewardType.physical,
        category: RewardCategory.ecoFriendly,
        pointsCost: 500,
        imageUrl: 'https://images.pexels.com/photos/4099238/pexels-photo-4099238.jpeg',
        stockQuantity: 100,
        createdAt: DateTime.now(),
      ),
      RewardModel(
        id: 'compost_kit',
        title: 'Home Composting Kit',
        description: 'Complete kit for making compost at home with instructions',
        type: RewardType.physical,
        category: RewardCategory.ecoFriendly,
        pointsCost: 800,
        imageUrl: 'https://images.pexels.com/photos/4503273/pexels-photo-4503273.jpeg',
        stockQuantity: 50,
        createdAt: DateTime.now(),
      ),
      RewardModel(
        id: 'dustbin_set',
        title: '3-Bin Waste Segregation Set',
        description: 'Color-coded bins for dry, wet, and hazardous waste',
        type: RewardType.physical,
        category: RewardCategory.ecoFriendly,
        pointsCost: 1200,
        imageUrl: 'https://images.pexels.com/photos/3735218/pexels-photo-3735218.jpeg',
        stockQuantity: 75,
        createdAt: DateTime.now(),
      ),
      RewardModel(
        id: 'plant_seeds',
        title: 'Native Plant Seeds Pack',
        description: 'Collection of native Indian plant seeds for home gardening',
        type: RewardType.physical,
        category: RewardCategory.ecoFriendly,
        pointsCost: 300,
        imageUrl: 'https://images.pexels.com/photos/1301856/pexels-photo-1301856.jpeg',
        stockQuantity: 200,
        createdAt: DateTime.now(),
      ),
      RewardModel(
        id: 'eco_certificate',
        title: 'Eco Warrior Certificate',
        description: 'Digital certificate recognizing your environmental efforts',
        type: RewardType.certificate,
        category: RewardCategory.educational,
        pointsCost: 1000,
        imageUrl: 'https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg',
        stockQuantity: -1, // Unlimited
        createdAt: DateTime.now(),
      ),
      RewardModel(
        id: 'discount_voucher',
        title: '20% Off Eco Products',
        description: 'Discount voucher for eco-friendly products at partner stores',
        type: RewardType.discount,
        category: RewardCategory.lifestyle,
        pointsCost: 400,
        imageUrl: 'https://images.pexels.com/photos/3985062/pexels-photo-3985062.jpeg',
        stockQuantity: -1, // Unlimited
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> loadUserRedemptions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('reward_redemptions')
          .where('userId', isEqualTo: userId)
          .orderBy('redeemedAt', descending: true)
          .get();

      _userRedemptions = querySnapshot.docs
          .map((doc) => RewardRedemptionModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load redemptions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redeemReward(String userId, String rewardId, int userPoints, {String? deliveryAddress}) async {
    try {
      final reward = _rewards.firstWhere((r) => r.id == rewardId);
      
      if (userPoints < reward.pointsCost) {
        _errorMessage = 'Insufficient points for this reward';
        notifyListeners();
        return false;
      }

      if (reward.stockQuantity == 0) {
        _errorMessage = 'This reward is out of stock';
        notifyListeners();
        return false;
      }

      final redemption = RewardRedemptionModel(
        id: '',
        userId: userId,
        rewardId: rewardId,
        pointsUsed: reward.pointsCost,
        redeemedAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
      );

      await FirebaseFirestore.instance
          .collection('reward_redemptions')
          .add(redemption.toFirestore());

      // Update user points
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'points': FieldValue.increment(-reward.pointsCost),
      });

      // Update stock if not unlimited
      if (reward.stockQuantity > 0) {
        final updatedReward = RewardModel(
          id: reward.id,
          title: reward.title,
          description: reward.description,
          type: reward.type,
          category: reward.category,
          pointsCost: reward.pointsCost,
          imageUrl: reward.imageUrl,
          isAvailable: reward.isAvailable,
          stockQuantity: reward.stockQuantity - 1,
          metadata: reward.metadata,
          createdAt: reward.createdAt,
        );
        
        final index = _rewards.indexWhere((r) => r.id == rewardId);
        if (index != -1) {
          _rewards[index] = updatedReward;
        }
      }

      _userRedemptions.insert(0, redemption);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to redeem reward: $e';
      notifyListeners();
      return false;
    }
  }

  List<RewardModel> getRewardsByCategory(RewardCategory category) {
    return _rewards.where((r) => r.category == category && r.isAvailable).toList();
  }

  List<RewardModel> getAffordableRewards(int userPoints) {
    return _rewards.where((r) => r.pointsCost <= userPoints && r.isAvailable).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}