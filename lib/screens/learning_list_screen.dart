import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import './check_screen.dart';

class LearningListScreen extends StatefulWidget {
  final List<WordCard> wordsToLearn;

  const LearningListScreen({super.key, required this.wordsToLearn});

  @override
  State<LearningListScreen> createState() => _LearningListScreenState();
}

class _LearningListScreenState extends State<LearningListScreen> {
  final Set<String> _expandedCardIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedCardIds.contains(id)) {
        _expandedCardIds.remove(id);
      } else {
        _expandedCardIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Today's New Words",
              subtitleWidget: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.wordsToLearn.length} words to learn',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.wordsToLearn.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final word = widget.wordsToLearn[index];
                  final isExpanded = _expandedCardIds.contains(word.id);
                  return _buildWordListItem(word, isExpanded);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.background),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CheckScreen(wordsToCheck: widget.wordsToLearn),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Check',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordListItem(WordCard word, bool isExpanded) {
    final displayExample = word.example.isNotEmpty
        ? word.example
        : 'The implementation of the new system took six months.';
    final displayTranslation = word.exampleTranslation.isNotEmpty
        ? word.exampleTranslation
        : '新システムの実装には6ヶ月かかった。';
    final displaySynonyms = word.synonyms.isNotEmpty
        ? word.synonyms
        : ['execution', 'deployment'];

    return GestureDetector(
      onTap: () => _toggleExpand(word.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: isExpanded
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : EdgeInsets.zero,
        padding: isExpanded
            ? const EdgeInsets.all(20)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isExpanded
              ? BorderRadius.circular(16)
              : BorderRadius.zero,
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    word.partOfSpeech.isEmpty ? 'noun' : word.partOfSpeech,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ],
            ),

            if (isExpanded) ...[
              const SizedBox(height: 16),
              Text(
                word.meanings.join(' / '),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Example',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: AppColors.textLight,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayExample,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayTranslation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '類義語',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displaySynonyms
                    .map((synonym) => _buildSynonymChip(synonym))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSynonymChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
      ),
    );
  }
}
