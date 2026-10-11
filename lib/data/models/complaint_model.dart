enum ComplaintCategory {
  infrastruktur,
  kebersihan,
  keamanan,
  ketertiban,
  lainnya,
}

extension ComplaintCategoryExtension on ComplaintCategory {
  String get displayName {
    switch (this) {
      case ComplaintCategory.infrastruktur:
        return 'Infrastruktur & Jalan';
      case ComplaintCategory.kebersihan:
        return 'Kebersihan & Sampah';
      case ComplaintCategory.keamanan:
        return 'Keamanan Lingkungan';
      case ComplaintCategory.ketertiban:
        return 'Ketertiban Warga';
      case ComplaintCategory.lainnya:
        return 'Lainnya';
    }
  }
}

enum ComplaintStatus {
  menunggu,
  diproses,
  selesai,
}

extension ComplaintStatusExtension on ComplaintStatus {
  String get label {
    switch (this) {
      case ComplaintStatus.menunggu:
        return 'Menunggu Respon';
      case ComplaintStatus.diproses:
        return 'Sedang Ditindaklanjuti';
      case ComplaintStatus.selesai:
        return 'Selesai Ditangani';
    }
  }
}

class ComplaintItem {
  final String id;
  final String title;
  final String description;
  final ComplaintCategory category;
  final bool isAnonymous;
  final String reporterName;
  final String reporterRt;
  final DateTime createdAt;
  final ComplaintStatus status;
  final String? adminResponse;
  final DateTime? resolvedAt;

  const ComplaintItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isAnonymous,
    required this.reporterName,
    required this.reporterRt,
    required this.createdAt,
    required this.status,
    this.adminResponse,
    this.resolvedAt,
  });

  /// Returns masked name if anonymous to protect resident identity
  String get displayedReporter {
    if (isAnonymous) {
      return 'Warga Anonim ($reporterRt)';
    }
    return '$reporterName ($reporterRt)';
  }

  ComplaintItem copyWith({
    String? id,
    String? title,
    String? description,
    ComplaintCategory? category,
    bool? isAnonymous,
    String? reporterName,
    String? reporterRt,
    DateTime? createdAt,
    ComplaintStatus? status,
    String? adminResponse,
    DateTime? resolvedAt,
  }) {
    return ComplaintItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reporterName: reporterName ?? this.reporterName,
      reporterRt: reporterRt ?? this.reporterRt,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
