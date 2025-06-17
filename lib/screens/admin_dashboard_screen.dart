import 'package:flutter/material.dart';
import '../models/health_record.dart';
import '../services/data_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    // Get statistics
    final petSpeciesCounts = _dataService.getPetSpeciesCount();
    final recordTypeCounts = _dataService.getRecordTypeCounts();
    final totalPets = _dataService.getPets().length;
    final totalRecords = _dataService.getAllHealthRecords().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'System Overview (admin@gmail.com)',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Pets',
                    value: totalPets.toString(),
                    icon: Icons.pets,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Records',
                    value: totalRecords.toString(),
                    icon: Icons.description,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pet distribution
            const Text(
              'Pet Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Species cards
            ...petSpeciesCounts.entries.map((entry) {
              return ListTile(
                leading: _buildSpeciesIcon(entry.key),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value} pet${entry.value != 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),

            const SizedBox(height: 24),
            const Divider(),

            // Record distribution
            const Text(
              'Health Record Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Record type cards
            ...recordTypeCounts.entries.map((entry) {
              return ListTile(
                leading: _buildRecordTypeIcon(entry.key),
                title: Text(_getRecordTypeTitle(entry.key)),
                trailing: Text(
                  '${entry.value} record${entry.value != 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesIcon(String species) {
    return CircleAvatar(
      backgroundColor: _getSpeciesColor(species).withAlpha(40),
      child: Icon(
        _getSpeciesIconData(species),
        color: _getSpeciesColor(species),
      ),
    );
  }

  IconData _getSpeciesIconData(String species) {
    switch (species) {
      case 'Dog':
        return Icons.pets;
      case 'Cat':
        return Icons.catching_pokemon;
      case 'Bird':
        return Icons.flutter_dash;
      default:
        return Icons.pets;
    }
  }

  Color _getSpeciesColor(String species) {
    switch (species) {
      case 'Dog':
        return Colors.blue;
      case 'Cat':
        return Colors.orange;
      case 'Bird':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecordTypeIcon(RecordType type) {
    final color = _getRecordTypeColor(type);
    return CircleAvatar(
      backgroundColor: color.withAlpha(40),
      child: Icon(_getRecordTypeIconData(type), color: color),
    );
  }

  IconData _getRecordTypeIconData(RecordType type) {
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

  String _getRecordTypeTitle(RecordType type) {
    switch (type) {
      case RecordType.vaccination:
        return 'Vaccinations';
      case RecordType.checkup:
        return 'Checkups';
      case RecordType.medication:
        return 'Medications';
      case RecordType.weight:
        return 'Weight Records';
      case RecordType.food:
        return 'Food Logs';
    }
  }
}
