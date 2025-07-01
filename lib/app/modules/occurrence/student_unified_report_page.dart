import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceRecords;

  const AttendancePage({super.key, required this.attendanceRecords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Presença'),
      ),
      body: ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          return _buildAttendanceItem(attendanceRecords[index]);
        },
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> record) {
    final String status = record['status']?.toString() ?? 'N';
    final String rawDate = record['date']?.toString() ?? '';
    if (rawDate.isEmpty) return const SizedBox.shrink();
    
    final DateTime date = DateTime.parse(rawDate);
    final String content = record['content']?.toString() ?? '';
    
    // Lógica corrigida: P = Presente, A = Ausente
    Color statusColor = status == 'P' ? Colors.green : 
                       status == 'A' ? Colors.red : Colors.grey;
    String statusText = status == 'P' ? 'Presente' : 
                       status == 'A' ? 'Ausente' : 'N/A';
    IconData statusIcon = status == 'P' ? Icons.check_circle : 
                         status == 'A' ? Icons.cancel : Icons.help;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          statusIcon,
          color: statusColor,
        ),
        title: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: content.isNotEmpty ? Text(content) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}