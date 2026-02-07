import 'package:flutter_test/flutter_test.dart';
import 'package:learning_english/models/word.dart';
import 'package:learning_english/repositories/local_word_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalWordRepository', () {
    late LocalWordRepository repository;
    final initialWords = [
      WordCard(id: '1', text: 'Agile', meaning: '俊敏な / アジャイル開発', category: 'IT'),
      WordCard(
          id: '2',
          text: 'Consensus',
          meaning: '合意 / 総意',
          category: 'Business'),
      WordCard(
          id: '3', text: 'Legacy', meaning: '遺産 / (IT)古いシステム', category: 'IT'),
      WordCard(
          id: '4', text: 'Stakeholder', meaning: '利害関係者', category: 'Business'),
      WordCard(id: '5', text: 'Scalability', meaning: '拡張性', category: 'IT'),
      WordCard(id: '6', text: 'Pivot', meaning: '方向転換', category: 'Startup'),
      WordCard(id: '7', text: 'Disruptive', meaning: '破壊的な', category: 'Startup'),
      WordCard(
          id: '8', text: 'Retention', meaning: '維持 / 保持率', category: 'Marketing'),
    ];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = LocalWordRepository();
    });

    test('loadWords returns initial words when no data is in SharedPreferences',
        () async {
      final words = await repository.loadWords();
      expect(words.map((e) => e.toJson()),
          equals(initialWords.map((e) => e.toJson())));
    });

    test('addWord adds a new word and saves it', () async {
      final newWord =
          WordCard(id: '9', text: 'test', meaning: 'テスト', category: 'Test');
      await repository.addWord(newWord);
      final words = await repository.loadWords();
      expect(words.length, initialWords.length + 1);
      expect(words.last.text, 'test');
    });

    test('saveWords saves a list of words', () async {
      final customWords = [
        WordCard(id: '10', text: 'custom', meaning: 'カスタム', category: 'Test'),
      ];
      await repository.saveWords(customWords);
      final words = await repository.loadWords();
      expect(words.length, 1);
      expect(words.first.text, 'custom');
    });

    test('resetData clears all words from SharedPreferences', () async {
      final customWords = [
        WordCard(id: '10', text: 'custom', meaning: 'カスタム', category: 'Test'),
      ];
      await repository.saveWords(customWords);
      var words = await repository.loadWords();
      expect(words.isNotEmpty, isTrue);

      await repository.resetData();
      words = await repository.loadWords();
      // reset後はmasterDataが返される
      expect(words.map((e) => e.toJson()),
          equals(initialWords.map((e) => e.toJson())));
    });
  });
}
