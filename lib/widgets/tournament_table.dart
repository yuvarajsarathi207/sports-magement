import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TournamentTable extends StatelessWidget {
  final List<TournamentTableData> data;
  final VoidCallback? onCreateTap;

  const TournamentTable({
    super.key,
    required this.data,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Tournaments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onCreateTap != null)
                  TextButton.icon(
                    onPressed: onCreateTap,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create New'),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                AppColors.background,
              ),
              columns: const [
                DataColumn(label: Text('Tournament Name')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Start Date')),
                DataColumn(label: Text('Slots')),
                DataColumn(label: Text('Entry Fee')),
                DataColumn(label: Text('Actions')),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.name)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: _getStatusColor(item.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(item.startDate)),
                    DataCell(Text('${item.slots}/${item.totalSlots}')),
                    DataCell(Text('\$${item.entryFee.toStringAsFixed(0)}')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: item.onTap,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.success;
      case 'draft':
        return AppColors.warning;
      case 'ongoing':
        return AppColors.info;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class TournamentTableData {
  final String name;
  final String status;
  final String startDate;
  final int slots;
  final int totalSlots;
  final double entryFee;
  final VoidCallback onTap;

  TournamentTableData({
    required this.name,
    required this.status,
    required this.startDate,
    required this.slots,
    required this.totalSlots,
    required this.entryFee,
    required this.onTap,
  });
}


