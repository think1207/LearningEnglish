import 'package:flutter/material.dart';

import '../models/word.dart';
import '../repositories/local_word_repository.dart';
import '../widgets/word_card.dart';

enum SessionPhase { sorting, reviewReady, review, completed }

class LearningSessionScreen extends StatefulWidget {
  final List<WordCard> initialQueue;

  const LearningSessionScreen({super.key, required this.initialQueue});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  final _repo = LocalWordRepository();

  List<WordCard> _currentQueue = [];
  final List<WordCard> _retryList = [];
  int _reviewTotal = 0;

  SessionPhase _phase = SessionPhase.sorting;
  bool _isAnswerVisible = false;

  @override
  void initState() {
    super.initState();
    _currentQueue = List.from(widget.initialQueue);
  }

  void _saveProgress(WordCard card) {
    _repo.loadWords().then((allWords) {
      final index = allWords.indexWhere((w) => w.id == card.id);
      if (index != -1) {
        allWords[index] = card;
        _repo.saveWords(allWords);
      }
    });
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

      _saveProgress(currentCard);

      if (_currentQueue.isEmpty) {
        if (_phase == SessionPhase.sorting || _phase == SessionPhase.review) {
          if (_retryList.isNotEmpty) {
            _phase = SessionPhase.reviewReady;
          } else {
            _phase = SessionPhase.completed;
          }
        }
      }
    });
  }

  void _startReview() {
    setState(() {
      _phase = SessionPhase.review;
      _currentQueue = List.from(_retryList);
      _reviewTotal = _retryList.length;
      _currentQueue.shuffle();
      _retryList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: _getAppBarColor(),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double? value;
    switch (_phase) {
      case SessionPhase.sorting:
        if (widget.initialQueue.isNotEmpty) {
          value = (widget.initialQueue.length - _currentQueue.length) /
              widget.initialQueue.length;
        } else {
          value = 1.0;
        }
        break;
      case SessionPhase.review:
        if (_reviewTotal > 0) {
          value = (_reviewTotal - _currentQueue.length) / _reviewTotal;
        } else {
          value = 1.0;
        }
        break;
      case SessionPhase.reviewReady:
        value = 0.0;
        break;
      case SessionPhase.completed:
        value = 1.0;
        break;
    }

    return LinearProgressIndicator(
      value: value,
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
    if (_currentQueue.isEmpty) return const Center(child: Text("Loading..."));
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
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ホームに戻る"),
          ),
        ],
      ),
    );
  }
}
