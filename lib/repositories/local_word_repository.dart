import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';
import './base_word_repository.dart';

class LocalWordRepository implements BaseWordRepository {
  static final LocalWordRepository _instance = LocalWordRepository._internal();

  factory LocalWordRepository() => _instance;

  LocalWordRepository._internal();

  static const String _storageKey = 'user_study_data';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  final List<WordCard> _masterData = [
    WordCard(id: '1', text: 'Agile', meaning: '俊敏な / アジャイル開発', category: 'IT'),
    WordCard(
      id: '2',
      text: 'Consensus',
      meaning: '合意 / 総意',
      category: 'Business',
    ),
    WordCard(
      id: '3',
      text: 'Legacy',
      meaning: '遺産 / (IT)古いシステム',
      category: 'IT',
    ),
    WordCard(
      id: '4',
      text: 'Stakeholder',
      meaning: '利害関係者',
      category: 'Business',
    ),
    WordCard(id: '5', text: 'Scalability', meaning: '拡張性', category: 'IT'),
    WordCard(id: '6', text: 'Pivot', meaning: '方向転換', category: 'Startup'),
    WordCard(id: '7', text: 'Disruptive', meaning: '破壊的な', category: 'Startup'),
    WordCard(
      id: '8',
      text: 'Retention',
      meaning: '維持 / 保持率',
      category: 'Marketing',
    ),
  ];

  @override
  Future<List<WordCard>> loadWords() async {
    final prefs = await _prefs;
    String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return List.from(_masterData);
    }

    try {
      List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => WordCard.fromJson(e)).toList();
    } catch (e) {
      print("Error loading data: $e");
      return List.from(_masterData);
    }
  }

  @override
  Future<void> addWord(WordCard newWord) async {
    final currentList = await loadWords();
    currentList.add(newWord);
    await saveWords(currentList);
  }

  @override
  Future<void> saveWords(List<WordCard> words) async {
    final prefs = await _prefs;
    String jsonString = jsonEncode(words.map((w) => w.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> resetData() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }
}
