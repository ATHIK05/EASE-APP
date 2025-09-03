import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/training_provider.dart';
import '../../models/user_model.dart';
import '../../models/training_model.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/training_widgets.dart';

class EnhancedTrainingScreen extends StatefulWidget {
  const EnhancedTrainingScreen({super.key});

  @override
  State<EnhancedTrainingScreen> createState() => _EnhancedTrainingScreenState();
}

class _EnhancedTrainingScreenState extends State<EnhancedTrainingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6),
              const Color(0xFF1D4ED8),
              if (isDark) const Color(0xFF1E293B) else const Color(0xFF1E40AF),
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
                  child: Container(
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
                                    'Waste Management Training',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TranslatedText(
                                    'Master the skills for a cleaner India',
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
                        
                        const SizedBox(height: 20),
                        
                        // Progress Overview
                        Consumer2<TrainingProvider, AuthProvider>(
                          builder: (context, trainingProvider, authProvider, child) {
                            final user = authProvider.currentUser;
                            final completionPercentage = trainingProvider.getCompletionPercentage(
                              user?.role ?? UserRole.wasteProvider
                            );
                            final totalPointsEarned = _calculateTotalPoints(trainingProvider, user?.role);
                            
                            return Container(
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
                              child: Column(
                                children: [
                                  const TranslatedText(
                                    'Your Progress',
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
                                      _buildProgressStat(
                                        'Completion',
                                        '${(completionPercentage * 100).round()}%',
                                        Icons.school,
                                        Colors.yellow,
                                      ),
                                      _buildProgressStat(
                                        'Points Earned',
                                        '$totalPointsEarned',
                                        Icons.stars,
                                        Colors.orange,
                                      ),
                                      _buildProgressStat(
                                        'Certificates',
                                        '${_getCertificateCount(trainingProvider)}',
                                        Icons.verified,
                                        Colors.green,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: completionPercentage,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                                    minHeight: 8,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Training Modules
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
                  child: Consumer2<TrainingProvider, AuthProvider>(
                    builder: (context, trainingProvider, authProvider, child) {
                      final user = authProvider.currentUser;
                      final trainings = trainingProvider.getTrainingsForRole(
                        user?.role ?? UserRole.wasteProvider
                      );
                      
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: trainings.length,
                        itemBuilder: (context, index) {
                          final training = trainings[index];
                          final status = trainingProvider.userProgress[training.id] ?? TrainingStatus.notStarted;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: EnhancedTrainingCard(
                              training: training,
                              status: status,
                              isMandatory: training.isMandatory,
                              onStart: () => _startTraining(context, training, trainingProvider, authProvider),
                            ),
                          );
                        },
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TranslatedText(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _calculateTotalPoints(TrainingProvider trainingProvider, UserRole? role) {
    final trainings = trainingProvider.getTrainingsForRole(role ?? UserRole.wasteProvider);
    return trainings
        .where((t) => trainingProvider.userProgress[t.id] == TrainingStatus.completed)
        .fold(0, (sum, training) => sum + training.pointsReward);
  }

  int _getCertificateCount(TrainingProvider trainingProvider) {
    return trainingProvider.userProgress.values
        .where((status) => status == TrainingStatus.completed)
        .length;
  }

  void _startTraining(
    BuildContext context,
    TrainingModel training,
    TrainingProvider trainingProvider,
    AuthProvider authProvider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingModuleScreen(
          training: training,
          onComplete: (score) async {
            final success = await trainingProvider.completeTraining(
              authProvider.currentUser!.id,
              training.id,
              score,
            );
            
            if (success) {
              await authProvider.updateUserPoints(training.pointsReward);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Training completed! +${training.pointsReward} points earned'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class TrainingModuleScreen extends StatefulWidget {
  final TrainingModel training;
  final Function(int score) onComplete;

  const TrainingModuleScreen({
    super.key,
    required this.training,
    required this.onComplete,
  });

  @override
  State<TrainingModuleScreen> createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<TrainingModuleScreen> {
  int _currentStep = 0;
  int _score = 0;
  final int _totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText(
          widget.training.title,
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          LanguageSelector(
            iconColor: theme.appBarTheme.foregroundColor,
            backgroundColor: theme.cardColor,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3B82F6),
              const Color(0xFF1D4ED8),
              if (theme.brightness == Brightness.dark) const Color(0xFF1E293B) else const Color(0xFF1E40AF),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildStepContent(),
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: theme.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: TranslatedText(
                                  'Previous',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
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
                                  widget.onComplete(_score);
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: TranslatedText(
                                _currentStep < _totalSteps - 1 
                                    ? 'Next' 
                                    : 'Complete (+${widget.training.pointsReward} points)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    final theme = Theme.of(context);
    
    switch (_currentStep) {
      case 0:
        return _buildIntroStep(theme);
      case 1:
        return _buildVideoStep(theme);
      case 2:
        return _buildInteractiveStep(theme);
      case 3:
        return _buildQuizStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'Module Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  widget.training.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.access_time, '${widget.training.duration} min', Colors.orange, theme),
                    _buildInfoChip(Icons.signal_cellular_alt, widget.training.difficulty, Colors.purple, theme),
                    _buildInfoChip(Icons.stars, '${widget.training.pointsReward} points', Colors.yellow[700]!, theme),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          TranslatedText(
            'What You\'ll Learn',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          ...widget.training.modules.map((module) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TranslatedText(
                      module,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVideoStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TranslatedText(
            'Training Video',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 12),
                TranslatedText(
                  'Interactive Training Video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                TranslatedText(
                  'Watch and learn waste management techniques',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TranslatedText(
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
      ),
    );
  }

  Widget _buildInteractiveStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'Interactive Practice',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          TranslatedText(
            'Practice what you\'ve learned with this interactive exercise:',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          InteractiveSegregationWidget(
            onComplete: () {
              setState(() {
                _score += 20;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStep(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'Knowledge Check',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          TranslatedText(
            'Answer these questions to complete the module:',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sample Quiz Question
          Container(
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
                Text(
                  'Question 1 of 3',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                const TranslatedText(
                  'Which bin should you use for banana peels?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ...['Blue (Dry)', 'Green (Wet)', 'Red (Hazardous)', 'Any bin'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isCorrect = index == 1; // Green (Wet) is correct
                  
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isCorrect) _score += 10;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                          color: theme.cardColor,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                shape: BoxShape.circle,
                                color: theme.cardColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            TranslatedText(
                              option,
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color, ThemeData theme) {
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