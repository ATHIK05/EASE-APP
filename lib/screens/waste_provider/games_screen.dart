import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/game_widgets.dart';

class GamesScreen extends StatefulWidget {
  final String? initialGameId;
  
  const GamesScreen({super.key, this.initialGameId});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
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
              Color(0xFF8B5CF6),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.games,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Eco Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Learn while having fun!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        return Container(
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
                                '${gameProvider.totalGamePoints}',
                                style: const TextStyle(
                                  color: Colors.white,
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
              ),
              
              // Games List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: gameProvider.dailyGames.length,
                        itemBuilder: (context, index) {
                          final game = gameProvider.dailyGames[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildGameCard(game, gameProvider),
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

  Widget _buildGameCard(GameData game, GameProvider gameProvider) {
    final canPlay = gameProvider.canPlayGame(game.id);
    final score = gameProvider.getGameScore(game.id);
    
    Color gameColor;
    IconData gameIcon;
    
    switch (game.type) {
      case GameType.sortingGame:
        gameColor = Colors.green;
        gameIcon = Icons.sort;
        break;
      case GameType.quizGame:
        gameColor = Colors.blue;
        gameIcon = Icons.quiz;
        break;
      case GameType.memoryGame:
        gameColor = Colors.purple;
        gameIcon = Icons.memory;
        break;
      case GameType.actionGame:
        gameColor = Colors.orange;
        gameIcon = Icons.directions_run;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gameColor.withOpacity(0.8), gameColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gameColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    gameIcon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Game Stats
            Row(
              children: [
                _buildStatChip(Icons.stars, '${game.pointsReward} pts', Colors.yellow[300]!),
                const SizedBox(width: 12),
                _buildStatChip(Icons.signal_cellular_alt, 'Level ${game.difficulty}', Colors.white70),
                if (score > 0) ...[
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.emoji_events, 'Best: $score', Colors.white70),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Play Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canPlay 
                    ? () => _playGame(game, gameProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: gameColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canPlay ? 'Play Now' : 'Played Today',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
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

  void _playGame(GameData game, GameProvider gameProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamePlayScreen(
          game: game,
          onGameComplete: (score, pointsEarned) async {
            await gameProvider.completeGame(game.id, score, pointsEarned);
            
            // Award points to user
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.updateUserPoints(pointsEarned);
            
            _confettiController.play();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Game completed! +$pointsEarned points earned'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class GamePlayScreen extends StatefulWidget {
  final GameData game;
  final Function(int score, int pointsEarned) onGameComplete;

  const GamePlayScreen({
    super.key,
    required this.game,
    required this.onGameComplete,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  int _score = 0;
  bool _gameCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: _buildGameContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    switch (widget.game.type) {
      case GameType.sortingGame:
        return SortingGameWidget(
          gameConfig: widget.game.gameConfig,
          onScoreUpdate: (score) => setState(() => _score = score),
          onGameComplete: (finalScore) => _completeGame(finalScore),
        );
      case GameType.quizGame:
        return QuizGameWidget(
          gameConfig: widget.game.gameConfig,
          onScoreUpdate: (score) => setState(() => _score = score),
          onGameComplete: (finalScore) => _completeGame(finalScore),
        );
      case GameType.memoryGame:
        return MemoryGameWidget(
          gameConfig: widget.game.gameConfig,
          onScoreUpdate: (score) => setState(() => _score = score),
          onGameComplete: (finalScore) => _completeGame(finalScore),
        );
      case GameType.actionGame:
        return ActionGameWidget(
          gameConfig: widget.game.gameConfig,
          onScoreUpdate: (score) => setState(() => _score = score),
          onGameComplete: (finalScore) => _completeGame(finalScore),
        );
    }
  }

  void _completeGame(int finalScore) {
    if (!_gameCompleted) {
      _gameCompleted = true;
      final pointsEarned = (finalScore * widget.game.pointsReward / 100).round();
      widget.onGameComplete(finalScore, pointsEarned);
      
      // Show completion dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.yellow,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $finalScore',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$pointsEarned Points Earned',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close game screen
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}