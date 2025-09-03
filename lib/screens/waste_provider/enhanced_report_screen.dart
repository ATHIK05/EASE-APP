import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/waste_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/waste_report_model.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/language_selector.dart';

class EnhancedReportScreen extends StatefulWidget {
  const EnhancedReportScreen({super.key});

  @override
  State<EnhancedReportScreen> createState() => _EnhancedReportScreenState();
}

class _EnhancedReportScreenState extends State<EnhancedReportScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _driveLinksController = TextEditingController();
  
  WasteType _selectedWasteType = WasteType.mixed;
  Priority _selectedPriority = Priority.medium;
  Position? _currentPosition;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<WasteType, Map<String, dynamic>> _wasteTypeData = {
    WasteType.mixed: {
      'label': 'Mixed Waste',
      'icon': Icons.delete,
      'color': Colors.red,
      'description': 'Unsegregated waste mixture'
    },
    WasteType.plastic: {
      'label': 'Plastic Waste',
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'description': 'Bottles, bags, containers'
    },
    WasteType.organic: {
      'label': 'Organic Waste',
      'icon': Icons.eco,
      'color': Colors.green,
      'description': 'Food scraps, garden waste'
    },
    WasteType.electronic: {
      'label': 'E-Waste',
      'icon': Icons.computer,
      'color': Colors.purple,
      'description': 'Electronics, batteries'
    },
    WasteType.construction: {
      'label': 'Construction Debris',
      'icon': Icons.construction,
      'color': Colors.orange,
      'description': 'Building materials, rubble'
    },
    WasteType.hazardous: {
      'label': 'Hazardous Waste',
      'icon': Icons.warning,
      'color': Colors.red[800]!,
      'description': 'Chemicals, medical waste'
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _driveLinksController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        _locationController.text = address;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
        
        // Parse drive links
        List<String> imageUrls = [];
        if (_driveLinksController.text.isNotEmpty) {
          imageUrls = _driveLinksController.text
              .split('\n')
              .map((link) => link.trim())
              .where((link) => link.isNotEmpty)
              .toList();
        }

        // Create report
        final report = WasteReportModel(
          id: '',
          reporterId: authProvider.currentUser!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          wasteType: _selectedWasteType,
          priority: _selectedPriority,
          location: _locationController.text.trim(),
          latitude: _currentPosition?.latitude ?? 0.0,
          longitude: _currentPosition?.longitude ?? 0.0,
          imageUrls: imageUrls,
          createdAt: DateTime.now(),
        );

        final success = await wasteProvider.submitReport(report);
        
        if (success && mounted) {
          // Award points for reporting
          await authProvider.updateUserPoints(50);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully! +50 points earned'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF59E0B),
              Color(0xFFEA580C),
              Color(0xFFDC2626),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
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
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TranslatedText(
                                    'Report Waste Issue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TranslatedText(
                                    'Help keep India clean',
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
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Impact Stats
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ImpactStat(
                                icon: Icons.report,
                                value: '1.7L',
                                label: 'Tonnes/Day',
                                color: Colors.orange,
                              ),
                              _ImpactStat(
                                icon: Icons.recycling,
                                value: '54%',
                                label: 'Treated',
                                color: Colors.green,
                              ),
                              _ImpactStat(
                                icon: Icons.warning,
                                value: '46%',
                                label: 'Unaccounted',
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Form Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Drive Links Section
                            TranslatedText(
                              'Photo/Video Evidence',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineSmall?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TranslatedText(
                              'Share Google Drive links to photos/videos (one per line)',
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.blue[900]?.withOpacity(0.2)
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.blue[400]!
                                      : Colors.blue[200]!,
                                ),
                              ),
                              child: TextFormField(
                                controller: _driveLinksController,
                                maxLines: 4,
                                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  hintText: 'https://drive.google.com/file/d/...\nhttps://drive.google.com/file/d/...',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Icon(
                                      Icons.link,
                                      color: theme.iconTheme.color,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                  hintStyle: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Provider.of<LanguageProvider>(context, listen: false).translate('Please provide at least one photo/video link');
                                  }
                                  return null;
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Report Title
                            TextFormField(
                              controller: _titleController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: Provider.of<LanguageProvider>(context).translate('Report Title'),
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: theme.iconTheme.color,
                                ),
                                hintText: 'e.g., Illegal dumping near park',
                                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return Provider.of<LanguageProvider>(context, listen: false).translate('Please enter a title');
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Location with GPS
                            TextFormField(
                              controller: _locationController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: Provider.of<LanguageProvider>(context).translate('Location'),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: theme.iconTheme.color,
                                ),
                                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                suffixIcon: IconButton(
                                  icon: _isGettingLocation
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          Icons.my_location,
                                          color: theme.iconTheme.color,
                                        ),
                                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                                ),
                                hintText: 'Tap GPS icon to get current location',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return Provider.of<LanguageProvider>(context, listen: false).translate('Please enter location');
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Waste Type Selection
                            TranslatedText(
                              'Waste Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                              children: _wasteTypeData.entries.map((entry) {
                                final wasteType = entry.key;
                                final data = entry.value;
                                final isSelected = _selectedWasteType == wasteType;
                                
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedWasteType = wasteType),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: isSelected 
                                          ? LinearGradient(
                                              colors: [
                                                data['color'].withOpacity(0.8),
                                                data['color'],
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : theme.cardColor,
                                      border: Border.all(
                                        color: isSelected 
                                            ? data['color']
                                            : theme.dividerColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: data['color'].withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ] : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          data['icon'],
                                          size: 20,
                                          color: isSelected 
                                              ? Colors.white
                                              : data['color'],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            Provider.of<LanguageProvider>(context).translate(data['label']),
                                            style: TextStyle(
                                              color: isSelected 
                                                  ? Colors.white
                                                  : theme.textTheme.bodyMedium?.color,
                                              fontWeight: isSelected 
                                                  ? FontWeight.bold 
                                                  : FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Priority Selection
                            TranslatedText(
                              'Priority Level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: Priority.values.map((priority) {
                                final isSelected = _selectedPriority == priority;
                                Color color;
                                IconData icon;
                                
                                switch (priority) {
                                  case Priority.low:
                                    color = Colors.green;
                                    icon = Icons.trending_down;
                                    break;
                                  case Priority.medium:
                                    color = Colors.orange;
                                    icon = Icons.trending_flat;
                                    break;
                                  case Priority.high:
                                    color = Colors.red;
                                    icon = Icons.trending_up;
                                    break;
                                  case Priority.urgent:
                                    color = Colors.red[800]!;
                                    icon = Icons.priority_high;
                                    break;
                                }
                                
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPriority = priority),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: isSelected 
                                            ? LinearGradient(
                                                colors: [
                                                  color.withOpacity(0.8),
                                                  color,
                                                ],
                                              )
                                            : null,
                                        color: isSelected ? null : theme.cardColor,
                                        border: Border.all(
                                          color: isSelected ? color : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ] : null,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            icon,
                                            color: isSelected ? Colors.white : color,
                                            size: 20,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            Provider.of<LanguageProvider>(context).translate(priority.toString().split('.').last),
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                              fontWeight: isSelected 
                                                  ? FontWeight.bold 
                                                  : FontWeight.w500,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: Provider.of<LanguageProvider>(context).translate('Detailed Description'),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(bottom: 60),
                                  child: Icon(
                                    Icons.description,
                                    color: theme.iconTheme.color,
                                  ),
                                ),
                                alignLabelWithHint: true,
                                hintText: 'Describe the waste issue in detail...',
                                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return Provider.of<LanguageProvider>(context, listen: false).translate('Please provide a description');
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Submit Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitReport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: _isSubmitting ? 0 : 8,
                                  shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                                ),
                                child: _isSubmitting
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          TranslatedText(
                                            'Submitting Report...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, size: 20),
                                          SizedBox(width: 8),
                                          TranslatedText(
                                            'Submit Report (+50 Points)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Help Text
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.blue[900]?.withOpacity(0.2)
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.blue[400]!
                                      : Colors.blue[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: theme.brightness == Brightness.dark 
                                        ? Colors.blue[300]
                                        : Colors.blue[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TranslatedText(
                                      'Your report helps keep India clean. Include clear photos and accurate location for faster resolution.',
                                      style: TextStyle(
                                        color: theme.brightness == Brightness.dark 
                                            ? Colors.blue[300]
                                            : Colors.blue[600],
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ImpactStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}