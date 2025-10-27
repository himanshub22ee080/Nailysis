class PatientData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String medicalId;
  final String? address;
  final String? emergencyContact;

  PatientData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.medicalId,
    this.address,
    this.emergencyContact,
  });

  String get fullName => '$firstName $lastName';

  PatientData copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? medicalId,
    String? address,
    String? emergencyContact,
  }) {
    return PatientData(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      medicalId: medicalId ?? this.medicalId,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'medicalId': medicalId,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      medicalId: json['medicalId'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
    );
  }

  // Convert from Supabase row (uses snake_case column names)
  factory PatientData.fromMap(Map<String, dynamic> map) {
    return PatientData(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      dateOfBirth: map['dob'] as String,
      gender: map['gender'] as String,
      medicalId: map['medical_id'] as String,
      address: map['address'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
    );
  }

  // Convert to Supabase row format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'dob': dateOfBirth,
      'gender': gender,
      'medical_id': medicalId,
      'address': address,
      'emergency_contact': emergencyContact,
    };
  }
}
