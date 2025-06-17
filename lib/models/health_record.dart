import 'package:flutter/material.dart';

class HealthRecord {
  String id;
  String petId;
  DateTime date;
  RecordType type;
  String description;
  String veterinarian;
  DateTime? nextDueDate;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.type,
    required this.description,
    this.veterinarian = '',
    this.nextDueDate,
  });

  // For demo purposes - factory method to create sample records
  factory HealthRecord.sample(String id, String petId, RecordType type) {
    return HealthRecord(
      id: id,
      petId: petId,
      date: DateTime.now().subtract(Duration(days: int.parse(id) * 30)),
      type: type,
      description: _getSampleDescription(type),
      veterinarian: 'Dr. Smith',
      nextDueDate: type == RecordType.vaccination
          ? DateTime.now().add(const Duration(days: 365))
          : null,
    );
  }

  static String _getSampleDescription(RecordType type) {
    switch (type) {
      case RecordType.vaccination:
        return 'Annual rabies vaccination';
      case RecordType.checkup:
        return 'Regular wellness exam';
      case RecordType.medication:
        return 'Prescribed flea treatment';
      case RecordType.weight:
        return 'Weight check - stable';
      case RecordType.food:
        return 'Changed to premium diet food';
    }
  }

  // Get icon for the record type
  IconData getIcon() {
    switch (type) {
      case RecordType.vaccination:
        return Icons.vaccines;
      case RecordType.checkup:
        return Icons.health_and_safety;
      case RecordType.medication:
        return Icons.medication;
      case RecordType.weight:
        return Icons.monitor_weight;
      case RecordType.food:
        return Icons.food_bank;
    }
  }

  // Get color for the record type
  Color getColor() {
    switch (type) {
      case RecordType.vaccination:
        return Colors.blue;
      case RecordType.checkup:
        return Colors.green;
      case RecordType.medication:
        return Colors.red;
      case RecordType.weight:
        return Colors.orange;
      case RecordType.food:
        return Colors.purple;
    }
  }
}

enum RecordType { vaccination, checkup, medication, weight, food }
