import 'package:flutter/material.dart';

import '../data_models.dart';
import '../mock_data.dart';
import '../widgets/word_card.dart';

enum SessionPhase { sorting, reviewReady, review, completed }

class LearningSessionScreen extends StatefulWidget {
  const LearningSessionScreen({super.key});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  List<WordCard> _currentQueue = [];
  final List<WordCard> _retryList = [];
  final List<WordCard> _knownList = [];

  SessionPhase _phase = SessionPhase.sorting;
  bool _isAnswerVisible = false;

  @override
  void initState() {
    super.initState();
    _currentQueue = List.from(initialData);
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
        _knownList.add(currentCard);
      } else {
        _retryList.add(currentCard);
      }

      _currentQueue.removeAt(0);
      _isAnswerVisible = false;

      _checkPhaseTransition();
    });
  }

  void _checkPhaseTransition() {
    if (_currentQueue.isNotEmpty) return;

    if (_phase == SessionPhase.sorting) {
      if (_retryList.isNotEmpty) {
        setState(() {
          _phase = SessionPhase.reviewReady;
        });
      } else {
        setState(() {
          _phase = SessionPhase.completed;
        });
      }
    } else if (_phase == SessionPhase.review) {
      if (_retryList.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('間違えた単語をもう一度！'),
            duration: Duration(seconds: 1),
          ),
        );
        setState(() {
          _currentQueue = List.from(_retryList);
          _currentQueue.shuffle();
          _retryList.clear();
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
      _retryList.clear();
    });
  }

  void _resetSession() {
    setState(() {
      _phase = SessionPhase.sorting;
      _currentQueue = List.from(initialData);
      _knownList.clear();
      _retryList.clear();
      _isAnswerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: _getAppBarColor(),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_phase == SessionPhase.sorting || _phase == SessionPhase.review)
              LinearProgressIndicator(
                value: _phase == SessionPhase.review
                    ? (_currentQueue.isEmpty ? 1.0 : 0.5)
                    : null,
                backgroundColor: Colors.grey.shade300,
                color: _getAppBarColor(),
              ),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
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
    if (_currentQueue.isEmpty) {
      return const Center(child: Text('Loading'));
    }

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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.repeat, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              '仕分け完了！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "「知らない」と答えた ${_retryList.length}個の単語を\n覚えるまで繰り返します。",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("復習スタート"),
            ),
          ],
        ),
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
          const SizedBox(height: 16),
          Text(
            "合計学習数: ${_knownList.length + _retryList.length}単語",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: _resetSession,
            child: const Text("最初に戻る (デバッグ用)"),
          ),
        ],
      ),
    );
  }
}
