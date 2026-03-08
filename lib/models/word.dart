enum WordStatus { fresh, learning, mastered }

class WordCard {
  final String id;
  final String text;
  final String meaning;
  final String category;
  final String partOfSpeech;

  final String example;
  final String exampleTranslation;
  final List<String> synonyms;

  WordStatus status;
  int proficiency;

  WordCard({
    required this.id,
    required this.text,
    required this.meaning,
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
    String? meaning,
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
      meaning: meaning ?? this.meaning,
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
    return WordCard(
      id: json['id'],
      text: json['text'],
      meaning: json['meaning'],
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
      'meaning': meaning,
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
