class Vocabulary {
  // 🔒 Attributs privés
  String _id;
  String _word;
  String _definition;
  String _example;
  DateTime _createdAt;
  String _bookId;
  bool _isSynced;
  String _userId;

  // 🧱 Constructeur
  Vocabulary({
    required String id,
    required String word,
    required String definition,
    required String example,
    required DateTime createdAt,
    required String bookId,
    required bool isSynced,
    required String userId,
  })  : _id = id,
        _word = word,
        _definition = definition,
        _example = example,
        _createdAt = createdAt,
        _bookId = bookId,
        _isSynced = isSynced,
        _userId = userId;

  // 🧩 Getters
  String get id => _id;
  String get word => _word;
  String get definition => _definition;
  String get example => _example;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;
  bool get isSynced => _isSynced;
  String get userId => _userId;

  // ✏️ Setters
  set word(String value) => _word = value;
  set definition(String value) => _definition = value;
  set example(String value) => _example = value;
  set bookId(String value) => _bookId = value;
  set isSynced(bool value) => _isSynced = value;
  set userId(String value) => _userId = value;

  // 🔁 Convertir depuis JSON (lecture depuis Supabase)
  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as String,
      word: json['word'] as String,
      definition: json['definition'] as String,
      example: json['example'],
      createdAt: DateTime.parse(json['created_at'] as String), // ← conversion obligatoire
      bookId: json['book_id'] as String,
      isSynced: json['isSynced'] as bool,
      userId: json['user_id'] as String,
    );
  }


  // 🔁 Convertir vers JSON (insertion dans Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'word': _word,
      'definition': _definition,
      'example': _example,
      'created_at': _createdAt.toIso8601String(),
      'book_id': _bookId,
      'isSynced': _isSynced,
      'user_id': _userId,
    };
  }
}
