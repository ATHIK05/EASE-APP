import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/waste_provider.dart';
import '../../models/facility_model.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  FacilityType? _selectedType;
  String _searchQuery = '';
  bool _showMap = false;

  final Map<FacilityType, Map<String, dynamic>> _facilityTypeData = {
    FacilityType.recycling: {
      'label': 'Recycling Centers',
      'icon': Icons.recycling,
      'color': Colors.green,
    },
    FacilityType.wte: {
      'label': 'Waste-to-Energy',
      'icon': Icons.flash_on,
      'color': Colors.yellow[700],
    },
    FacilityType.compost: {
      'label': 'Composting Units',
      'icon': Icons.eco,
      'color': Colors.green[700],
    },
    FacilityType.biogas: {
      'label': 'Biogas Plants',
      'icon': Icons.local_gas_station,
      'color': Colors.blue,
    },
    FacilityType.scrapShop: {
      'label': 'Scrap Shops',
      'icon': Icons.store,
      'color': Colors.orange,
    },
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WasteProvider>(context, listen: false).loadFacilities();
    });
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
    final facilities = wasteProvider.facilities;
    
    _markers = facilities.map((facility) {
      return Marker(
        markerId: MarkerId(facility.id),
        position: LatLng(facility.latitude, facility.longitude),
        infoWindow: InfoWindow(
          title: facility.name,
          snippet: facility.type.toString().split('.').last,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(facility.type),
        ),
      );
    }).toSet();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {});
  }

  double _getMarkerColor(FacilityType type) {
    switch (type) {
      case FacilityType.recycling:
        return BitmapDescriptor.hueGreen;
      case FacilityType.wte:
        return BitmapDescriptor.hueYellow;
      case FacilityType.compost:
        return BitmapDescriptor.hueOrange;
      case FacilityType.biogas:
        return BitmapDescriptor.hueBlue;
      case FacilityType.scrapShop:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                'Waste Management Facilities',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TranslatedText(
                                'Find nearby treatment centers',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        LanguageSelector(
                          iconColor: Colors.white,
                          backgroundColor: theme.cardColor,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() => _showMap = !_showMap),
                          icon: Icon(
                            _showMap ? Icons.list : Icons.map,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: languageProvider.translate('Search facilities...'),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.iconTheme.color,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filter Chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(languageProvider.translate('All'), null),
                    ..._facilityTypeData.entries.map((entry) {
                      return _buildFilterChip(
                        languageProvider.translate(entry.value['label']),
                        entry.key,
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _showMap ? _buildMapView() : _buildListView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, FacilityType? type) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
        },
        backgroundColor: theme.cardColor.withOpacity(0.7),
        selectedColor: Colors.white.withOpacity(0.3),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GoogleMap(
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
    );
  }

  Widget _buildListView() {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Consumer<WasteProvider>(
      builder: (context, wasteProvider, child) {
        var facilities = wasteProvider.facilities;
        
        // Apply filters
        if (_selectedType != null) {
          facilities = facilities.where((f) => f.type == _selectedType).toList();
        }
        
        if (_searchQuery.isNotEmpty) {
          facilities = facilities.where((f) =>
              f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              f.address.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }

        if (facilities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TranslatedText(
                  'No facilities found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TranslatedText(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildFacilityCard(facility),
            );
          },
        );
      },
    );
  }
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No facilities found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildFacilityCard(facility),
            );
          },
        );
      },
    );
  }

  Widget _buildFacilityCard(FacilityModel facility) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final typeData = _facilityTypeData[facility.type]!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeData['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeData['icon'],
                  color: typeData['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      languageProvider.translate(typeData['label']),
                      style: TextStyle(
                        color: typeData['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: facility.status == FacilityStatus.operational
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  facility.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: facility.status == FacilityStatus.operational
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  facility.address,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: theme.iconTheme.color,
              ),
              const SizedBox(width: 8),
              Text(
                '${languageProvider.translate('Capacity')}: ${facility.capacity}',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.yellow[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    facility.rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callFacility(facility.contact),
                  icon: const Icon(Icons.phone, size: 16),
                  label: TranslatedText(
                    'Call',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirections(facility),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const TranslatedText(
                    'Directions',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  void _callFacility(String phoneNumber) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    // Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${languageProvider.translate('Calling')} $phoneNumber...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _getDirections(FacilityModel facility) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    // Implement navigation to facility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${languageProvider.translate('Getting directions to')} ${facility.name}...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}