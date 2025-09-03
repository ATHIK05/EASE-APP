import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_model.dart';
import '../models/user_model.dart';

class TrainingProvider extends ChangeNotifier {
  List<TrainingModel> _citizenTrainings = [];
  List<TrainingModel> _workerTrainings = [];
  List<TrainingModel> _championTrainings = [];
  List<GreenChampionModel> _greenChampions = [];
  Map<String, TrainingStatus> _userProgress = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<TrainingModel> get citizenTrainings => _citizenTrainings;
  List<TrainingModel> get workerTrainings => _workerTrainings;
  List<TrainingModel> get championTrainings => _championTrainings;
  List<GreenChampionModel> get greenChampions => _greenChampions;
  Map<String, TrainingStatus> get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TrainingProvider() {
    _initializeTrainings();
  }

  void _initializeTrainings() {
    _citizenTrainings = [
      TrainingModel(
        id: 'citizen_basic',
        title: 'Basic Waste Management for Citizens',
        description: 'Learn the fundamentals of waste segregation and disposal',
        type: TrainingType.citizen,
        duration: 30,
        difficulty: 'Beginner',
        pointsReward: 200,
        isMandatory: true,
        order: 1,
        modules: [
          'Types of Waste',
          'Source Segregation',
          '3-Bin System',
          'Common Mistakes'
        ],
        quizData: {
          'questions': [
            {
              'question': 'Which bin should banana peels go into?',
              'options': ['Blue (Dry)', 'Green (Wet)', 'Red (Hazardous)', 'Any bin'],
              'correct': 1,
              'explanation': 'Organic waste like banana peels goes in the green (wet) bin.'
            },
            {
              'question': 'What percentage of India\'s waste is currently treated scientifically?',
              'options': ['34%', '54%', '74%', '84%'],
              'correct': 1,
              'explanation': 'According to CPCB data, only 54% of India\'s waste is scientifically treated.'
            }
          ]
        },
      ),
      TrainingModel(
        id: 'citizen_composting',
        title: 'Home Composting Mastery',
        description: 'Create nutrient-rich compost from kitchen waste',
        type: TrainingType.citizen,
        duration: 45,
        difficulty: 'Intermediate',
        pointsReward: 300,
        isMandatory: true,
        order: 2,
        modules: [
          'Composting Science',
          'DIY Compost Bin Setup',
          'Maintenance & Troubleshooting',
          'Using Finished Compost'
        ],
      ),
      TrainingModel(
        id: 'citizen_plastic_reuse',
        title: 'Creative Plastic Reuse',
        description: 'Transform plastic waste into useful household items',
        type: TrainingType.citizen,
        duration: 35,
        difficulty: 'Intermediate',
        pointsReward: 250,
        isMandatory: false,
        order: 3,
        modules: [
          'Plastic Types & Properties',
          'Creative Reuse Ideas',
          'Safety Guidelines',
          'Community Sharing'
        ],
      ),
    ];

    _workerTrainings = [
      TrainingModel(
        id: 'worker_safety',
        title: 'Waste Worker Safety Protocols',
        description: 'Essential safety measures and protective equipment usage',
        type: TrainingType.wasteWorker,
        duration: 60,
        difficulty: 'Advanced',
        pointsReward: 400,
        isMandatory: true,
        order: 1,
        modules: [
          'Personal Protective Equipment',
          'Hazardous Waste Handling',
          'Emergency Procedures',
          'Health Monitoring'
        ],
      ),
      TrainingModel(
        id: 'worker_collection',
        title: 'Efficient Collection Techniques',
        description: 'Optimize waste collection routes and methods',
        type: TrainingType.wasteWorker,
        duration: 40,
        difficulty: 'Intermediate',
        pointsReward: 300,
        isMandatory: true,
        order: 2,
        modules: [
          'Route Optimization',
          'Vehicle Maintenance',
          'Customer Interaction',
          'Quality Control'
        ],
      ),
    ];

    _championTrainings = [
      TrainingModel(
        id: 'champion_leadership',
        title: 'Green Champion Leadership',
        description: 'Lead your community towards sustainable waste management',
        type: TrainingType.greenChampion,
        duration: 90,
        difficulty: 'Advanced',
        pointsReward: 500,
        isMandatory: true,
        order: 1,
        modules: [
          'Community Engagement',
          'Monitoring Systems',
          'Conflict Resolution',
          'Data Analysis'
        ],
      ),
    ];
  }

  Future<void> loadUserProgress(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final progressDoc = await FirebaseFirestore.instance
          .collection('user_training_progress')
          .doc(userId)
          .get();

      if (progressDoc.exists) {
        final data = progressDoc.data() as Map<String, dynamic>;
        _userProgress = Map<String, TrainingStatus>.from(
          data.map((key, value) => MapEntry(
            key,
            TrainingStatus.values.firstWhere(
              (e) => e.toString() == 'TrainingStatus.$value',
              orElse: () => TrainingStatus.notStarted,
            ),
          )),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load training progress: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeTraining(String userId, String trainingId, int score) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_training_progress')
          .doc(userId)
          .set({
        trainingId: TrainingStatus.completed.toString().split('.').last,
      }, SetOptions(merge: true));

      // Award certificate for mandatory trainings
      final training = _getTrainingById(trainingId);
      if (training?.isMandatory == true && score >= 80) {
        await _awardCertificate(userId, trainingId);
      }

      _userProgress[trainingId] = TrainingStatus.completed;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to complete training: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _awardCertificate(String userId, String trainingId) async {
    // Generate certificate and store URL
    final certificateUrl = 'certificates/${userId}_$trainingId.pdf';
    
    await FirebaseFirestore.instance
        .collection('certificates')
        .add({
      'userId': userId,
      'trainingId': trainingId,
      'certificateUrl': certificateUrl,
      'issuedAt': Timestamp.now(),
      'isValid': true,
    });
  }

  TrainingModel? _getTrainingById(String id) {
    for (final training in [..._citizenTrainings, ..._workerTrainings, ..._championTrainings]) {
      if (training.id == id) return training;
    }
    return null;
  }

  List<TrainingModel> getTrainingsForRole(UserRole role) {
    switch (role) {
      case UserRole.wasteProvider:
        return _citizenTrainings;
      case UserRole.wasteCollector:
        return _workerTrainings;
      case UserRole.admin:
        return _championTrainings;
    }
  }

  double getCompletionPercentage(UserRole role) {
    final trainings = getTrainingsForRole(role);
    final completed = trainings.where((t) => 
        _userProgress[t.id] == TrainingStatus.completed).length;
    return trainings.isEmpty ? 0.0 : completed / trainings.length;
  }

  bool isMandatoryTrainingComplete(UserRole role) {
    final mandatoryTrainings = getTrainingsForRole(role)
        .where((t) => t.isMandatory).toList();
    
    return mandatoryTrainings.every((t) => 
        _userProgress[t.id] == TrainingStatus.completed);
  }

  Future<void> appointGreenChampion(String userId, String areaCode, String areaName) async {
    try {
      final champion = GreenChampionModel(
        id: '',
        userId: userId,
        areaCode: areaCode,
        areaName: areaName,
        designation: 'Area Green Champion',
        appointedAt: DateTime.now(),
        responsibilities: [
          'Monitor waste segregation in assigned area',
          'Conduct community awareness programs',
          'Report violations and improvements',
          'Coordinate with waste collection teams',
        ],
      );

      await FirebaseFirestore.instance
          .collection('green_champions')
          .add(champion.toFirestore());

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to appoint Green Champion: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}