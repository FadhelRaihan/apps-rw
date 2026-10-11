enum LetterType {
  pengantarRtRw,
  keteranganDomisili,
  keteranganUsaha,
  keteranganTidakMampu,
}

extension LetterTypeExtension on LetterType {
  String get displayName {
    switch (this) {
      case LetterType.pengantarRtRw:
        return 'Surat Pengantar RT/RW';
      case LetterType.keteranganDomisili:
        return 'Surat Keterangan Domisili';
      case LetterType.keteranganUsaha:
        return 'Surat Keterangan Usaha';
      case LetterType.keteranganTidakMampu:
        return 'Surat Keterangan Tidak Mampu (SKTM)';
    }
  }

  String get defaultDescription {
    switch (this) {
      case LetterType.pengantarRtRw:
        return 'Untuk pengurusan KTP, KK, SKCK, atau keperluan dinas kependudukan.';
      case LetterType.keteranganDomisili:
        return 'Bukti resmi tempat tinggal warga di lingkungan RW 05.';
      case LetterType.keteranganUsaha:
        return 'Keterangan izin/keberadaan unit usaha mikro di wilayah RT/RW.';
      case LetterType.keteranganTidakMampu:
        return 'Pengantar pengajuan bantuan sosial atau beasiswa pendidikan.';
    }
  }
}

enum LetterStatus {
  diajukan, // Submitted by resident, awaiting RT verification
  diverifikasiRt, // Verified by RT, awaiting RW approval
  disetujuiRw, // Approved by RW, finished and valid
  ditolak,
}

extension LetterStatusExtension on LetterStatus {
  String get label {
    switch (this) {
      case LetterStatus.diajukan:
        return 'Menunggu Verifikasi RT';
      case LetterStatus.diverifikasiRt:
        return 'Menunggu Persetujuan RW';
      case LetterStatus.disetujuiRw:
        return 'Selesai & Disetujui';
      case LetterStatus.ditolak:
        return 'Ditolak';
    }
  }

  int get stepIndex {
    switch (this) {
      case LetterStatus.diajukan:
        return 1;
      case LetterStatus.diverifikasiRt:
        return 2;
      case LetterStatus.disetujuiRw:
        return 3;
      case LetterStatus.ditolak:
        return 0;
    }
  }
}

class LetterRequest {
  final String id;
  final LetterType letterType;
  final String residentName;
  final String nik;
  final String rtNumber;
  final String rwNumber;
  final String purpose;
  final DateTime requestDate;
  final LetterStatus status;
  final String? qrCodeVerification;
  final String? rejectionReason;
  final DateTime? approvedByRtAt;
  final DateTime? approvedByRwAt;

  const LetterRequest({
    required this.id,
    required this.letterType,
    required this.residentName,
    required this.nik,
    required this.rtNumber,
    required this.rwNumber,
    required this.purpose,
    required this.requestDate,
    required this.status,
    this.qrCodeVerification,
    this.rejectionReason,
    this.approvedByRtAt,
    this.approvedByRwAt,
  });

  LetterRequest copyWith({
    String? id,
    LetterType? letterType,
    String? residentName,
    String? nik,
    String? rtNumber,
    String? rwNumber,
    String? purpose,
    DateTime? requestDate,
    LetterStatus? status,
    String? qrCodeVerification,
    String? rejectionReason,
    DateTime? approvedByRtAt,
    DateTime? approvedByRwAt,
  }) {
    return LetterRequest(
      id: id ?? this.id,
      letterType: letterType ?? this.letterType,
      residentName: residentName ?? this.residentName,
      nik: nik ?? this.nik,
      rtNumber: rtNumber ?? this.rtNumber,
      rwNumber: rwNumber ?? this.rwNumber,
      purpose: purpose ?? this.purpose,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      qrCodeVerification: qrCodeVerification ?? this.qrCodeVerification,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedByRtAt: approvedByRtAt ?? this.approvedByRtAt,
      approvedByRwAt: approvedByRwAt ?? this.approvedByRwAt,
    );
  }
}
