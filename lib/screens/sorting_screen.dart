import 'package:flutter/material.dart';

import '../models/word.dart';
import '../repositories/local_word_repository.dart';
import '../widgets/word_card.dart';
import 'sort_complete_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';

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
  bool _isAnswerVisible = false;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SortCompleteScreen(retryList: _retryList),
          ),
        );
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

      card.status = WordStatus.learning;
      _saveProgress(card);

      _isAnswerVisible = false;
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Sort',
              subtitle: '学習する単語を仕分け',
              leftIcon: Icons.close,
            ),
            _buildProgressSection(),
            _buildSwipeHints(),
            Expanded(child: _buildCardStack()),
            _buildUndoButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final processedCount = _initialCount - _currentQueue.length;
    final progressValue = _initialCount > 0
        ? processedCount / _initialCount
        : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Unknown: $processedCount/$_initialCount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // Figmaに合わせてチップの背景を白に
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.code,
                          size: 14,
                          color: AppColors.textDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Figmaのような丸みのあるプログレスバー
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.shade300,
                  color: AppColors.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        // プログレスバーのすぐ下に入る横幅いっぱいの区切り線
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      ],
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: leftOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: leftOpacity > 0 ? AppColors.danger : Colors.black26,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "Don't know",
                  style: TextStyle(
                    color: leftOpacity > 0 ? AppColors.danger : Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: rightOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  "Know",
                  style: TextStyle(
                    color: rightOpacity > 0
                        ? AppColors.primary
                        : Colors.black26,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle_outline,
                  color: rightOpacity > 0 ? AppColors.primary : Colors.black26,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    if (_currentQueue.isEmpty) return const Center(child: Text("Loading..."));

    final topCardData = _currentQueue.first;
    final secondCardData = _currentQueue.length > 1 ? _currentQueue[1] : null;

    Color currentAnswerColor = AppColors.textDark;
    if (_isDragging) {
      if (_dragOffset.dx > 0) {
        currentAnswerColor = AppColors.primary;
      } else if (_dragOffset.dx < 0) {
        currentAnswerColor = AppColors.danger;
      }
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
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
              color: _history.isEmpty ? Colors.black26 : AppColors.textDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Undo',
              style: TextStyle(
                color: _history.isEmpty ? Colors.black26 : AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
