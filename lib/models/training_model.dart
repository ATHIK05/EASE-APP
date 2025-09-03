import 'package:cloud_firestore/cloud_firestore.dart';

enum TrainingType { citizen, wasteWorker, greenChampion }
enum TrainingStatus { notStarted, inProgress, completed, certified }

class TrainingModel {
  final String id;
  final String title;
  final String description;
  final TrainingType type;
  final TrainingStatus status;
  final int duration; // in minutes
  final String difficulty;
  final int pointsReward;
  final List<String> modules;
  final List<String> videoUrls;
  final Map<String, dynamic> quizData;
  final DateTime? completedAt;
  final String? certificateUrl;
  final bool isMandatory;
  final int order;

  TrainingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = TrainingStatus.notStarted,
    required this.duration,
    required this.difficulty,
    required this.pointsReward,
    this.modules = const [],
    this.videoUrls = const [],
    this.quizData = const {},
    this.completedAt,
    this.certificateUrl,
    this.isMandatory = false,
    this.order = 0,
  });

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: TrainingType.values.firstWhere(
        (e) => e.toString() == 'TrainingType.${data['type']}',
        orElse: () => TrainingType.citizen,
      ),
      status: TrainingStatus.values.firstWhere(
        (e) => e.toString() == 'TrainingStatus.${data['status']}',
        orElse: () => TrainingStatus.notStarted,
      ),
      duration: data['duration'] ?? 0,
      difficulty: data['difficulty'] ?? 'Beginner',
      pointsReward: data['pointsReward'] ?? 0,
      modules: List<String>.from(data['modules'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      quizData: Map<String, dynamic>.from(data['quizData'] ?? {}),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      certificateUrl: data['certificateUrl'],
      isMandatory: data['isMandatory'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'duration': duration,
      'difficulty': difficulty,
      'pointsReward': pointsReward,
      'modules': modules,
      'videoUrls': videoUrls,
      'quizData': quizData,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'certificateUrl': certificateUrl,
      'isMandatory': isMandatory,
      'order': order,
    };
  }
}

class GreenChampionModel {
  final String id;
  final String userId;
  final String areaCode;
  final String areaName;
  final String designation;
  final DateTime appointedAt;
  final List<String> responsibilities;
  final Map<String, int> performanceMetrics;
  final bool isActive;

  GreenChampionModel({
    required this.id,
    required this.userId,
    required this.areaCode,
    required this.areaName,
    required this.designation,
    required this.appointedAt,
    this.responsibilities = const [],
    this.performanceMetrics = const {},
    this.isActive = true,
  });

  factory GreenChampionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GreenChampionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      areaCode: data['areaCode'] ?? '',
      areaName: data['areaName'] ?? '',
      designation: data['designation'] ?? '',
      appointedAt: (data['appointedAt'] as Timestamp).toDate(),
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      performanceMetrics: Map<String, int>.from(data['performanceMetrics'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'areaCode': areaCode,
      'areaName': areaName,
      'designation': designation,
      'appointedAt': Timestamp.fromDate(appointedAt),
      'responsibilities': responsibilities,
      'performanceMetrics': performanceMetrics,
      'isActive': isActive,
    };
  }
}