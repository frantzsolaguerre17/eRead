class Book {
  String _id;
  String _title;
  String _author;
  String _number_of_pages;
  DateTime _createdAt;
  bool _isSynced;
  String _cover;
  String _pdf;
  String _userId;
  String _category;
  String? _user_name;

  // Nouveaux champs
  int _readingProgress; // 0..100
  bool _isRead;

  Book({
    required String id,
    required String title,
    required String author,
    required String number_of_pages,
    required DateTime createdAt,
    required bool isSynced,
    required String cover,
    required String pdf,
    required String userId,
    required String category,
    String? user_name,
    int readingProgress = 0,
    bool isRead = false,
  })  : _id = id,
        _title = title,
        _author = author,
        _number_of_pages = number_of_pages,
        _createdAt = createdAt,
        _isSynced = isSynced,
        _cover = cover,
        _pdf = pdf,
        _userId = userId,
        _category = category,
        _user_name = user_name,
        _readingProgress = readingProgress,
        _isRead = isRead;

  // getters
  String get id => _id;
  String get title => _title;
  String get author => _author;
  String get number_of_pages => _number_of_pages;
  DateTime get createdAt => _createdAt;
  bool get isSynced => _isSynced;
  String get cover => _cover;
  String get pdf => _pdf;
  String get userId => _userId;
  String get category => _category;
  String? get user_name => _user_name;
  int get readingProgress => _readingProgress;
  bool get isRead => _isRead;

  // setters si besoin
  set readingProgress(int v) => _readingProgress = v;
  set isRead(bool v) => _isRead = v;

  // fromJson
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      number_of_pages: (json['number_of_pages'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      cover: json['cover'] as String? ?? '',
      pdf: json['pdf'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      category: json['category'] as String? ?? 'Autre',
      user_name: json['user_name'] as String? ?? json['username'] as String? ?? 'Inconnu',
      readingProgress: (json['reading_progress'] is int) ? json['reading_progress'] as int : int.tryParse((json['reading_progress'] ?? '0').toString()) ?? 0,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'author': _author,
      'number_of_pages': _number_of_pages,
      'created_at': _createdAt.toIso8601String(),
      'isSynced': _isSynced,
      'cover': _cover,
      'pdf': _pdf,
      'user_id': _userId,
      'category': _category,
      'user_name': _user_name,
      'reading_progress': _readingProgress,
      'is_read': _isRead,
    };
  }
}
