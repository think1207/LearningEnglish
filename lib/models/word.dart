enum WordStatus { fresh, learning, mastered }

class WordCard {
  final String id;
  final String text;
  final List<String> meanings; // 配列で意味を保持
  final String category;
  final String partOfSpeech;

  // 例文・類義語
  final String example;
  final String exampleTranslation;
  final List<String> synonyms;

  WordStatus status;
  int proficiency;

  WordCard({
    required this.id,
    required this.text,
    required this.meanings,
    required this.category,
    required this.partOfSpeech,
    this.example = '',
    this.exampleTranslation = '',
    this.synonyms = const [],
    this.status = WordStatus.fresh,
    this.proficiency = 0,
  });

  WordCard copyWith({
    String? id,
    String? text,
    List<String>? meanings,
    String? category,
    String? partOfSpeech,
    String? example,
    String? exampleTranslation,
    List<String>? synonyms,
    WordStatus? status,
    int? proficiency,
  }) {
    return WordCard(
      id: id ?? this.id,
      text: text ?? this.text,
      meanings: meanings ?? this.meanings,
      category: category ?? this.category,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      synonyms: synonyms ?? this.synonyms,
      status: status ?? this.status,
      proficiency: proficiency ?? this.proficiency,
    );
  }

  factory WordCard.fromJson(Map<String, dynamic> json) {
    // --- 後方互換性（古いデータを読み込んだ時のための安全な処理） ---
    List<String> loadedMeanings = [];
    if (json['meanings'] != null) {
      // 新しい配列データが存在する場合
      loadedMeanings = List<String>.from(json['meanings']);
    } else if (json['meaning'] != null) {
      // 古い文字列形式の 'meaning' しか保存されていない場合は、自動で分割して配列化する
      loadedMeanings = (json['meaning'] as String)
          .split(RegExp(r'[/、]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return WordCard(
      id: json['id'],
      text: json['text'],
      meanings: loadedMeanings,
      category: json['category'],
      partOfSpeech: json['partOfSpeech'],
      example: json['example'] ?? '',
      exampleTranslation: json['exampleTranslation'] ?? '',
      synonyms: List<String>.from(json['synonyms'] ?? []),
      status: WordStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => WordStatus.fresh,
      ),
      proficiency: json['proficiency'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'meanings': meanings,
      'category': category,
      'partOfSpeech': partOfSpeech,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'synonyms': synonyms,
      'status': status.toString(),
      'proficiency': proficiency,
    };
  }
}
