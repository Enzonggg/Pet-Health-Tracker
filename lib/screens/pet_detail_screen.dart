import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/health_record.dart';
import '../services/data_service.dart';
import '../utils/snackbar_utils.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  List<HealthRecord> _healthRecords = [];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      // This forces a rebuild when tab changes to update the FAB visibility
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadHealthRecords() {
    setState(() {
      _healthRecords = _dataService.getHealthRecords(widget.pet.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Health Records'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: 'Print Report',
          ),
          // Show delete option only if user owns the pet or is admin
          if (_canDeletePet())
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deletePet();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Pet', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(), _buildHealthRecordsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // If on health records tab, add health record; otherwise do nothing
          if (_tabController.index == 1) {
            navigatorKey.currentState
                ?.pushNamed('/add_health_record', arguments: widget.pet)
                .then((_) => _loadHealthRecords());
          }
        },
        backgroundColor: _tabController.index == 1 ? Colors.blue : Colors.grey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet avatar and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.pet.species == 'Dog'
                      ? Icons.pets
                      : widget.pet.species == 'Cat'
                      ? Icons.catching_pokemon
                      : Icons.flutter_dash,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),

              // Basic pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pet.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.pet.species} • ${widget.pet.breed}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip('Age: ${widget.pet.getAge()}'),
                    _buildInfoChip('Weight: ${widget.pet.weight} kg'),
                    _buildInfoChip('Gender: ${widget.pet.gender}'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Pet statistics
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Health Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildStatTile(
            title: 'Vaccinations',
            count: _healthRecords
                .where((record) => record.type == RecordType.vaccination)
                .length,
            icon: Icons.vaccines,
            color: Colors.blue,
          ),

          _buildStatTile(
            title: 'Checkups',
            count: _healthRecords
                .where((record) => record.type == RecordType.checkup)
                .length,
            icon: Icons.health_and_safety,
            color: Colors.green,
          ),

          _buildStatTile(
            title: 'Medications',
            count: _healthRecords
                .where((record) => record.type == RecordType.medication)
                .length,
            icon: Icons.medication,
            color: Colors.red,
          ),

          _buildStatTile(
            title: 'Weight Records',
            count: _healthRecords
                .where((record) => record.type == RecordType.weight)
                .length,
            icon: Icons.monitor_weight,
            color: Colors.orange,
          ),

          _buildStatTile(
            title: 'Food Logs',
            count: _healthRecords
                .where((record) => record.type == RecordType.food)
                .length,
            icon: Icons.food_bank,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  Widget _buildStatTile({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(40),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHealthRecordsTab() {
    if (_healthRecords.isEmpty) {
      return const Center(
        child: Text(
          'No health records yet. Add your first record!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _healthRecords.length,
      itemBuilder: (context, index) {
        final record = _healthRecords[index];
        final currentUser = _dataService.currentUser;
        final canDelete =
            currentUser?.isAdmin == true ||
            widget.pet.ownerId == currentUser?.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: record.getColor().withAlpha(100), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: record.getColor().withAlpha(40),
                      child: Icon(record.getIcon(), color: record.getColor()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getRecordTypeTitle(record.type),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatDate(record.date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _deleteHealthRecord(record),
                        tooltip: 'Delete Record',
                      ),
                    if (record.nextDueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Next: ${_formatDate(record.nextDueDate!)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(record.description),
                if (record.veterinarian.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Veterinarian: ${record.veterinarian}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteHealthRecord(HealthRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Health Record'),
          content: Text(
            'Are you sure you want to delete this ${_getRecordTypeTitle(record.type).toLowerCase()} record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dataService.deleteHealthRecord(widget.pet.id, record.id);
                _loadHealthRecords();
                showSnackBarInPhoneFrame(
                  message: 'Health record deleted successfully',
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

  bool _canDeletePet() {
    final currentUser = _dataService.currentUser;
    return currentUser?.isAdmin == true ||
        widget.pet.ownerId == currentUser?.id;
  }

  void _deletePet() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pet'),
          content: Text(
            'Are you sure you want to delete ${widget.pet.name}? This will also delete all associated health records and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dataService.deletePet(widget.pet.id);
                showSnackBarInPhoneFrame(
                  message: 'Pet ${widget.pet.name} deleted successfully',
                  backgroundColor: Colors.red,
                );
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _printReport() {
    // In a real app, this would generate a PDF report
    showSnackBarInPhoneFrame(
      message: 'Generating health report for vet...',
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 2),
    );

    // Simulate printing with a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showSnackBarInPhoneFrame(
          message: 'Health report exported successfully!',
          backgroundColor: Colors.green,
        );
      }
    });
  }
}
