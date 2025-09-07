class MeasurementResult {
  final String id;
  final double hemoglobin;
  final DateTime timestamp;
  final String patientId;
  final String? notes;

  MeasurementResult({
    required this.id,
    required this.hemoglobin,
    required this.timestamp,
    required this.patientId,
    this.notes,
  });

  MeasurementStatus get status {
    if (hemoglobin < 8) return MeasurementStatus.severe;
    if (hemoglobin < 10) return MeasurementStatus.moderate;
    if (hemoglobin < 12) return MeasurementStatus.mild;
    return MeasurementStatus.normal;
  }

  MeasurementResult copyWith({
    String? id,
    double? hemoglobin,
    DateTime? timestamp,
    String? patientId,
    String? notes,
  }) {
    return MeasurementResult(
      id: id ?? this.id,
      hemoglobin: hemoglobin ?? this.hemoglobin,
      timestamp: timestamp ?? this.timestamp,
      patientId: patientId ?? this.patientId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hemoglobin': hemoglobin,
      'timestamp': timestamp.toIso8601String(),
      'patientId': patientId,
      'notes': notes,
    };
  }

  factory MeasurementResult.fromJson(Map<String, dynamic> json) {
    return MeasurementResult(
      id: json['id'],
      hemoglobin: json['hemoglobin'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      patientId: json['patientId'],
      notes: json['notes'],
    );
  }
}

enum MeasurementStatus {
  severe,
  moderate,
  mild,
  normal,
}