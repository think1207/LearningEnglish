import 'package:flutter/material.dart';
import 'package:banexy/repositories/local_word_repository.dart';
import 'package:banexy/screens/add_word_screen.dart';
import 'package:banexy/screens/new_words_setup_screen.dart';

import '../models/word.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalWordRepository _repo = LocalWordRepository();
  List<WordCard> _allWords = [];
  bool _isLoading = true;

  static const Color _headerColor = Color(0xFF8BA094);
  static const Color _bgColor = Color(0xFFF4F5F6);
  static const Color _textColorDark = Color(0xFF2C3E50);
  static const Color _textColorLight = Color(0xFF7F8C8D);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final words = await _repo.loadWords();
    if (mounted) {
      setState(() {
        _allWords = words;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final masteredCount = _allWords
        .where((w) => w.status == WordStatus.mastered)
        .length;

    final weakCount = 24;
    final learningCount = 18;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: _headerColor,
              padding: const EdgeInsets.only(
                top: 72,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Words',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white70,
                            ),
                            onPressed: () async {
                              await _repo.resetData();
                              _loadData();
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '🍌 7',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Master technical vocabulary for your career',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildActionCard(
                  title: 'New Words',
                  subtitle1: '前回：Technology',
                  subtitle2: '新しい単語を学ぶ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NewWordsSetupScreen(allWords: _allWords),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  title: 'Review',
                  badgeText: 'Due: 12',
                  subtitle1: 'Recent 3d + Overdue 7d',
                  subtitle2: '復習が必要な単語の確認',
                  onTap: () {
                    // TODO: Implement review screen
                  },
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  icon: Icons.list,
                  title: 'Lists',
                  subtitle1: 'Mastered / Weak / Learning',
                  onTap: () {
                    // TODO: Implement lists screen
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'YOUR PROGRESS',
                  style: TextStyle(
                    color: _textColorLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        count: masteredCount.toString(),
                        label: 'Mastered',
                        countColor: _textColorDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        count: weakCount.toString(),
                        label: 'Weak',
                        countColor: const Color(0xFFC7715D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProgressCard(
                        count: learningCount.toString(),
                        label: 'Learning',
                        countColor: const Color(0xFF658671),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWordScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: _headerColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionCard({
    IconData? icon,
    required String title,
    String? badgeText,
    required String subtitle1,
    String? subtitle2,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: _textColorLight),
                  ),
                  const SizedBox(width: 16),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textColorDark,
                            ),
                          ),

                          if (badgeText != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBECEB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badgeText,
                                style: const TextStyle(
                                  color: Color(0xFFC7715D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle1,
                        style: const TextStyle(
                          color: _textColorLight,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle2 != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle2,
                          style: const TextStyle(
                            color: _textColorLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String count,
    required String label,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textColorDark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
