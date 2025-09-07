import 'package:flutter/material.dart';
import 'package:Nailysis/models/patient_data.dart';
import 'package:Nailysis/widgets/medical_card.dart';
import 'package:Nailysis/theme/app_theme.dart';

class PatientProfile extends StatelessWidget {
  final PatientData patient;
  final bool compact;
  final bool clickable;

  const PatientProfile({
    super.key,
    required this.patient,
    this.compact = false,
    this.clickable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactProfile(context);
    }
    return _buildFullProfile(context);
  }

  Widget _buildCompactProfile(BuildContext context) {
    return MedicalCard(
      color: clickable ? Colors.grey.withOpacity(0.05) : null,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryTeal,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${patient.medicalId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatAge(patient.dateOfBirth),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          if (clickable)
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildFullProfile(BuildContext context) {
    return MedicalCard(
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryTeal,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Medical ID: ${patient.medicalId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatAge(patient.dateOfBirth),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Detailed info
          Column(
            children: [
              _buildInfoRow(Icons.email, 'Email', patient.email),
              _buildInfoRow(Icons.phone, 'Phone', patient.phone),
              _buildInfoRow(Icons.person_outline, 'Gender',
                  _formatGender(patient.gender)),
              _buildInfoRow(Icons.cake, 'Date of Birth',
                  _formatDate(patient.dateOfBirth)),
              if (patient.address != null)
                _buildInfoRow(Icons.location_on, 'Address', patient.address!),
              if (patient.emergencyContact != null)
                _buildInfoRow(Icons.emergency, 'Emergency Contact',
                    patient.emergencyContact!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(String dateOfBirth) {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      final age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        return '${age - 1} years old';
      }
      return '$age years old';
    } catch (e) {
      return 'Age unknown';
    }
  }

  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
}
