import 'package:flutter/material.dart';
import 'dart:math';

enum GameType { sortingGame, quizGame, memoryGame, actionGame }

class GameData {
  final String id;
  final String title;
  final String description;
  final GameType type;
  final int pointsReward;
  final int difficulty;
  final String imageUrl;
  final Map<String, dynamic> gameConfig;

  GameData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.difficulty,
    required this.imageUrl,
    required this.gameConfig,
  });
}

class GameProvider extends ChangeNotifier {
  List<GameData> _dailyGames = [];
  Map<String, int> _gameScores = {};
  Map<String, DateTime> _lastPlayed = {};
  int _totalGamePoints = 0;
  
  List<GameData> get dailyGames => _dailyGames;
  Map<String, int> get gameScores => _gameScores;
  int get totalGamePoints => _totalGamePoints;

  GameProvider() {
    _generateDailyGames();
  }

  void _generateDailyGames() {
    final random = Random();
    final today = DateTime.now();
    final seed = today.year * 1000 + today.month * 100 + today.day;
    final gameRandom = Random(seed);

    _dailyGames = [
      GameData(
        id: 'sorting_${today.day}',
        title: 'Waste Sorting Challenge',
        description: 'Sort different types of waste into correct bins',
        type: GameType.sortingGame,
        pointsReward: 50 + gameRandom.nextInt(50),
        difficulty: 1 + gameRandom.nextInt(3),
        imageUrl: 'assets/games/sorting_game.png',
        gameConfig: {
          'items': _generateSortingItems(),
          'timeLimit': 60,
          'bins': ['Dry', 'Wet', 'Hazardous'],
        },
      ),
      GameData(
        id: 'quiz_${today.day}',
        title: 'Eco Knowledge Quiz',
        description: 'Test your knowledge about waste management',
        type: GameType.quizGame,
        pointsReward: 30 + gameRandom.nextInt(40),
        difficulty: 1 + gameRandom.nextInt(3),
        imageUrl: 'assets/games/quiz_game.png',
        gameConfig: {
          'questions': _generateQuizQuestions(),
          'timePerQuestion': 15,
        },
      ),
      GameData(
        id: 'memory_${today.day}',
        title: 'Green Memory Match',
        description: 'Match eco-friendly items and their benefits',
        type: GameType.memoryGame,
        pointsReward: 40 + gameRandom.nextInt(35),
        difficulty: 1 + gameRandom.nextInt(3),
        imageUrl: 'assets/games/memory_game.png',
        gameConfig: {
          'pairs': _generateMemoryPairs(),
          'gridSize': 4,
        },
      ),
      GameData(
        id: 'action_${today.day}',
        title: 'Clean City Runner',
        description: 'Collect waste while running through the city',
        type: GameType.actionGame,
        pointsReward: 60 + gameRandom.nextInt(60),
        difficulty: 2 + gameRandom.nextInt(2),
        imageUrl: 'assets/games/action_game.png',
        gameConfig: {
          'levels': 3,
          'obstacles': ['pollution', 'traffic', 'time'],
        },
      ),
    ];
    notifyListeners();
  }

  List<Map<String, String>> _generateSortingItems() {
    final items = [
      {'name': 'Banana Peel', 'type': 'Wet', 'image': 'banana_peel.png'},
      {'name': 'Plastic Bottle', 'type': 'Dry', 'image': 'plastic_bottle.png'},
      {'name': 'Battery', 'type': 'Hazardous', 'image': 'battery.png'},
      {'name': 'Newspaper', 'type': 'Dry', 'image': 'newspaper.png'},
      {'name': 'Food Scraps', 'type': 'Wet', 'image': 'food_scraps.png'},
      {'name': 'Medicine', 'type': 'Hazardous', 'image': 'medicine.png'},
      {'name': 'Cardboard', 'type': 'Dry', 'image': 'cardboard.png'},
      {'name': 'Vegetable Peels', 'type': 'Wet', 'image': 'vegetable_peels.png'},
    ];
    items.shuffle();
    return items.take(6).toList();
  }

  List<Map<String, dynamic>> _generateQuizQuestions() {
    final questions = [
      {
        'question': 'What percentage of India\'s waste is currently treated scientifically?',
        'options': ['34%', '54%', '74%', '84%'],
        'correct': 1,
        'explanation': 'According to CPCB data, only 54% of India\'s waste is scientifically treated.'
      },
      {
        'question': 'Which bin should you use for banana peels?',
        'options': ['Blue (Dry)', 'Green (Wet)', 'Red (Hazardous)', 'Any bin'],
        'correct': 1,
        'explanation': 'Organic waste like banana peels goes in the green (wet) bin.'
      },
      {
        'question': 'How much waste does India generate daily?',
        'options': ['1.2 lakh tonnes', '1.7 lakh tonnes', '2.1 lakh tonnes', '2.5 lakh tonnes'],
        'correct': 1,
        'explanation': 'India generates approximately 1.7 lakh tonnes of waste daily.'
      },
      {
        'question': 'What is the first step in waste management?',
        'options': ['Collection', 'Treatment', 'Source Segregation', 'Disposal'],
        'correct': 2,
        'explanation': 'Source segregation at the point of generation is the first and most important step.'
      },
    ];
    questions.shuffle();
    return questions.take(3).toList();
  }

  List<Map<String, String>> _generateMemoryPairs() {
    return [
      {'item': 'Compost', 'benefit': 'Rich Soil'},
      {'item': 'Recycling', 'benefit': 'Save Resources'},
      {'item': 'Segregation', 'benefit': 'Easy Processing'},
      {'item': 'Reuse', 'benefit': 'Reduce Waste'},
      {'item': 'Biogas', 'benefit': 'Clean Energy'},
      {'item': 'Awareness', 'benefit': 'Better Future'},
    ];
  }

  Future<void> playGame(String gameId) async {
    _lastPlayed[gameId] = DateTime.now();
    notifyListeners();
  }

  Future<void> completeGame(String gameId, int score, int pointsEarned) async {
    _gameScores[gameId] = score;
    _totalGamePoints += pointsEarned;
    _lastPlayed[gameId] = DateTime.now();
    notifyListeners();
  }

  bool canPlayGame(String gameId) {
    final lastPlayed = _lastPlayed[gameId];
    if (lastPlayed == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastPlayed);
    return difference.inHours >= 24; // Can play once per day
  }

  int getGameScore(String gameId) {
    return _gameScores[gameId] ?? 0;
  }

  void resetDailyGames() {
    final now = DateTime.now();
    final lastReset = DateTime(now.year, now.month, now.day);
    
    // Check if it's a new day
    final shouldReset = _lastPlayed.values.any((date) {
      return date.isBefore(lastReset);
    });
    
    if (shouldReset) {
      _generateDailyGames();
    }
  }
}