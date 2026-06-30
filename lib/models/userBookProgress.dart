class UserBookProgress {
  final String userId;
  final String bookId;
  int readingProgress;
  bool isRead;

  UserBookProgress({
    required this.userId,
    required this.bookId,
    this.readingProgress = 0,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'book_id': bookId,
    'reading_progress': readingProgress,
    'is_read': isRead,
  };

  factory UserBookProgress.fromMap(Map<String, dynamic> map) => UserBookProgress(
    userId: map['user_id'],
    bookId: map['book_id'],
    readingProgress: map['reading_progress'] ?? 0,
    isRead: map['is_read'] ?? false,
  );
}
