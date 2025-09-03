import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/waste_report_model.dart';
import '../models/facility_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Report Operations
  Future<void> createReport(WasteReportModel report) async {
    await _firestore.collection('reports').add(report.toFirestore());
  }

  Future<List<WasteReportModel>> getAllReports() async {
    final querySnapshot = await _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => WasteReportModel.fromFirestore(doc))
        .toList();
  }

  Future<List<WasteReportModel>> getUserReports(String userId) async {
    final querySnapshot = await _firestore
        .collection('reports')
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => WasteReportModel.fromFirestore(doc))
        .toList();
  }

  Future<List<WasteReportModel>> getCollectorReports(String collectorId) async {
    final querySnapshot = await _firestore
        .collection('reports')
        .where('collectorId', isEqualTo: collectorId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => WasteReportModel.fromFirestore(doc))
        .toList();
  }

  Future<void> assignReport(String reportId, String collectorId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'collectorId': collectorId,
      'status': ReportStatus.assigned.toString().split('.').last,
      'assignedAt': Timestamp.now(),
    });
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status, {String? notes}) async {
    final updateData = <String, dynamic>{
      'status': status.toString().split('.').last,
    };
    
    if (status == ReportStatus.resolved) {
      updateData['resolvedAt'] = Timestamp.now();
      updateData['pointsAwarded'] = 50; // Base points for resolution
    }
    
    if (notes != null) {
      updateData['resolutionNotes'] = notes;
    }
    
    await _firestore.collection('reports').doc(reportId).update(updateData);
  }

  // Facility Operations
  Future<List<FacilityModel>> getAllFacilities() async {
    final querySnapshot = await _firestore.collection('facilities').get();
    return querySnapshot.docs
        .map((doc) => FacilityModel.fromFirestore(doc))
        .toList();
  }

  Future<List<FacilityModel>> getNearbyFacilities(
    double latitude, 
    double longitude, 
    double radiusKm
  ) async {
    // In production, use GeoFirestore for efficient geospatial queries
    final querySnapshot = await _firestore.collection('facilities').get();
    final facilities = querySnapshot.docs
        .map((doc) => FacilityModel.fromFirestore(doc))
        .toList();
    
    return facilities.where((facility) {
      final distance = _calculateDistance(
        latitude, longitude,
        facility.latitude, facility.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // Image Upload
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Note: Using Drive links instead of direct upload to reduce storage costs
  Future<String> processDriveLink(String driveLink) async {
    // Convert Google Drive share link to direct access link
    if (driveLink.contains('drive.google.com/file/d/')) {
      final fileId = driveLink.split('/d/')[1].split('/')[0];
      return 'https://drive.google.com/uc?id=$fileId';
    }
    return driveLink;
  }

  // Utility Methods
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula for calculating distance between two points
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getAnalytics() async {
    final reportsSnapshot = await _firestore.collection('reports').get();
    final usersSnapshot = await _firestore.collection('users').get();
    
    return {
      'totalReports': reportsSnapshot.size,
      'totalUsers': usersSnapshot.size,
      'resolvedReports': reportsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'resolved')
          .length,
      'activeCollectors': usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'wasteCollector')
          .length,
    };
  }
}

extension on double {
  double sin() => 0.0; // Placeholder - use dart:math in production
  double cos() => 0.0; // Placeholder - use dart:math in production
  double asin() => 0.0; // Placeholder - use dart:math in production
  double sqrt() => 0.0; // Placeholder - use dart:math in production
}