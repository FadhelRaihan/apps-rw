class FamilyMember {
  final String nik;
  final String name;
  final String relation; // Kepala Keluarga, Istri, Anak, Orang Tua, dll.
  final String gender; // Laki-laki / Perempuan
  final String birthDate;
  final String occupation;
  final bool isVerified;

  const FamilyMember({
    required this.nik,
    required this.name,
    required this.relation,
    required this.gender,
    required this.birthDate,
    required this.occupation,
    this.isVerified = true,
  });

  FamilyMember copyWith({
    String? nik,
    String? name,
    String? relation,
    String? gender,
    String? birthDate,
    String? occupation,
    bool? isVerified,
  }) {
    return FamilyMember(
      nik: nik ?? this.nik,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      occupation: occupation ?? this.occupation,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class FamilyCard {
  final String noKk;
  final String headOfFamilyName;
  final String address;
  final String rtNumber;
  final String rwNumber;
  final List<FamilyMember> members;

  const FamilyCard({
    required this.noKk,
    required this.headOfFamilyName,
    required this.address,
    required this.rtNumber,
    required this.rwNumber,
    required this.members,
  });

  FamilyCard copyWith({
    String? noKk,
    String? headOfFamilyName,
    String? address,
    String? rtNumber,
    String? rwNumber,
    List<FamilyMember>? members,
  }) {
    return FamilyCard(
      noKk: noKk ?? this.noKk,
      headOfFamilyName: headOfFamilyName ?? this.headOfFamilyName,
      address: address ?? this.address,
      rtNumber: rtNumber ?? this.rtNumber,
      rwNumber: rwNumber ?? this.rwNumber,
      members: members ?? this.members,
    );
  }
}
