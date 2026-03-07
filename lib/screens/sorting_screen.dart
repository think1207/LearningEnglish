import 'package:flutter/material.dart';

import '../models/word.dart';
import '../repositories/local_word_repository.dart';
import '../widgets/word_card.dart';

enum SessionPhase { sorting, reviewReady, review, completed }

class SwipeHistory {
  final WordCard card;
  final bool isRightSwipe;
  SwipeHistory(this.card, this.isRightSwipe);
}

class SortingScreen extends StatefulWidget {
  final List<WordCard> initialQueue;
  final String category;

  const SortingScreen({
    super.key,
    required this.initialQueue,
    this.category = 'Technology',
  });

  @override
  State<SortingScreen> createState() => _SortingScreenState();
}

class _SortingScreenState extends State<SortingScreen> {
  final _repo = LocalWordRepository();

  List<WordCard> _currentQueue = [];
  final List<WordCard> _retryList = [];
  final List<SwipeHistory> _history = [];

  int _initialCount = 0;
  SessionPhase _phase = SessionPhase.sorting;
  bool _isAnswerVisible = false;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  static const Color _primaryColor = Color(0xFF8BA094);
  static const Color _dangerColor = Color(0xFFD97061);
  static const Color _bgColor = Color(0xFFF4F5F6);
  static const Color _textColorDark = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    _currentQueue = List.from(widget.initialQueue);
    _initialCount = _currentQueue.length;
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

  void _onSwiped(bool isRight) {
    if (_currentQueue.isEmpty) return;

    final currentCard = _currentQueue.first;

    setState(() {
      // 履歴に保存
      _history.add(SwipeHistory(currentCard, isRight));

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
      _dragOffset = Offset.zero;

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

  void _undo() {
    if (_history.isEmpty) return;

    setState(() {
      final lastSwipe = _history.removeLast();
      final card = lastSwipe.card;

      _currentQueue.insert(0, card);

      if (!lastSwipe.isRightSwipe) {
        _retryList.removeWhere((w) => w.id == card.id);
      }

      // プログレスを元に戻す（簡易的にステータスを戻す）
      // ※厳密なproficiencyの巻き戻しが必要な場合は調整してください
      card.status = WordStatus.learning;
      _saveProgress(card);

      _isAnswerVisible = false;
      _dragOffset = Offset.zero;
    });
  }

  void _startReview() {
    setState(() {
      _phase = SessionPhase.review;
      _currentQueue = List.from(_retryList);
      _initialCount = _retryList.length;
      _currentQueue.shuffle();
      _retryList.clear();
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            if (_phase == SessionPhase.sorting ||
                _phase == SessionPhase.review) ...[
              _buildProgressHeader(),
              _buildSwipeHints(),
            ],
            Expanded(child: _buildBodyContent()),
            if (_phase == SessionPhase.sorting || _phase == SessionPhase.review)
              _buildUndoButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: _textColorDark),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            _getAppBarTitle(),
            style: const TextStyle(
              color: _textColorDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getAppBarSubtitle(),
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_phase) {
      case SessionPhase.sorting:
        return 'Sort';
      case SessionPhase.reviewReady:
        return 'Ready';
      case SessionPhase.review:
        return 'Review';
      case SessionPhase.completed:
        return 'Completed';
    }
  }

  String _getAppBarSubtitle() {
    switch (_phase) {
      case SessionPhase.sorting:
        return '学習する単語を仕分け';
      case SessionPhase.reviewReady:
        return '復習の準備ができました';
      case SessionPhase.review:
        return '苦手な単語を復習';
      case SessionPhase.completed:
        return 'お疲れ様でした！';
    }
  }

  Widget _buildProgressHeader() {
    final processedCount = _initialCount - _currentQueue.length;
    final progressValue = _initialCount > 0
        ? processedCount / _initialCount
        : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Unknown: $processedCount/$_initialCount",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      widget.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey.shade200,
            color: _primaryColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHints() {
    double leftOpacity = 0.0;
    double rightOpacity = 0.0;

    if (_isDragging) {
      if (_dragOffset.dx < 0) {
        leftOpacity = (_dragOffset.dx.abs() / 150).clamp(0.0, 0.15);
      } else if (_dragOffset.dx > 0) {
        rightOpacity = (_dragOffset.dx / 150).clamp(0.0, 0.15);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Don't know
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _dangerColor.withOpacity(leftOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: leftOpacity > 0 ? _dangerColor : Colors.black26,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "Don't know",
                  style: TextStyle(
                    color: leftOpacity > 0 ? _dangerColor : Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Know
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(rightOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  "Know",
                  style: TextStyle(
                    color: rightOpacity > 0 ? _primaryColor : Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle_outline,
                  color: rightOpacity > 0 ? _primaryColor : Colors.black26,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

    Color currentAnswerColor = Colors.black87;
    if (_isDragging) {
      if (_dragOffset.dx > 0) {
        currentAnswerColor = _primaryColor;
      } else if (_dragOffset.dx < 0) {
        currentAnswerColor = _dangerColor;
      }
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 後ろのカード（ダミー）
          if (secondCardData != null)
            Transform.scale(
              scale: 0.95,
              child: Transform.translate(
                offset: const Offset(0, 20),
                child: Opacity(
                  opacity: 0.5,
                  child: StaticCard(card: secondCardData, isVisible: false),
                ),
              ),
            ),

          SwipeableCard(
            key: ValueKey(topCardData.id),
            card: topCardData,
            isAnswerVisible: _isAnswerVisible,
            answerColor: currentAnswerColor,
            onTap: () {},
            onSwiped: _onSwiped,
            onDragUpdate: (offset) {
              setState(() {
                _isDragging = true;
                _dragOffset = offset;
                _isAnswerVisible = true;
              });
            },
            onDragEnd: () {
              setState(() {
                _isDragging = false;
                _dragOffset = Offset.zero;
                _isAnswerVisible = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUndoButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: OutlinedButton(
        onPressed: _history.isEmpty ? null : _undo,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(
            color: _history.isEmpty
                ? Colors.grey.shade200
                : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.undo,
              color: _history.isEmpty ? Colors.black26 : _textColorDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Undo',
              style: TextStyle(
                color: _history.isEmpty ? Colors.black26 : _textColorDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewReadyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.repeat, size: 80, color: _dangerColor),
          const SizedBox(height: 20),
          Text(
            "苦手な ${_retryList.length}語を復習します",
            style: const TextStyle(fontSize: 18, color: _textColorDark),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("スタート", style: TextStyle(fontSize: 18)),
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
          const Icon(Icons.check_circle, size: 80, color: _primaryColor),
          const SizedBox(height: 24),
          const Text(
            "本日の学習終了！",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColorDark,
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("ホームに戻る", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
