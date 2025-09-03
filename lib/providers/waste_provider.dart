import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_report_model.dart';
import '../models/facility_model.dart';
import '../services/firebase_service.dart';

class WasteProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<WasteReportModel> _reports = [];
  List<FacilityModel> _facilities = [];
  List<WasteReportModel> _myReports = [];
  List<WasteReportModel> _assignedReports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WasteReportModel> get reports => _reports;
  List<FacilityModel> get facilities => _facilities;
  List<WasteReportModel> get myReports => _myReports;
  List<WasteReportModel> get assignedReports => _assignedReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _reports = await _firebaseService.getAllReports();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyReports(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _myReports = await _firebaseService.getUserReports(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load your reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAssignedReports(String collectorId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _assignedReports = await _firebaseService.getCollectorReports(collectorId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load assigned reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFacilities() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _facilities = await _firebaseService.getAllFacilities();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load facilities: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport(WasteReportModel report) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firebaseService.createReport(report);
      _myReports.insert(0, report);
      _reports.insert(0, report);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit report: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignReport(String reportId, String collectorId) async {
    try {
      await _firebaseService.assignReport(reportId, collectorId);
      
      // Update local state
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex != -1) {
        _reports[reportIndex] = _reports[reportIndex].copyWith(
          collectorId: collectorId,
          status: ReportStatus.assigned,
          assignedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign report: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReportStatus(String reportId, ReportStatus status, {String? notes}) async {
    try {
      await _firebaseService.updateReportStatus(reportId, status, notes: notes);
      
      // Update local state
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex != -1) {
        _reports[reportIndex] = _reports[reportIndex].copyWith(
          status: status,
          resolvedAt: status == ReportStatus.resolved ? DateTime.now() : null,
          resolutionNotes: notes,
        );
      }
      
      // Update assigned reports if applicable
      final assignedIndex = _assignedReports.indexWhere((r) => r.id == reportId);
      if (assignedIndex != -1) {
        _assignedReports[assignedIndex] = _assignedReports[assignedIndex].copyWith(
          status: status,
          resolvedAt: status == ReportStatus.resolved ? DateTime.now() : null,
          resolutionNotes: notes,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update report: $e';
      notifyListeners();
      return false;
    }
  }

  List<FacilityModel> getNearbyFacilities(double latitude, double longitude, double radiusKm) {
    return _facilities.where((facility) {
      final distance = _calculateDistance(
        latitude, longitude,
        facility.latitude, facility.longitude,
      );
      return distance <= radiusKm && facility.status == FacilityStatus.operational;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation - in production, use proper geospatial calculations
    final deltaLat = lat1 - lat2;
    final deltaLon = lon1 - lon2;
    return (deltaLat * deltaLat + deltaLon * deltaLon) * 111; // Rough km conversion
  }

  Map<String, int> getReportStats() {
    return {
      'total': _reports.length,
      'pending': _reports.where((r) => r.status == ReportStatus.pending).length,
      'assigned': _reports.where((r) => r.status == ReportStatus.assigned).length,
      'inProgress': _reports.where((r) => r.status == ReportStatus.inProgress).length,
      'resolved': _reports.where((r) => r.status == ReportStatus.resolved).length,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}