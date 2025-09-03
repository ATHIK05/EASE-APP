import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/waste_provider.dart';
import '../../models/waste_report_model.dart';

class CollectorMapScreen extends StatefulWidget {
  const CollectorMapScreen({super.key});

  @override
  State<CollectorMapScreen> createState() => _CollectorMapScreenState();
}

class _CollectorMapScreenState extends State<CollectorMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  WasteReportModel? _selectedReport;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateMapMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateMapMarkers();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateMapMarkers() {
    final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
    final reports = wasteProvider.assignedReports;
    
    _markers = reports.map((report) {
      double markerColor;
      switch (report.status) {
        case ReportStatus.assigned:
          markerColor = BitmapDescriptor.hueBlue;
          break;
        case ReportStatus.inProgress:
          markerColor = BitmapDescriptor.hueOrange;
          break;
        case ReportStatus.resolved:
          markerColor = BitmapDescriptor.hueGreen;
          break;
        default:
          markerColor = BitmapDescriptor.hueRed;
      }

      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.latitude, report.longitude),
        infoWindow: InfoWindow(
          title: report.title,
          snippet: report.status.toString().split('.').last,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
        onTap: () => _selectReport(report),
      );
    }).toSet();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    }

    setState(() {});
  }

  void _selectReport(WasteReportModel report) {
    setState(() {
      _selectedReport = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 12,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (_) => setState(() => _selectedReport = null),
                ),
          
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.9),
                    const Color(0xFF3B82F6).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Reports Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _updateMapMarkers,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Selected Report Details
          if (_selectedReport != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedReport!.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _selectedReport = null),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _selectedReport!.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedReport!.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _getDirections(_selectedReport!),
                            icon: const Icon(Icons.directions, size: 16),
                            label: const Text('Directions'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectedReport!.status == ReportStatus.assigned
                                ? () => _startWork(_selectedReport!)
                                : _selectedReport!.status == ReportStatus.inProgress
                                    ? () => _completeWork(_selectedReport!)
                                    : null,
                            icon: Icon(
                              _selectedReport!.status == ReportStatus.assigned
                                  ? Icons.play_arrow
                                  : Icons.check,
                              size: 16,
                            ),
                            label: Text(
                              _selectedReport!.status == ReportStatus.assigned
                                  ? 'Start Work'
                                  : _selectedReport!.status == ReportStatus.inProgress
                                      ? 'Complete'
                                      : 'Completed',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedReport!.status == ReportStatus.resolved
                                  ? Colors.grey
                                  : const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _getDirections(WasteReportModel report) {
    // Implement navigation to report location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Getting directions to ${report.location}')),
    );
  }

  void _startWork(WasteReportModel report) async {
    final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
    final success = await wasteProvider.updateReportStatus(
      report.id,
      ReportStatus.inProgress,
    );
    
    if (success && mounted) {
      setState(() {
        _selectedReport = _selectedReport!.copyWith(status: ReportStatus.inProgress);
      });
      _updateMapMarkers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work started on this report'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _completeWork(WasteReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Work'),
        content: const Text('Mark this report as resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
              final success = await wasteProvider.updateReportStatus(
                report.id,
                ReportStatus.resolved,
                notes: 'Work completed successfully',
              );
              
              if (success && context.mounted) {
                setState(() {
                  _selectedReport = _selectedReport!.copyWith(status: ReportStatus.resolved);
                });
                _updateMapMarkers();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report marked as resolved'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}