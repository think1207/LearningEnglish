import '../models/word.dart';

abstract class BaseWordRepository {
  Future<List<WordCard>> loadWords();

  Future<void> addWord(WordCard newWord);

  Future<void> saveWords(List<WordCard> words);

  Future<void> resetData();
}
