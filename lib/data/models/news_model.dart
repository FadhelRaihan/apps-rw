enum NewsCategory {
  pengumuman,
  agenda,
  galeri,
}

extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.pengumuman:
        return 'Pengumuman';
      case NewsCategory.agenda:
        return 'Agenda Kegiatan';
      case NewsCategory.galeri:
        return 'Galeri Foto';
    }
  }
}

enum NewsStatus {
  pending,
  published,
  rejected,
}

class NewsItem {
  final String id;
  final String title;
  final String content;
  final NewsCategory category;
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final NewsStatus status;
  final String? imageUrl;
  final DateTime? eventDate;
  final String? location;

  const NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    this.status = NewsStatus.published,
    this.imageUrl,
    this.eventDate,
    this.location,
  });

  NewsItem copyWith({
    String? id,
    String? title,
    String? content,
    NewsCategory? category,
    String? authorName,
    String? authorRole,
    DateTime? createdAt,
    NewsStatus? status,
    String? imageUrl,
    DateTime? eventDate,
    String? location,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
    );
  }
}
