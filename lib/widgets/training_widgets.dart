import 'package:flutter/material.dart';
import 'dart:math';
import '../models/training_model.dart';

class EnhancedTrainingCard extends StatelessWidget {
  final TrainingModel training;
  final TrainingStatus status;
  final VoidCallback onStart;
  final bool isMandatory;

  const EnhancedTrainingCard({
    super.key,
    required this.training,
    required this.status,
    required this.onStart,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case TrainingStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'COMPLETED';
        break;
      case TrainingStatus.inProgress:
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle;
        statusText = 'IN PROGRESS';
        break;
      case TrainingStatus.certified:
        statusColor = Colors.purple;
        statusIcon = Icons.verified;
        statusText = 'CERTIFIED';
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.play_arrow;
        statusText = 'START';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMandatory ? Colors.red[200]! : Colors.blue[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.8), statusColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              training.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (isMandatory)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'MANDATORY',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        training.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Training Details
            Row(
              children: [
                _buildDetailChip(
                  Icons.access_time,
                  '${training.duration} min',
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildDetailChip(
                  Icons.signal_cellular_alt,
                  training.difficulty,
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildDetailChip(
                  Icons.stars,
                  '${training.pointsReward} pts',
                  Colors.yellow[700]!,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Modules Preview
            Text(
              'Training Modules',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: training.modules.take(3).map((module) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    module,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (training.modules.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${training.modules.length - 3} more modules',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: status == TrainingStatus.completed ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: status == TrainingStatus.completed ? 0 : 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      statusIcon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class InteractiveSegregationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const InteractiveSegregationWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<InteractiveSegregationWidget> createState() => _InteractiveSegregationWidgetState();
}

class _InteractiveSegregationWidgetState extends State<InteractiveSegregationWidget> {
  final List<Map<String, String>> _wasteItems = [
    {'name': 'Banana Peel', 'type': 'Wet', 'emoji': '🍌'},
    {'name': 'Plastic Bottle', 'type': 'Dry', 'emoji': '🍼'},
    {'name': 'Battery', 'type': 'Hazardous', 'emoji': '🔋'},
    {'name': 'Newspaper', 'type': 'Dry', 'emoji': '📰'},
    {'name': 'Medicine', 'type': 'Hazardous', 'emoji': '💊'},
    {'name': 'Food Scraps', 'type': 'Wet', 'emoji': '🥬'},
  ];

  Map<String, List<Map<String, String>>> _bins = {
    'Dry': [],
    'Wet': [],
    'Hazardous': [],
  };

  int _score = 0;
  int _attempts = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive Waste Segregation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Drag waste items to the correct bins',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Score Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Score: $_score/${_wasteItems.length * 10}',
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Bins
        Row(
          children: [
            Expanded(child: _buildBin('Dry', Colors.blue, '🗂️')),
            const SizedBox(width: 8),
            Expanded(child: _buildBin('Wet', Colors.green, '🌱')),
            const SizedBox(width: 8),
            Expanded(child: _buildBin('Hazardous', Colors.red, '⚠️')),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Waste Items
        if (_wasteItems.isNotEmpty) ...[
          Text(
            'Drag items to bins:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _wasteItems.map((item) {
              return _buildDraggableItem(item);
            }).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.green[600],
                ),
                const SizedBox(height: 12),
                Text(
                  'Excellent Work!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'ve successfully segregated all waste items',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBin(String binType, Color color, String emoji) {
    return DragTarget<Map<String, String>>(
      onAccept: (item) => _sortItem(item, binType),
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color,
              width: candidateData.isNotEmpty ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                binType,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${_bins[binType]!.length} items',
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(Map<String, String> item) {
    return Draggable<Map<String, String>>(
      data: item,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['emoji']!,
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                item['name']!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
      ),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['emoji']!,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              item['name']!,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _sortItem(Map<String, String> item, String binType) {
    setState(() {
      _wasteItems.remove(item);
      _bins[binType]!.add(item);
      _attempts++;
      
      // Check if correct
      if (item['type'] == binType) {
        _score += 10;
      }
      
      // Check if all items sorted
      if (_wasteItems.isEmpty) {
        widget.onComplete();
      }
    });
  }
}

class CompostingSimulatorWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const CompostingSimulatorWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<CompostingSimulatorWidget> createState() => _CompostingSimulatorWidgetState();
}

class _CompostingSimulatorWidgetState extends State<CompostingSimulatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  int _currentStep = 0;
  final List<String> _steps = [
    'Add brown materials (dry leaves, paper)',
    'Add green materials (kitchen scraps)',
    'Mix thoroughly',
    'Add water for moisture',
    'Wait for decomposition',
  ];

  final List<String> _stepEmojis = ['🍂', '🥬', '🔄', '💧', '⏰'];
  final List<Color> _stepColors = [
    Colors.brown,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Composting Simulator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Follow the steps to create perfect compost',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Compost Bin Visualization
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.brown[200]!,
                  Colors.brown[400]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown[600]!, width: 3),
            ),
            child: Stack(
              children: [
                // Compost layers
                for (int i = 0; i <= _currentStep && i < 4; i++)
                  Positioned(
                    bottom: i * 30.0,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                        color: _stepColors[i].withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                
                // Mixing animation
                if (_currentStep == 2)
                  Center(
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * pi,
                          child: Icon(
                            Icons.refresh,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                
                // Water drops
                if (_currentStep == 3)
                  ...List.generate(5, (index) {
                    return Positioned(
                      top: 20 + (index * 15.0),
                      left: 80 + (index * 10.0),
                      child: const Text('💧', style: TextStyle(fontSize: 16)),
                    );
                  }),
                
                // Time indicator
                if (_currentStep == 4)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⏰', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text(
                          'Decomposing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Steps
        Column(
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green
                          : isCurrent 
                              ? _stepColors[index]
                              : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              _stepEmojis[index],
                              style: const TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted 
                            ? Colors.green[700]
                            : isCurrent 
                                ? Colors.black87
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (isCurrent)
                    ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _stepColors[index],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Do It',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep == 2) {
      _rotationController.repeat();
    }
    
    setState(() {
      _currentStep++;
    });
    
    if (_currentStep >= _steps.length) {
      widget.onComplete();
    }
    
    if (_currentStep != 2) {
      _rotationController.stop();
    }
  }
}

class PlasticReuseGalleryWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const PlasticReuseGalleryWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<PlasticReuseGalleryWidget> createState() => _PlasticReuseGalleryWidgetState();
}

class _PlasticReuseGalleryWidgetState extends State<PlasticReuseGalleryWidget> {
  final List<Map<String, String>> _reuseIdeas = [
    {
      'title': 'Bottle Planter',
      'description': 'Cut plastic bottles to create hanging planters',
      'difficulty': 'Easy',
      'emoji': '🪴',
    },
    {
      'title': 'Storage Containers',
      'description': 'Convert large containers for organizing items',
      'difficulty': 'Easy',
      'emoji': '📦',
    },
    {
      'title': 'Bird Feeder',
      'description': 'Transform bottles into eco-friendly bird feeders',
      'difficulty': 'Medium',
      'emoji': '🐦',
    },
    {
      'title': 'Watering System',
      'description': 'Create drip irrigation using plastic bottles',
      'difficulty': 'Medium',
      'emoji': '💧',
    },
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creative Plastic Reuse Ideas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore innovative ways to give plastic a second life',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Gallery
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _reuseIdeas.length,
            itemBuilder: (context, index) {
              final idea = _reuseIdeas[index];
              final isSelected = index == _selectedIndex;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        idea['emoji']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        idea['title']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue[800] : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Selected Idea Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _reuseIdeas[_selectedIndex]['emoji']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reuseIdeas[_selectedIndex]['title']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _reuseIdeas[_selectedIndex]['difficulty']!,
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _reuseIdeas[_selectedIndex]['description']!,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mark as learned
                    widget.onComplete();
                  },
                  icon: const Icon(Icons.lightbulb, size: 16),
                  label: const Text('I\'ve Learned This'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}