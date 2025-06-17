import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/health_record.dart';
import '../services/data_service.dart';
import '../utils/snackbar_utils.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  List<Pet> _pets = [];
  List<HealthRecord> _upcomingReminders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _pets = _dataService.getPets();
      _upcomingReminders = _dataService.getUpcomingReminders();
    });
  }

  void _deletePet(Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pet'),
          content: Text(
            'Are you sure you want to delete ${pet.name}? This will also delete all associated health records.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dataService.deletePet(pet.id);
                _loadData();
                showSnackBarInPhoneFrame(
                  message: 'Pet ${pet.name} deleted successfully',
                  backgroundColor: Colors.red,
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _dataService.currentUser;
    final isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Health Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () {
                navigatorKey.currentState
                    ?.pushNamed('/admin_dashboard')
                    .then((_) => _loadData());
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _dataService.logout();
              widget.onNavigate('/login');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User welcome
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withAlpha(40),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    currentUser?.name.substring(0, 1) ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${currentUser?.name ?? 'User'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAdmin ? 'Admin Account' : 'User Account',
                        style: TextStyle(
                          fontSize: 14,
                          color: isAdmin ? Colors.purple : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reminders section
          if (_upcomingReminders.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Upcoming Reminders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminders view not implemented yet'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _upcomingReminders.length > 3
                    ? 3
                    : _upcomingReminders.length,
                itemBuilder: (context, index) {
                  final reminder = _upcomingReminders[index];
                  final pet = _dataService.getPet(reminder.petId);

                  return Card(
                    color: Colors.orange.withAlpha(40),
                    margin: const EdgeInsets.only(right: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet?.name ?? 'Unknown Pet',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            reminder.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Due: ${_formatDate(reminder.nextDueDate!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Pets section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.pets, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Your Pets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    navigatorKey.currentState
                        ?.pushNamed('/add_pet')
                        .then((_) => _loadData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Pet'),
                ),
              ],
            ),
          ),

          // Pet list
          Expanded(
            child: _pets.isEmpty
                ? const Center(
                    child: Text(
                      'No pets added yet. Add your first pet!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _pets.length,
                    itemBuilder: (context, index) {
                      final pet = _pets[index];
                      final currentUser = _dataService.currentUser;
                      final canDelete =
                          currentUser?.isAdmin == true ||
                          pet.ownerId == currentUser?.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.withAlpha(40),
                            child: Icon(
                              pet.species == 'Dog'
                                  ? Icons.pets
                                  : pet.species == 'Cat'
                                  ? Icons.catching_pokemon
                                  : Icons.flutter_dash,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} • ${pet.breed} • ${pet.getAge()}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canDelete)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deletePet(pet),
                                  tooltip: 'Delete Pet',
                                ),
                              const Icon(Icons.arrow_forward_ios_rounded),
                            ],
                          ),
                          onTap: () {
                            navigatorKey.currentState
                                ?.pushNamed('/pet_detail', arguments: pet)
                                .then((_) => _loadData());
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
