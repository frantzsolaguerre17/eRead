class Expression {
  String _id;
  String _expressionText;
  String _definition;
  String _example;
  DateTime _createdAt;
  String _bookId;
  String _userId;
  bool _isFavorite; // ⭐ NOUVEAU

  Expression({
    required String id,
    required String expressionText,
    required String definition,
    required String example,
    required DateTime createdAt,
    required String bookId,
    required String userId,
    bool isFavorite = false,
  })  : _id = id,
        _expressionText = expressionText,
        _definition = definition,
        _example = example,
        _createdAt = createdAt,
        _bookId = bookId,
        _userId = userId,
        _isFavorite = isFavorite;

  // Getters
  String get id => _id;
  String get expressionText => _expressionText;
  String get definition => _definition;
  String get example => _example;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;
  String get userId => _userId;
  bool get isFavorite => _isFavorite;

  // Setters
  set expressionText(String v) => _expressionText = v;
  set definition(String v) => _definition = v;
  set example(String v) => _example = v;
  set isFavorite(bool v) => _isFavorite = v;

  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'],
      expressionText: json['expression_text'],
      definition: json['definition'],
      example: json['example'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      bookId: json['book_id'],
      userId: json['user_id'],
      isFavorite: json['is_favorite'] ?? false, // ⭐
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'expression_text': _expressionText,
      'definition': _definition,
      'example': _example,
      'created_at': _createdAt.toIso8601String(),
      'book_id': _bookId,
      'user_id': _userId,
      'is_favorite': _isFavorite, // ⭐
    };
  }
}
