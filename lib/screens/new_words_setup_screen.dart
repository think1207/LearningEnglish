import 'package:flutter/material.dart';

import '../models/word.dart';
import 'sorting_screen.dart';
import '../theme/app_colors.dart';

class NewWordsSetupScreen extends StatefulWidget {
  final List<WordCard> allWords;

  const NewWordsSetupScreen({super.key, required this.allWords});

  @override
  State<NewWordsSetupScreen> createState() => _NewWordsSetupScreenState();
}

class _NewWordsSetupScreenState extends State<NewWordsSetupScreen> {
  String _selectedCategory = 'Technology';
  int _targetCount = 10;
  bool _saveAsDefault = false;

  void _startSorting() {
    final candidates = widget.allWords.where((w) {
      final categoryMatch =
          w.category == _selectedCategory || w.category.isEmpty;
      final notMastered = w.status != WordStatus.mastered;
      return categoryMatch && notMastered;
    }).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedCategory の学習対象単語がありません！'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    candidates.shuffle();
    final sessionQueue = candidates.take(_targetCount).toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SortingScreen(
          initialQueue: sessionQueue,
          category: _selectedCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textDark,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'New Words',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '学習モードと今日の目標を選択',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECT MODE',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildModeCard(
                      title: 'General',
                      subtitle: 'Common words for daily use',
                      icon: Icons.language,
                    ),
                    _buildModeCard(
                      title: 'Technology',
                      subtitle: 'Tech & engineering terms',
                      icon: Icons.code,
                    ),
                    _buildModeCard(
                      title: 'Business',
                      subtitle: 'Business & management vocab',
                      icon: Icons.work_outline,
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "TODAY'S NEW TARGET",
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTargetCard(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startSorting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Sorting',
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

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 28)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (_targetCount > 5) setState(() => _targetCount -= 5);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, color: AppColors.textDark),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_targetCount',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Text(
                    'words',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (_targetCount < 50) setState(() => _targetCount += 5);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              5,
              10,
              15,
              20,
              30,
            ].map((val) => _buildChip(val)).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Save as default',
                style: TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
              Switch(
                value: _saveAsDefault,
                onChanged: (val) => setState(() => _saveAsDefault = val),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int value) {
    final isSelected = _targetCount == value;
    return GestureDetector(
      onTap: () => setState(() => _targetCount = value),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
