import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/user.dart';

// Simulates a data service that would normally connect to a backend
class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // In-memory data storage (would be replaced with real database in production)
  final Map<String, User> _users = {};
  final Map<String, Pet> _pets = {};
  final Map<String, HealthRecord> _healthRecords = {};
  User? _currentUser;
  // Initialize with only admin user
  void initialize() {
    // Create admin user only
    final adminUser = User(
      id: 'admin',
      name: 'Admin User',
      email: 'admin@gmail.com',
      role: UserRole.admin,
    );

    _users[adminUser.id] = adminUser;
  }

  // Register a new user
  bool register(String name, String email, String password) {
    // Check if email already exists
    final existingUser = _users.values.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (existingUser) {
      return false; // Email already in use
    }

    // Create a new user ID
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Create and store the new user
    final newUser = User(
      id: userId,
      name: name,
      email: email,
      role: UserRole.user,
    );

    _users[userId] = newUser;

    // Log in as the newly created user
    _currentUser = newUser;

    return true;
  } // Authentication methods

  bool login(String email, String password) {
    // Admin login with fixed credentials
    if (email.toLowerCase() == 'admin@gmail.com' && password == 'admin123') {
      // Find the admin user
      User? adminUser = _users.values.firstWhere(
        (user) => user.role == UserRole.admin,
        orElse: () => User(
          id: 'admin',
          name: 'Admin User',
          email: 'admin@gmail.com',
          role: UserRole.admin,
        ),
      );

      _users[adminUser.id] = adminUser;
      _currentUser = adminUser;
      return true;
    }

    // Regular user login - requires registration
    try {
      final user = _users.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );

      // In a real app, we would check the password hash here
      // For demo purposes, we're just checking the email
      _currentUser = user;
      return true;
    } catch (e) {
      // User not found
      return false;
    }
  }

  void logout() {
    _currentUser = null;
  }

  User? get currentUser => _currentUser;

  // Pet management methods
  List<Pet> getPets() {
    if (_currentUser == null) return [];

    if (_currentUser!.isAdmin) {
      // Admins can see all pets
      return _pets.values.toList();
    } else {
      // Regular users only see their own pets
      return _pets.values
          .where((pet) => pet.ownerId == _currentUser!.id)
          .toList();
    }
  }

  Pet? getPet(String id) {
    return _pets[id];
  }

  void addPet(Pet pet) {
    _pets[pet.id] = pet;
  }

  void updatePet(Pet pet) {
    _pets[pet.id] = pet;
  }

  void deletePet(String id) {
    _pets.remove(id);

    // Also remove associated health records
    _healthRecords.removeWhere((key, record) => record.petId == id);
  }

  // Health record management methods
  List<HealthRecord> getHealthRecords(String petId) {
    return _healthRecords.values
        .where((record) => record.petId == petId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  List<HealthRecord> getAllHealthRecords() {
    return _healthRecords.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void addHealthRecord(HealthRecord record) {
    _healthRecords['${record.petId}_${record.id}'] = record;
  }

  void updateHealthRecord(HealthRecord record) {
    _healthRecords['${record.petId}_${record.id}'] = record;
  }

  void deleteHealthRecord(String petId, String recordId) {
    _healthRecords.remove('${petId}_$recordId');
  }

  // Get upcoming vaccinations/reminders
  List<HealthRecord> getUpcomingReminders() {
    final now = DateTime.now();

    return _healthRecords.values
        .where(
          (record) =>
              record.nextDueDate != null &&
              record.nextDueDate!.isAfter(now) &&
              record.nextDueDate!.isBefore(now.add(const Duration(days: 30))),
        )
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  // Statistics methods (for admin dashboard)
  Map<String, int> getPetSpeciesCount() {
    final counts = <String, int>{};

    for (final pet in _pets.values) {
      counts[pet.species] = (counts[pet.species] ?? 0) + 1;
    }

    return counts;
  }

  Map<RecordType, int> getRecordTypeCounts() {
    final counts = <RecordType, int>{};

    for (final record in _healthRecords.values) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }

    return counts;
  }
}
