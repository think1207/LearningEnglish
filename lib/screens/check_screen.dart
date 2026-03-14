import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/app_colors.dart';
import 'dart:math';

enum AnswerResult { correct, almost, incorrect }

class CheckScreen extends StatefulWidget {
  final List<WordCard> wordsToCheck;

  const CheckScreen({super.key, required this.wordsToCheck});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  int _currentIndex = 0;
  int _weakCount = 0;
  bool _isAnswered = false;
  AnswerResult _lastResult = AnswerResult.incorrect;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var v0 = List<int>.filled(b.length + 1, 0);
    var v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i <= b.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[b.length];
  }

  AnswerResult _checkAnswerLogic(String input, List<String> correctMeanings) {
    final normalizedInput = input.trim().toLowerCase();
    if (normalizedInput.isEmpty) return AnswerResult.incorrect;

    bool isAlmost = false;

    for (final targetMeaning in correctMeanings) {
      final target = targetMeaning.trim().toLowerCase();

      if (normalizedInput == target) {
        return AnswerResult.correct;
      }

      if (normalizedInput.length >= 2 && target.length >= 2) {
        if (target.contains(normalizedInput) ||
            normalizedInput.contains(target)) {
          isAlmost = true;
        }
      }

      final distance = _levenshteinDistance(normalizedInput, target);
      if (target.length <= 4 && distance == 1) {
        isAlmost = true;
      } else if (target.length > 4 && distance <= 2) {
        isAlmost = true;
      }
    }

    return isAlmost ? AnswerResult.almost : AnswerResult.incorrect;
  }

  void _onCheckPressed() {
    if (_textController.text.trim().isEmpty) return;

    final currentWord = widget.wordsToCheck[_currentIndex];
    final result = _checkAnswerLogic(
      _textController.text,
      currentWord.meanings,
    );

    setState(() {
      _isAnswered = true;
      _lastResult = result;
      if (result == AnswerResult.incorrect) {
        _weakCount++;
      }
    });

    _focusNode.unfocus();
  }

  void _onNextPressed() {
    setState(() {
      if (_currentIndex < widget.wordsToCheck.length - 1) {
        // --- まだ次の問題がある場合は、状態をリセットして進む ---
        _currentIndex++;
        _isAnswered = false;
        _textController.clear();
        Future.delayed(
          const Duration(milliseconds: 100),
          () => _focusNode.requestFocus(),
        );
      } else {
        // --- 全問終了した場合 ---
        // TODO: 全問終了用の ResultScreen ができたら、以下のように pushReplacement で遷移させるのがベストです。
        /*
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              totalWords: widget.wordsToCheck.length,
              weakCount: _weakCount,
            ),
          ),
        );
        */

        // とりあえず現状はホーム画面まで戻る処理にしています
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.wordsToCheck.length;
    final currentWord = widget.wordsToCheck[_currentIndex];

    const Color bgGreen = AppColors.primary;
    const Color cardGreen = Color(0xFF7B9586);
    const Color cardRed = Color(0xFFD07D6D);

    return Scaffold(
      backgroundColor: bgGreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Check New Words',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${_currentIndex + 1}/$totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Weak flagged',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$_weakCount',
                        style: const TextStyle(
                          color: Color(0xFFE89A8F),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentWord.text,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              currentWord.partOfSpeech.isEmpty
                                  ? 'noun'
                                  : currentWord.partOfSpeech,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _isAnswered &&
                                        _lastResult == AnswerResult.incorrect
                                    ? const Color(0xFFFDECEB)
                                    : AppColors.background,
                              ),
                              child: Icon(
                                Icons.volume_up,
                                color:
                                    _isAnswered &&
                                        _lastResult == AnswerResult.incorrect
                                    ? cardRed
                                    : AppColors.textLight,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!_isAnswered) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                          decoration: const InputDecoration(
                            hintText: '日本語の意味を入力',
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _onCheckPressed(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onCheckPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Check',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Type the Japanese meaning',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: _lastResult == AnswerResult.incorrect
                              ? cardRed
                              : cardGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _lastResult == AnswerResult.incorrect
                                    ? Icons.close
                                    : Icons.check,
                                color: _lastResult == AnswerResult.incorrect
                                    ? cardRed
                                    : cardGreen,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _lastResult == AnswerResult.incorrect
                                  ? 'Repeat'
                                  : (_lastResult == AnswerResult.almost
                                        ? 'Nice! (惜しい)'
                                        : 'Nice!'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your answer:',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _textController.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _lastResult == AnswerResult.incorrect
                                    ? cardRed
                                    : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Correct meaning:',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentWord.meanings.join('、'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cardGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _lastResult == AnswerResult.incorrect
                                ? cardRed
                                : cardGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
