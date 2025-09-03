import 'package:flutter/material.dart';
import 'dart:math';

class SortingGameWidget extends StatefulWidget {
  final Map<String, dynamic> gameConfig;
  final Function(int) onScoreUpdate;
  final Function(int) onGameComplete;

  const SortingGameWidget({
    super.key,
    required this.gameConfig,
    required this.onScoreUpdate,
    required this.onGameComplete,
  });

  @override
  State<SortingGameWidget> createState() => _SortingGameWidgetState();
}

class _SortingGameWidgetState extends State<SortingGameWidget> {
  List<Map<String, String>> _items = [];
  Map<String, List<Map<String, String>>> _bins = {};
  int _score = 0;
  int _timeLeft = 60;
  bool _gameStarted = false;
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _items = List<Map<String, String>>.from(widget.gameConfig['items']);
    _bins = {
      'Dry': <Map<String, String>>[],
      'Wet': <Map<String, String>>[],
      'Hazardous': <Map<String, String>>[],
    };
    _timeLeft = widget.gameConfig['timeLimit'] ?? 60;
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_gameStarted && !_gameEnded && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        _startTimer();
      } else if (_timeLeft <= 0) {
        _endGame();
      }
    });
  }

  void _endGame() {
    setState(() {
      _gameEnded = true;
    });
    widget.onGameComplete(_score);
  }

  void _sortItem(Map<String, String> item, String binType) {
    if (_gameEnded) return;
    
    setState(() {
      _items.remove(item);
      _bins[binType]!.add(item);
      
      // Check if correct
      if (item['type'] == binType) {
        _score += 10;
        widget.onScoreUpdate(_score);
      } else {
        _score = max(0, _score - 5);
        widget.onScoreUpdate(_score);
      }
      
      // Check if all items sorted
      if (_items.isEmpty) {
        _endGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    }
    
    if (_gameEnded) {
      return _buildEndScreen();
    }
    
    return _buildGameScreen();
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sort,
            size: 80,
            color: Color(0xFF10B981),
          ),
          const SizedBox(height: 24),
          const Text(
            'Waste Sorting Challenge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sort the waste items into the correct bins:\n• Blue for Dry waste\n• Green for Wet waste\n• Red for Hazardous waste',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timer and Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.red[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_timeLeft s',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                      'Score: $_score',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Bins
          Row(
            children: [
              Expanded(child: _buildBin('Dry', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildBin('Wet', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildBin('Hazardous', Colors.red)),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Items to Sort
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildDraggableItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndScreen() {
    final percentage = (_score / (_items.length * 10) * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _score >= 50 ? Icons.emoji_events : Icons.sentiment_satisfied,
            size: 80,
            color: _score >= 50 ? Colors.yellow[600] : Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            _score >= 50 ? 'Great Job!' : 'Good Try!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Final Score: $_score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accuracy: $percentage%',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBin(String binType, Color color) {
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete,
                color: color,
                size: 32,
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
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco,
                size: 24,
                color: Color(0xFF10B981),
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
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
      ),
      child: Container(
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
            const Icon(
              Icons.eco,
              size: 32,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 8),
            Text(
              item['name']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class QuizGameWidget extends StatefulWidget {
  final Map<String, dynamic> gameConfig;
  final Function(int) onScoreUpdate;
  final Function(int) onGameComplete;

  const QuizGameWidget({
    super.key,
    required this.gameConfig,
    required this.onScoreUpdate,
    required this.onGameComplete,
  });

  @override
  State<QuizGameWidget> createState() => _QuizGameWidgetState();
}

class _QuizGameWidgetState extends State<QuizGameWidget> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _questions = List<Map<String, dynamic>>.from(widget.gameConfig['questions']);
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
  }

  void _selectAnswer(int answerIndex) {
    if (_showResult) return;
    
    setState(() {
      _selectedAnswer = answerIndex;
      _showResult = true;
    });
    
    // Check if correct
    final question = _questions[_currentQuestionIndex];
    if (answerIndex == question['correct']) {
      _score += 10;
      widget.onScoreUpdate(_score);
    }
    
    // Move to next question after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _showResult = false;
        });
      } else {
        widget.onGameComplete(_score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    }
    
    return _buildQuizScreen();
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz,
            size: 80,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(height: 24),
          const Text(
            'Eco Knowledge Quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test your knowledge with ${_questions.length} questions about waste management and environmental protection.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Score: $_score',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          
          const SizedBox(height: 32),
          
          // Question
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: question['options'].length,
              itemBuilder: (context, index) {
                final option = question['options'][index];
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == question['correct'];
                
                Color backgroundColor;
                Color borderColor;
                Color textColor;
                
                if (_showResult) {
                  if (isCorrect) {
                    backgroundColor = Colors.green[100]!;
                    borderColor = Colors.green;
                    textColor = Colors.green[800]!;
                  } else if (isSelected) {
                    backgroundColor = Colors.red[100]!;
                    borderColor = Colors.red;
                    textColor = Colors.red[800]!;
                  } else {
                    backgroundColor = Colors.grey[100]!;
                    borderColor = Colors.grey[300]!;
                    textColor = Colors.grey[600]!;
                  }
                } else {
                  backgroundColor = Colors.white;
                  borderColor = Colors.grey[300]!;
                  textColor = Colors.grey[800]!;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: _showResult ? null : () => _selectAnswer(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _showResult && isCorrect 
                                  ? Colors.green 
                                  : _showResult && isSelected && !isCorrect
                                      ? Colors.red
                                      : Colors.transparent,
                              border: Border.all(
                                color: _showResult && isCorrect 
                                    ? Colors.green 
                                    : borderColor,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: _showResult && (isCorrect || (isSelected && !isCorrect))
                                ? Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Explanation
          if (_showResult && question['explanation'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question['explanation'],
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
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
}

class MemoryGameWidget extends StatefulWidget {
  final Map<String, dynamic> gameConfig;
  final Function(int) onScoreUpdate;
  final Function(int) onGameComplete;

  const MemoryGameWidget({
    super.key,
    required this.gameConfig,
    required this.onScoreUpdate,
    required this.onGameComplete,
  });

  @override
  State<MemoryGameWidget> createState() => _MemoryGameWidgetState();
}

class _MemoryGameWidgetState extends State<MemoryGameWidget> {
  List<String> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  List<int> _selectedCards = [];
  int _score = 0;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final pairs = List<Map<String, String>>.from(widget.gameConfig['pairs']);
    _cards = [];
    
    for (final pair in pairs) {
      _cards.add(pair['item']!);
      _cards.add(pair['benefit']!);
    }
    
    _cards.shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
  }

  void _flipCard(int index) {
    if (_flipped[index] || _matched[index] || _selectedCards.length >= 2) {
      return;
    }
    
    setState(() {
      _flipped[index] = true;
      _selectedCards.add(index);
    });
    
    if (_selectedCards.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final card1Index = _selectedCards[0];
    final card2Index = _selectedCards[1];
    final card1 = _cards[card1Index];
    final card2 = _cards[card2Index];
    
    // Check if cards form a pair
    final pairs = List<Map<String, String>>.from(widget.gameConfig['pairs']);
    bool isMatch = false;
    
    for (final pair in pairs) {
      if ((card1 == pair['item'] && card2 == pair['benefit']) ||
          (card1 == pair['benefit'] && card2 == pair['item'])) {
        isMatch = true;
        break;
      }
    }
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        if (isMatch) {
          _matched[card1Index] = true;
          _matched[card2Index] = true;
          _score += 20;
          widget.onScoreUpdate(_score);
        } else {
          _flipped[card1Index] = false;
          _flipped[card2Index] = false;
        }
        _selectedCards.clear();
      });
      
      // Check if game completed
      if (_matched.every((matched) => matched)) {
        widget.onGameComplete(_score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    }
    
    return _buildGameScreen();
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.memory,
            size: 80,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 24),
          const Text(
            'Green Memory Match',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Match eco-friendly items with their benefits. Flip cards to find matching pairs!',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.purple[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Score: $_score',
                  style: TextStyle(
                    color: Colors.purple[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Cards Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];
    
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isMatched 
              ? Colors.green[100]
              : isFlipped 
                  ? Colors.white
                  : Colors.purple[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched 
                ? Colors.green
                : isFlipped 
                    ? Colors.purple
                    : Colors.purple[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _cards[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMatched ? Colors.green[800] : Colors.purple[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Icon(
                  Icons.eco,
                  color: Colors.purple[400],
                  size: 24,
                ),
        ),
      ),
    );
  }
}

class ActionGameWidget extends StatefulWidget {
  final Map<String, dynamic> gameConfig;
  final Function(int) onScoreUpdate;
  final Function(int) onGameComplete;

  const ActionGameWidget({
    super.key,
    required this.gameConfig,
    required this.onScoreUpdate,
    required this.onGameComplete,
  });

  @override
  State<ActionGameWidget> createState() => _ActionGameWidgetState();
}

class _ActionGameWidgetState extends State<ActionGameWidget>
    with TickerProviderStateMixin {
  late AnimationController _runnerController;
  late Animation<double> _runnerAnimation;
  
  int _score = 0;
  int _level = 1;
  bool _gameStarted = false;
  bool _gameEnded = false;
  List<Offset> _wasteItems = [];
  List<Offset> _obstacles = [];

  @override
  void initState() {
    super.initState();
    _runnerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _runnerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_runnerController);
    
    _generateLevel();
  }

  @override
  void dispose() {
    _runnerController.dispose();
    super.dispose();
  }

  void _generateLevel() {
    final random = Random();
    _wasteItems = List.generate(10, (index) {
      return Offset(
        random.nextDouble() * 300,
        random.nextDouble() * 400 + 100,
      );
    });
    
    _obstacles = List.generate(5, (index) {
      return Offset(
        random.nextDouble() * 300,
        random.nextDouble() * 400 + 100,
      );
    });
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    _runnerController.repeat();
  }

  void _collectWaste(int index) {
    setState(() {
      _wasteItems.removeAt(index);
      _score += 10;
      widget.onScoreUpdate(_score);
    });
    
    if (_wasteItems.isEmpty) {
      _nextLevel();
    }
  }

  void _nextLevel() {
    if (_level < 3) {
      setState(() {
        _level++;
      });
      _generateLevel();
    } else {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _gameEnded = true;
    });
    _runnerController.stop();
    widget.onGameComplete(_score);
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return _buildStartScreen();
    }
    
    if (_gameEnded) {
      return _buildEndScreen();
    }
    
    return _buildGameScreen();
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_run,
            size: 80,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(height: 24),
          const Text(
            'Clean City Runner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Run through the city and collect waste while avoiding obstacles. Clean up as much as you can!',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Running',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Level $_level',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: $_score',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Game Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.green[100]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                children: [
                  // Runner
                  AnimatedBuilder(
                    animation: _runnerAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 20,
                        bottom: 50 + (_runnerAnimation.value * 20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Waste Items
                  ..._wasteItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final position = entry.value;
                    
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: GestureDetector(
                        onTap: () => _collectWaste(index),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.orange[400],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Obstacles
                  ..._obstacles.map((position) {
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap orange circles to collect waste. Avoid red obstacles!',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
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

  Widget _buildEndScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.yellow[600],
          ),
          const SizedBox(height: 24),
          const Text(
            'City Cleaned!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Final Score: $_score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Levels Completed: $_level',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}