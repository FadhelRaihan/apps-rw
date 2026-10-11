/// Role enumeration for testing and production authorization.
enum UserRole {
  warga,
  ketuaRt,
  ketuaRw,
  bendaharaRt,
  bendaharaRw,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.warga:
        return 'Warga';
      case UserRole.ketuaRt:
        return 'Ketua RT 02';
      case UserRole.ketuaRw:
        return 'Ketua RW 05';
      case UserRole.bendaharaRt:
        return 'Bendahara RT 02';
      case UserRole.bendaharaRw:
        return 'Bendahara RW 05';
    }
  }

  bool get isPengurus => this != UserRole.warga;
  bool get isRwLevel => this == UserRole.ketuaRw || this == UserRole.bendaharaRw;
  bool get isRtLevel => this == UserRole.ketuaRt || this == UserRole.bendaharaRt;
}

/// Represents the active logged-in user profile.
class UserProfile {
  final String id;
  final String name;
  final String nik;
  final String noKk;
  final String rtNumber;
  final String rwNumber;
  final String phone;
  final String address;
  final UserRole role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.nik,
    required this.noKk,
    required this.rtNumber,
    required this.rwNumber,
    required this.phone,
    required this.address,
    required this.role,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? nik,
    String? noKk,
    String? rtNumber,
    String? rwNumber,
    String? phone,
    String? address,
    UserRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      noKk: noKk ?? this.noKk,
      rtNumber: rtNumber ?? this.rtNumber,
      rwNumber: rwNumber ?? this.rwNumber,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }
}
