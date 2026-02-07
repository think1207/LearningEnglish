// ----------------------------------------------------------------------
// 1. Data Models (DB設計に基づいた簡易モデル)
// ----------------------------------------------------------------------

enum WordStatus { fresh, learning, mastered }

/*
 * Data Models (The simple model based on DB design)
 */
class WordCard {
  final String id;
  final String text; // English
  final String meaning; // Japanese
  final String category; // Terminology, jargon, etc...

  // Learning State
  WordStatus status;

  // 3 times to the right for counting masters etc.
  int proficiency;

  WordCard({
    required this.id,
    required this.text,
    required this.meaning,
    required this.category,
    this.status = WordStatus.fresh,
    this.proficiency = 0,
  });
}
