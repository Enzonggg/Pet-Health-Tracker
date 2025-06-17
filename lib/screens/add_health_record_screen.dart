import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/health_record.dart';
import '../services/data_service.dart';
import '../utils/snackbar_utils.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final Pet pet;
  final HealthRecord? record; // Null for new records, non-null for editing

  const AddHealthRecordScreen({super.key, required this.pet, this.record});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _veterinarianController = TextEditingController();

  late RecordType _selectedType;
  DateTime _date = DateTime.now();
  DateTime? _nextDueDate;

  final DataService _dataService = DataService();

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // Pre-fill form if editing
      _selectedType = widget.record!.type;
      _date = widget.record!.date;
      _nextDueDate = widget.record!.nextDueDate;
      _descriptionController.text = widget.record!.description;
      _veterinarianController.text = widget.record!.veterinarian;
    } else {
      // Default values for new record
      _selectedType = RecordType.checkup;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _veterinarianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Health Record' : 'Add Health Record'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet info header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withAlpha(40),
                      child: Icon(
                        widget.pet.species == 'Dog'
                            ? Icons.pets
                            : widget.pet.species == 'Cat'
                            ? Icons.catching_pokemon
                            : Icons.flutter_dash,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${widget.pet.species} • ${widget.pet.breed}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Record type dropdown
              const Text(
                'Record Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<RecordType>(
                value: _selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: RecordType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getRecordTypeTitle(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withAlpha(80)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        '${_date.month}/${_date.day}/${_date.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Next due date (for vaccinations)
              if (_selectedType == RecordType.vaccination) ...[
                Row(
                  children: [
                    const Text(
                      'Next Due Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _nextDueDate = _nextDueDate == null
                              ? DateTime.now().add(const Duration(days: 365))
                              : null;
                        });
                      },
                      child: Text(
                        _nextDueDate == null ? 'Add Reminder' : 'Remove',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_nextDueDate != null)
                  GestureDetector(
                    onTap: () => _selectNextDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(80)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_repeat, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            '${_nextDueDate!.month}/${_nextDueDate!.day}/${_nextDueDate!.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ], // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Veterinarian field
              TextFormField(
                controller: _veterinarianController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16), // Record type description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Explicitly using the methods here
                        Icon(
                          _getRecordTypeIcon(_selectedType),
                          color: _getRecordTypeColor(_selectedType),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About ${_getRecordTypeTitle(_selectedType)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Explicitly using the description method
                    Text(_getRecordTypeDescription(_selectedType)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isEditing ? 'Update Record' : 'Add Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectNextDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _nextDueDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  String _getRecordTypeTitle(RecordType type) {
    switch (type) {
      case RecordType.vaccination:
        return 'Vaccination';
      case RecordType.checkup:
        return 'Checkup';
      case RecordType.medication:
        return 'Medication';
      case RecordType.weight:
        return 'Weight Record';
      case RecordType.food:
        return 'Food Log';
    }
  }

  IconData _getRecordTypeIcon(RecordType type) {
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

  Color _getRecordTypeColor(RecordType type) {
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

  String _getRecordTypeDescription(RecordType type) {
    switch (type) {
      case RecordType.vaccination:
        return 'Record vaccinations such as rabies, distemper, or other preventative immunizations. Set reminders for when the next dose is due.';
      case RecordType.checkup:
        return 'Document regular wellness visits, physical examinations, or consultations with your veterinarian.';
      case RecordType.medication:
        return 'Track prescribed medications, treatments, or ongoing therapies for your pet\'s conditions.';
      case RecordType.weight:
        return 'Monitor your pet\'s weight over time to ensure they maintain a healthy body condition.';
      case RecordType.food:
        return 'Log diet changes, special nutritional needs, or feeding schedules for your pet.';
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // Update existing record
        final updatedRecord = HealthRecord(
          id: widget.record!.id,
          petId: widget.pet.id,
          date: _date,
          type: _selectedType,
          description: _descriptionController.text,
          veterinarian: _veterinarianController.text,
          nextDueDate: _nextDueDate,
        );

        _dataService.updateHealthRecord(updatedRecord);

        // Show success message inside phone frame
        showSnackBarInPhoneFrame(
          message: 'Health record updated successfully!',
          backgroundColor: Colors.green,
        );
      } else {
        // Create new record
        // Generate a simple ID (in a real app, this would be handled by the backend)
        final id = DateTime.now().millisecondsSinceEpoch.toString();

        final record = HealthRecord(
          id: id,
          petId: widget.pet.id,
          date: _date,
          type: _selectedType,
          description: _descriptionController.text,
          veterinarian: _veterinarianController.text,
          nextDueDate: _nextDueDate,
        );

        _dataService.addHealthRecord(record);

        // Show success message inside phone frame
        showSnackBarInPhoneFrame(
          message: 'Health record added successfully!',
          backgroundColor: Colors.green,
        );
      }

      Navigator.pop(context);
    }
  }
}
