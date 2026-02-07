import 'package:flutter/material.dart';
import 'package:learning_english/repositories/local_word_repository.dart';

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
      appBar: AppBar(title: const Text('Add New Word')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textCtrl,
                decoration: const InputDecoration(
                  labelText: 'English Word / Phrase',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a word' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _meaningCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meaning (Japanese)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.translate),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a meaning' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  hintText: 'e.g., My List, Work, etc...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Word'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
