import 'package:flutter/material.dart';
import 'package:banexy/repositories/local_word_repository.dart';
import 'package:banexy/theme/app_colors.dart';
import '../widgets/app_header.dart';

import '../models/word.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _partOfSpeechCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _meaningCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final newWord = WordCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _textCtrl.text,
        meaning: _meaningCtrl.text,
        category: _categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : 'User',
        partOfSpeech: _partOfSpeechCtrl.text.isNotEmpty
            ? _partOfSpeechCtrl.text
            : 'Noun',
      );

      await LocalWordRepository().addWord(newWord);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('単語を追加しました！')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Add New Word', subtitle: '新しい単語を辞書に追加'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _textCtrl,
                        decoration: const InputDecoration(
                          labelText: 'English Word / Phrase',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.abc),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter a word'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _meaningCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Meaning (Japanese)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.translate),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter a meaning'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Category (Optional)',
                          hintText: 'e.g., My List, Work, etc...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Word',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
