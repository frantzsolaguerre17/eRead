class Expression {
  // 🔒 Attributs privés
  String _id;
  String _expressionText;
  String _definition;
  String _example;
  DateTime _createdAt;
  String _bookId;
  String _userId;
  bool _isFavorite;

  // 🧱 Constructeur
  Expression({
    required String id,
    required String expressionText,
    required String definition,
    required String example,
    required DateTime createdAt,
    required String bookId,
    required String userId,
    required bool isFavorite,
  })  : _id = id,
        _expressionText = expressionText,
        _definition = definition,
        _example = example,
        _createdAt = createdAt,
        _bookId = bookId,
        _userId = userId,
       _isFavorite = isFavorite;

  // 🧩 Getters
  String get id => _id;
  String get expressionText => _expressionText;
  String get definition => _definition;
  String get example => _example;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;
  String get userId => _userId;
  bool get isFavorite => _isFavorite;

  // ✏️ Setters
  set expressionText(String value) => _expressionText = value;
  set definition(String value) => _definition = value;
  set example(String value) => _example = value;
  set bookId(String value) => _bookId = value;
  set userId(String value) => _userId = value;
  set isFavorite(bool value) => _isFavorite = value;

  // 🔁 Convertir depuis JSON (lecture depuis Supabase)
  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'] as String,
      expressionText: json['expression_text'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      createdAt: DateTime.parse(json['created_at']),
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  // 🔁 Convertir vers JSON (insertion dans Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'expression_text': _expressionText,
      'definition': _definition,
      'example': _example,
      'created_at': _createdAt?.toIso8601String(),
      'book_id': _bookId,
      'user_id': _userId,
      'is_favorite': _isFavorite, // ⭐ Export favori
    };
  }
}
