import '../models/word.dart';

abstract class BaseWordRepository {
  Future<List<WordCard>> loadWords();
  Future<void> saveWords(List<WordCard> words);
  Future<void> resetData();
}
