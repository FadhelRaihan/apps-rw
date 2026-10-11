enum EmergencyScope {
  rt,
  rw,
}

extension EmergencyScopeExtension on EmergencyScope {
  String get displayName {
    switch (this) {
      case EmergencyScope.rt:
        return 'Skala RT (RT 02 Saja)';
      case EmergencyScope.rw:
        return 'Skala RW (Seluruh Kawasan RW 05)';
    }
  }

  String get coverageDescription {
    switch (this) {
      case EmergencyScope.rt:
        return 'Sirine berbunyi di 38 rumah warga RT 02';
      case EmergencyScope.rw:
        return 'Sirine berbunyi di seluruh 240 rumah warga RW 05';
    }
  }

  int get sirenDeviceCount {
    switch (this) {
      case EmergencyScope.rt:
        return 38;
      case EmergencyScope.rw:
        return 240;
    }
  }
}

class EmergencyAlert {
  final String id;
  final String initiatorName;
  final String initiatorRt;
  final EmergencyScope scope;
  final DateTime triggerTime;
  final String reason;
  final bool isActive;
  final int affectedHousesCount;

  const EmergencyAlert({
    required this.id,
    required this.initiatorName,
    required this.initiatorRt,
    required this.scope,
    required this.triggerTime,
    required this.reason,
    required this.isActive,
    required this.affectedHousesCount,
  });

  EmergencyAlert copyWith({
    String? id,
    String? initiatorName,
    String? initiatorRt,
    EmergencyScope? scope,
    DateTime? triggerTime,
    String? reason,
    bool? isActive,
    int? affectedHousesCount,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      initiatorName: initiatorName ?? this.initiatorName,
      initiatorRt: initiatorRt ?? this.initiatorRt,
      scope: scope ?? this.scope,
      triggerTime: triggerTime ?? this.triggerTime,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
      affectedHousesCount: affectedHousesCount ?? this.affectedHousesCount,
    );
  }
}
