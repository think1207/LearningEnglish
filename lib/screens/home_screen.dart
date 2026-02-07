import 'package:flutter/material.dart';
import 'package:learning_english/repositories/local_word_repository.dart';
import 'package:learning_english/screens/add_word_screen.dart';
import 'package:learning_english/screens/learning_session_screen.dart';

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
  String _selectedCategory = 'All';

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

  List<String> _getCategoryList() {
    final categories = _allWords.map((w) => w.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  void _startSession() {
    final candidates = _allWords.where((w) {
      final categoryMatch =
          _selectedCategory == 'All' || w.category == _selectedCategory;
      final notMastered = w.status != WordStatus.mastered;
      return categoryMatch && notMastered;
    }).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('学習対象の単語がありません！(すべてマスター済みか、カテゴリに単語がありません)'),
        ),
      );
      return;
    }

    candidates.shuffle();
    final sessionQueue = candidates.take(10).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningSessionScreen(initialQueue: sessionQueue),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final masteredCount = _allWords
        .where((w) => w.status == WordStatus.mastered)
        .length;
    final totalCount = _allWords.length;
    final progress = totalCount > 0 ? masteredCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vocab App'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _repo.resetData();
              _loadData();
            },
            tooltip: 'データをリセット',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.indigo,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Total Progress',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$masteredCount / $totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      color: Colors.greenAccent,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mastered Words',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Start Learning',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _getCategoryList().map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session (10 Words)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWordScreen()),
          ).then((_) => _loadData());
        },
        label: const Text('Add Word'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
