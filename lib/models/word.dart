enum WordStatus { fresh, learning, mastered }

class WordCard {
  final String id;
  final String text;
  final String meaning;
  final String category;

  WordStatus status;
  int proficiency;

  WordCard({
    required this.id,
    required this.text,
    required this.meaning,
    required this.category,
    this.status = WordStatus.fresh,
    this.proficiency = 0,
  });

  WordCard copyWith({
    String? id,
    String? text,
    String? meaning,
    String? category,
    WordStatus? status,
    int? proficiency,
  }) {
    return WordCard(
      id: id ?? this.id,
      text: text ?? this.text,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
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
      'status': status.toString(),
      'proficiency': proficiency,
    };
  }
}
