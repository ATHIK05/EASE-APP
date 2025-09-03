import 'package:cloud_firestore/cloud_firestore.dart';

enum WasteType { mixed, plastic, organic, electronic, construction, hazardous }
enum ReportStatus { pending, assigned, inProgress, resolved, rejected }
enum Priority { low, medium, high, urgent }

class WasteReportModel {
  final String id;
  final String reporterId;
  final String? collectorId;
  final String title;
  final String description;
  final WasteType wasteType;
  final ReportStatus status;
  final Priority priority;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final int pointsAwarded;
  final Map<String, dynamic>? metadata;

  WasteReportModel({
    required this.id,
    required this.reporterId,
    this.collectorId,
    required this.title,
    required this.description,
    required this.wasteType,
    this.status = ReportStatus.pending,
    this.priority = Priority.medium,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imageUrls = const [],
    required this.createdAt,
    this.assignedAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.pointsAwarded = 0,
    this.metadata,
  });

  factory WasteReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WasteReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      collectorId: data['collectorId'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      wasteType: WasteType.values.firstWhere(
        (e) => e.toString() == 'WasteType.${data['wasteType']}',
        orElse: () => WasteType.mixed,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${data['status']}',
        orElse: () => ReportStatus.pending,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == 'Priority.${data['priority']}',
        orElse: () => Priority.medium,
      ),
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      assignedAt: data['assignedAt'] != null 
          ? (data['assignedAt'] as Timestamp).toDate() 
          : null,
      resolvedAt: data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate() 
          : null,
      resolutionNotes: data['resolutionNotes'],
      pointsAwarded: data['pointsAwarded'] ?? 0,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'collectorId': collectorId,
      'title': title,
      'description': description,
      'wasteType': wasteType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolutionNotes': resolutionNotes,
      'pointsAwarded': pointsAwarded,
      'metadata': metadata,
    };
  }

  WasteReportModel copyWith({
    String? collectorId,
    String? title,
    String? description,
    WasteType? wasteType,
    ReportStatus? status,
    Priority? priority,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    String? resolutionNotes,
    int? pointsAwarded,
    Map<String, dynamic>? metadata,
  }) {
    return WasteReportModel(
      id: id,
      reporterId: reporterId,
      collectorId: collectorId ?? this.collectorId,
      title: title ?? this.title,
      description: description ?? this.description,
      wasteType: wasteType ?? this.wasteType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      metadata: metadata ?? this.metadata,
    );
  }
}