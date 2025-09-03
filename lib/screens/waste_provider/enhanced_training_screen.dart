import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/training_model.dart';
import '../../models/user_model.dart';
import '../../widgets/training_widgets.dart';
import '../../widgets/translated_text.dart';

class EnhancedTrainingScreen extends StatefulWidget {
  const EnhancedTrainingScreen({super.key});

  @override
  State<EnhancedTrainingScreen> createState() => _EnhancedTrainingScreenState();
}

class _EnhancedTrainingScreenState extends State<EnhancedTrainingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _progressAnimationController;
  late List<Animation<double>> _progressAnimations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Interval(
          index * 0.3,
          (index * 0.3) + 0.7,
          curve: Curves.elasticOut,
        ),
      ));
    });
    
    _progressAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        trainingProvider.loadUserProgress(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
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
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              Padding(
                padding: const EdgeInsets.all(24),
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
                        const SizedBox(width: 8),
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
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                'Mandatory Training Hub',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TranslatedText(
                                'Master waste management skills',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<TrainingProvider>(
                          builder: (context, trainingProvider, child) {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final completionPercentage = trainingProvider.getCompletionPercentage(
                              authProvider.currentUser?.role ?? UserRole.wasteProvider
                            );
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: Colors.yellow,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(completionPercentage * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Training Progress Overview
                    Consumer2<TrainingProvider, AuthProvider>(
                      builder: (context, trainingProvider, authProvider, child) {
                        final userRole = authProvider.currentUser?.role ?? UserRole.wasteProvider;
                        final trainings = trainingProvider.getTrainingsForRole(userRole);
                        final completedCount = trainings.where((t) => 
                            trainingProvider.userProgress[t.id] == TrainingStatus.completed).length;
                        final mandatoryComplete = trainingProvider.isMandatoryTrainingComplete(userRole);
                        
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const TranslatedText(
                                'Training Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  AnimatedBuilder(
                                    animation: _progressAnimations[0],
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _progressAnimations[0].value,
                                        child: _buildProgressStat(
                                          'Completed',
                                          '$completedCount/${trainings.length}',
                                          Icons.check_circle,
                                          Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: _progressAnimations[1],
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _progressAnimations[1].value,
                                        child: _buildProgressStat(
                                          'Mandatory',
                                          mandatoryComplete ? 'Done' : 'Pending',
                                          Icons.priority_high,
                                          mandatoryComplete ? Colors.green : Colors.orange,
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: _progressAnimations[2],
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _progressAnimations[2].value,
                                        child: _buildProgressStat(
                                          'Points',
                                          '${authProvider.currentUser?.points ?? 0}',
                                          Icons.stars,
                                          Colors.yellow,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'Citizen'),
                          Tab(text: 'Worker'),
                          Tab(text: 'Champion'),
                        ],
                      ),
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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrainingTab(TrainingType.citizen),
                      _buildTrainingTab(TrainingType.wasteWorker),
                      _buildTrainingTab(TrainingType.greenChampion),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TranslatedText(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingTab(TrainingType type) {
    return Consumer2<TrainingProvider, AuthProvider>(
      builder: (context, trainingProvider, authProvider, child) {
        final trainings = trainingProvider.getTrainingsForRole(
          authProvider.currentUser?.role ?? UserRole.wasteProvider
        ).where((t) => t.type == type).toList();
        
        if (trainings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const TranslatedText(
                  'No training modules available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const TranslatedText(
                  'Training modules for this role will be available soon',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: trainings.length,
          itemBuilder: (context, index) {
            final training = trainings[index];
            final status = trainingProvider.userProgress[training.id] ?? TrainingStatus.notStarted;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: EnhancedTrainingCard(
                training: training,
                status: status,
                isMandatory: training.isMandatory,
                onStart: () => _startTraining(training),
              ),
            );
          },
        );
      },
    );
  }

  void _startTraining(TrainingModel training) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingModuleScreen(
          training: training,
          onComplete: (score) => _completeTraining(training, score),
        ),
      ),
    );
  }

  void _completeTraining(TrainingModel training, int score) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      final success = await trainingProvider.completeTraining(
        authProvider.currentUser!.id,
        training.id,
        score,
      );
      
      if (success && mounted) {
        // Award points
        await authProvider.updateUserPoints(training.pointsReward);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Training completed! +${training.pointsReward} points earned'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class TrainingModuleScreen extends StatefulWidget {
  final TrainingModel training;
  final Function(int) onComplete;

  const TrainingModuleScreen({
    super.key,
    required this.training,
    required this.onComplete,
  });

  @override
  State<TrainingModuleScreen> createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<TrainingModuleScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  int _totalSteps = 5;
  int _quizScore = 0;
  bool _interactiveCompleted = false;
  
  late AnimationController _stepAnimationController;
  late Animation<double> _stepAnimation;

  @override
  void initState() {
    super.initState();
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // Progress Header
              Padding(
                padding: const EdgeInsets.all(24),
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
                        Expanded(
                          child: TranslatedText(
                            widget.training.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.yellow,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.training.pointsReward}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress Indicator
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
                              TranslatedText(
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
                  child: AnimatedBuilder(
                    animation: _stepAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _stepAnimation.value) * 50),
                        child: Opacity(
                          opacity: _stepAnimation.value,
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
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _currentStep--;
                                            });
                                            _stepAnimationController.reset();
                                            _stepAnimationController.forward();
                                          },
                                          icon: const Icon(Icons.arrow_back),
                                          label: const TranslatedText('Previous'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            side: const BorderSide(color: Color(0xFF3B82F6)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    
                                    if (_currentStep > 0) const SizedBox(width: 16),
                                    
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _canProceed() ? () {
                                          if (_currentStep < _totalSteps - 1) {
                                            setState(() {
                                              _currentStep++;
                                            });
                                            _stepAnimationController.reset();
                                            _stepAnimationController.forward();
                                          } else {
                                            _completeTraining();
                                          }
                                        } : null,
                                        icon: Icon(
                                          _currentStep < _totalSteps - 1 
                                              ? Icons.arrow_forward 
                                              : Icons.check,
                                        ),
                                        label: TranslatedText(
                                          _currentStep < _totalSteps - 1 
                                              ? 'Next' 
                                              : 'Complete Training',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
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
      case 4:
        return _buildCertificationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'Training Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TranslatedText(
                        widget.training.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time, '${widget.training.duration} min'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.signal_cellular_alt, widget.training.difficulty),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.stars, '${widget.training.pointsReward} points'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const TranslatedText(
            'Learning Objectives',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...widget.training.modules.map((module) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TranslatedText(
                      module,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (widget.training.isMandatory) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TranslatedText(
                      'This is a mandatory training module. You must complete it to access all app features.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const TranslatedText(
            'Training Video',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.grey[300]!],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const TranslatedText(
                  'Training Video Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const TranslatedText(
                  'Video content would be embedded here',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Duration: ${widget.training.duration} minutes',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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
                  child: TranslatedText(
                    'Watch the complete video to proceed to the interactive exercises',
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
      ),
    );
  }

  Widget _buildInteractiveStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'Interactive Practice',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          const TranslatedText(
            'Practice what you\'ve learned with hands-on exercises:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Interactive Exercise based on training type
          if (widget.training.id.contains('segregation'))
            InteractiveSegregationWidget(
              onComplete: () {
                setState(() {
                  _interactiveCompleted = true;
                });
              },
            )
          else if (widget.training.id.contains('composting'))
            CompostingSimulatorWidget(
              onComplete: () {
                setState(() {
                  _interactiveCompleted = true;
                });
              },
            )
          else if (widget.training.id.contains('plastic'))
            PlasticReuseGalleryWidget(
              onComplete: () {
                setState(() {
                  _interactiveCompleted = true;
                });
              },
            )
          else
            // Default interactive content
            Container(
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
                    size: 64,
                    color: Colors.green[600],
                  ),
                  const SizedBox(height: 16),
                  TranslatedText(
                    'Interactive Exercise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TranslatedText(
                    'Complete the interactive exercise to proceed',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _interactiveCompleted = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const TranslatedText('Mark as Completed'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizStep() {
    final questions = widget.training.quizData['questions'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'Knowledge Assessment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          const TranslatedText(
            'Answer these questions to test your understanding:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (questions.isNotEmpty)
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                child: _buildQuizQuestion(question, index),
              );
            }).toList()
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 48,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  TranslatedText(
                    'Quiz questions will be available here',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizQuestion(Map<String, dynamic> question, int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${questionIndex + 1}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        TranslatedText(
          question['question'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...List.generate(question['options'].length, (optionIndex) {
          final option = question['options'][optionIndex];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                // Handle answer selection
                if (optionIndex == question['correct']) {
                  _quizScore += 10;
                }
              },
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
                    Expanded(
                      child: TranslatedText(option),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        
        if (question['explanation'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.yellow[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TranslatedText(
                    question['explanation'],
                    style: TextStyle(
                      color: Colors.yellow[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificationStep() {
    final finalScore = _quizScore + (_interactiveCompleted ? 20 : 0);
    final passed = finalScore >= 60;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          passed ? Icons.emoji_events : Icons.sentiment_satisfied,
          size: 80,
          color: passed ? Colors.yellow[600] : Colors.grey[600],
        ),
        const SizedBox(height: 24),
        
        TranslatedText(
          passed ? 'Congratulations!' : 'Good Effort!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Final Score: $finalScore/100',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        TranslatedText(
          passed 
              ? 'You have successfully completed the training!'
              : 'You can retake the training to improve your score.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        if (passed) ...[
          Container(
            padding: const EdgeInsets.all(20),
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
                  Icons.verified,
                  size: 48,
                  color: Colors.green[600],
                ),
                const SizedBox(height: 12),
                TranslatedText(
                  'Certificate Earned!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                TranslatedText(
                  'Your digital certificate will be available in your profile',
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Can always proceed from intro
      case 1:
        return true; // Video step - assume watched
      case 2:
        return _interactiveCompleted;
      case 3:
        return _quizScore > 0; // At least attempted quiz
      case 4:
        return true; // Certification step
      default:
        return false;
    }
  }

  void _completeTraining() {
    final finalScore = _quizScore + (_interactiveCompleted ? 20 : 0);
    widget.onComplete(finalScore);
  }
}