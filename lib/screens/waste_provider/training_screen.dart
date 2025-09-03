import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TrainingModule {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final int points;
  final bool isCompleted;
  final bool isUnlocked;
  final String videoUrl;
  final List<String> topics;

  TrainingModule({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.points,
    this.isCompleted = false,
    this.isUnlocked = true,
    required this.videoUrl,
    required this.topics,
  });
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  Set<String> _completedModules = {'intro'};
  
  late List<TrainingModule> _modules;

  @override
  void initState() {
    super.initState();
    _initializeModules();
  }

  void _initializeModules() {
    _modules = [
      TrainingModule(
        id: 'intro',
        title: 'Introduction to Waste Management',
        description: 'Learn the basics of waste types and environmental impact',
        duration: '15 min',
        difficulty: 'Beginner',
        points: 100,
        isCompleted: _completedModules.contains('intro'),
        isUnlocked: true,
        videoUrl: 'intro_video.mp4',
        topics: ['Types of Waste', 'Environmental Impact', 'Why It Matters'],
      ),
      TrainingModule(
        id: 'segregation',
        title: 'Source Segregation Techniques',
        description: 'Master the art of separating dry, wet, and hazardous waste',
        duration: '20 min',
        difficulty: 'Beginner',
        points: 150,
        isCompleted: _completedModules.contains('segregation'),
        isUnlocked: _completedModules.contains('intro'),
        videoUrl: 'segregation_video.mp4',
        topics: ['3-Bin System', 'Color Coding', 'Common Mistakes'],
      ),
      TrainingModule(
        id: 'composting',
        title: 'Home Composting Methods',
        description: 'Create nutrient-rich compost from organic waste',
        duration: '25 min',
        difficulty: 'Intermediate',
        points: 200,
        isCompleted: _completedModules.contains('composting'),
        isUnlocked: _completedModules.contains('segregation'),
        videoUrl: 'composting_video.mp4',
        topics: ['Composting Basics', 'DIY Compost Bin', 'Troubleshooting'],
      ),
      TrainingModule(
        id: 'recycling',
        title: 'Plastic Reuse and Recycling',
        description: 'Transform plastic waste into useful items',
        duration: '18 min',
        difficulty: 'Intermediate',
        points: 175,
        isCompleted: _completedModules.contains('recycling'),
        isUnlocked: _completedModules.contains('composting'),
        videoUrl: 'recycling_video.mp4',
        topics: ['Plastic Types', 'Creative Reuse', 'Recycling Centers'],
      ),
      TrainingModule(
        id: 'leadership',
        title: 'Community Leadership',
        description: 'Become a Green Champion and lead your community',
        duration: '30 min',
        difficulty: 'Advanced',
        points: 300,
        isCompleted: _completedModules.contains('leadership'),
        isUnlocked: _completedModules.contains('recycling'),
        videoUrl: 'leadership_video.mp4',
        topics: ['Leadership Skills', 'Community Engagement', 'Monitoring Systems'],
      ),
    ];
  }

  void _completeModule(String moduleId, int points) async {
    setState(() {
      _completedModules.add(moduleId);
      _initializeModules();
    });
    
    // Award points
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updateUserPoints(points);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Module completed! +$points points earned'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  double get _overallProgress {
    return _completedModules.length / _modules.length;
  }

  int get _totalPointsEarned {
    return _modules
        .where((module) => module.isCompleted)
        .fold(0, (sum, module) => sum + module.points);
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Waste Management Training',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Master the skills for a cleaner India',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_totalPointsEarned pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Progress Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(_overallProgress * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _overallProgress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Modules List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _modules.length,
                    itemBuilder: (context, index) {
                      final module = _modules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildModuleCard(module),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(TrainingModule module) {
    Color difficultyColor;
    switch (module.difficulty) {
      case 'Beginner':
        difficultyColor = Colors.green;
        break;
      case 'Intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'Advanced':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: module.isCompleted 
              ? Colors.green[200]! 
              : module.isUnlocked 
                  ? Colors.blue[200]! 
                  : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: module.isCompleted 
                        ? Colors.green.withOpacity(0.1)
                        : module.isUnlocked 
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    module.isCompleted 
                        ? Icons.check_circle
                        : module.isUnlocked 
                            ? Icons.play_circle
                            : Icons.lock,
                    color: module.isCompleted 
                        ? Colors.green
                        : module.isUnlocked 
                            ? Colors.blue
                            : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              module.difficulty,
                              style: TextStyle(
                                color: difficultyColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            module.duration,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.yellow[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${module.points}',
                          style: TextStyle(
                            color: Colors.yellow[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (module.isCompleted)
                      const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              module.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Topics
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: module.topics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: module.isUnlocked 
                    ? () => _startModule(module)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: module.isCompleted 
                      ? Colors.green
                      : module.isUnlocked 
                          ? const Color(0xFF3B82F6)
                          : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  module.isCompleted 
                      ? 'Completed'
                      : module.isUnlocked 
                          ? 'Start Module'
                          : 'Locked',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startModule(TrainingModule module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModuleDetailScreen(
          module: module,
          onComplete: () => _completeModuleHandler(module),
        ),
      ),
    );
  }

  void _completeModuleHandler(TrainingModule module) {
    setState(() {
      _completedModules.add(module.id);
      _initializeModules();
    });
    _completeModule(module.id, module.points);
  }
}

class ModuleDetailScreen extends StatefulWidget {
  final TrainingModule module;
  final VoidCallback onComplete;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.onComplete,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildStepContent(),
                      ),
                      
                      // Navigation Buttons
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                                child: const Text('Previous'),
                              ),
                            ),
                          
                          if (_currentStep > 0) const SizedBox(width: 16),
                          
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentStep < _totalSteps - 1) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  widget.onComplete();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                _currentStep < _totalSteps - 1 
                                    ? 'Next' 
                                    : 'Complete (+${widget.module.points} pts)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildVideoStep();
      case 2:
        return _buildInteractiveStep();
      case 3:
        return _buildQuizStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.module.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildInfoChip(Icons.access_time, widget.module.duration),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.signal_cellular_alt, widget.module.difficulty),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.stars, '${widget.module.points} points'),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'What You\'ll Learn',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...widget.module.topics.map((topic) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVideoStep() {
    return Column(
      children: [
        Text(
          'Training Video',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(height: 12),
              Text(
                'Training Video Placeholder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Interactive video content would be here',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.yellow[200]!),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Watch the complete video to proceed to the next step',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive Practice',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Practice what you\'ve learned with this interactive exercise:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Interactive Exercise Placeholder
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[100]!, Colors.green[50]!],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.touch_app,
                size: 48,
                color: Colors.green[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Drag & Drop Exercise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sort the waste items into correct bins',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Simulated sorting exercise
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBin('Dry', Colors.blue),
                  _buildBin('Wet', Colors.green),
                  _buildBin('Hazardous', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Knowledge Check',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Answer these questions to complete the module:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sample Quiz Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
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
              Text(
                'Question 1 of 3',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Which bin should you use for banana peels?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              ...['Blue (Dry)', 'Green (Wet)', 'Red (Hazardous)', 'Any bin'].map((option) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(option),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBin(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            Icons.delete,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}