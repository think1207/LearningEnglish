import 'package:flutter/material.dart';

import '../models/word.dart';
import '../repositories/local_word_repository.dart';
import '../widgets/word_card.dart';

enum SessionPhase { sorting, reviewReady, review, completed }

class LearningSessionScreen extends StatefulWidget {
  const LearningSessionScreen({super.key});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  final _repo = LocalWordRepository();

  List<WordCard> _allWords = [];
  List<WordCard> _currentQueue = [];
  final List<WordCard> _retryList = [];

  SessionPhase _phase = SessionPhase.sorting;
  bool _isAnswerVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final words = await _repo.loadWords();

    final activeWords =
        words.where((w) => w.status != WordStatus.mastered).toList();

    activeWords.shuffle();
    final todaysQueue = activeWords.take(10).toList();

    setState(() {
      _allWords = words;
      _currentQueue = todaysQueue;
      _isLoading = false;

      if (todaysQueue.isEmpty && words.isNotEmpty) {
        _phase = SessionPhase.completed;
      }
    });
  }

  Future<void> _saveProgress() async {
    await _repo.saveWords(_allWords);
  }

  void _toggleCard() {
    setState(() {
      _isAnswerVisible = !_isAnswerVisible;
    });
  }

  void _onSwiped(bool isRight) {
    if (_currentQueue.isEmpty) return;

    final currentCard = _currentQueue.first;

    setState(() {
      if (isRight) {
        currentCard.proficiency++;
        if (currentCard.proficiency >= 3) {
          currentCard.status = WordStatus.mastered;
        } else {
          currentCard.status = WordStatus.learning;
        }
      } else {
        currentCard.proficiency = 0;
        currentCard.status = WordStatus.learning;
        _retryList.add(currentCard);
      }

      _currentQueue.removeAt(0);
      _isAnswerVisible = false;

      _saveProgress();
      _checkPhaseTransition();
    });
  }

  void _checkPhaseTransition() {
    if (_currentQueue.isNotEmpty) return;

    if (_phase == SessionPhase.sorting || _phase == SessionPhase.review) {
      if (_retryList.isNotEmpty) {
        setState(() {
          _phase = SessionPhase.reviewReady;
        });
      } else {
        setState(() {
          _phase = SessionPhase.completed;
        });
      }
    }
  }

  void _startReview() {
    setState(() {
      _phase = SessionPhase.review;
      _currentQueue = List.from(_retryList);
      _currentQueue.shuffle();
      _retryList.clear();
    });
  }

  Future<void> _resetAndReload() async {
    await _repo.resetData();
    setState(() {
      _isLoading = true;
      _phase = SessionPhase.sorting;
      _retryList.clear();
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: _getAppBarColor(),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset learning status...",
            onPressed: _resetAndReload,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_phase == SessionPhase.sorting || _phase == SessionPhase.review)
              _buildProgressBar(),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value:
          _phase == SessionPhase.review ? (_currentQueue.isEmpty ? 1.0 : 0.5) : null,
      backgroundColor: Colors.grey.shade300,
      color: _getAppBarColor(),
    );
  }

  String _getAppBarTitle() {
    switch (_phase) {
      case SessionPhase.sorting:
        return '仕分け (Sorting)';
      case SessionPhase.reviewReady:
        return '準備完了';
      case SessionPhase.review:
        return '復習 (Review)';
      case SessionPhase.completed:
        return '完了';
    }
  }

  Color _getAppBarColor() {
    switch (_phase) {
      case SessionPhase.sorting:
        return Colors.indigo;
      case SessionPhase.reviewReady:
        return Colors.orange;
      case SessionPhase.review:
        return Colors.deepOrange;
      case SessionPhase.completed:
        return Colors.green;
    }
  }

  Widget _buildBodyContent() {
    if (_currentQueue.isEmpty) {
      if (_phase == SessionPhase.completed) return _buildCompletedScreen();
      if (_phase == SessionPhase.reviewReady) return _buildReviewReadyScreen();
      // Handles other empty states, e.g., initial load after sorting
      return const Center(child: CircularProgressIndicator());
    }

    switch (_phase) {
      case SessionPhase.sorting:
      case SessionPhase.review:
        return _buildCardStack();
      case SessionPhase.reviewReady:
        return _buildReviewReadyScreen();
      case SessionPhase.completed:
        return _buildCompletedScreen();
    }
  }

  Widget _buildCardStack() {
    final topCardData = _currentQueue.first;
    final secondCardData = _currentQueue.length > 1 ? _currentQueue[1] : null;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (secondCardData != null)
            Transform.scale(
              scale: 0.95,
              child: Transform.translate(
                offset: const Offset(0, 15),
                child: Opacity(
                  opacity: 0.6,
                  child: StaticCard(card: secondCardData, isVisible: false),
                ),
              ),
            ),
          SwipeableCard(
            key: ValueKey(topCardData.id),
            card: topCardData,
            isAnswerVisible: _isAnswerVisible,
            onTap: _toggleCard,
            onSwiped: _onSwiped,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewReadyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.repeat, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          Text(
            "苦手な ${_retryList.length}語を復習します",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text("スタート"),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedScreen() {
    final masteredCount =
        _allWords.where((w) => w.status == WordStatus.mastered).length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            "本日の学習終了！",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "現在のマスター単語: $masteredCount / ${_allWords.length}",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text("明日も頑張りましょう。", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
