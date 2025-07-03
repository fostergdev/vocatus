import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceRecords;

  const AttendancePage({super.key, required this.attendanceRecords});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Presença',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, 
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha:0.9), 
                colorScheme.primary, 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary), 
      ),
      body: attendanceRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined, 
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro de presença encontrado.',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant, 
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifique as chamadas ou os filtros de relatório.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0), 
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                return _buildAttendanceItem(attendanceRecords[index], colorScheme, textTheme); 
              },
            ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> record, ColorScheme colorScheme, TextTheme textTheme) {
    final String status = record['status']?.toString() ?? 'N';
    final String rawDate = record['date']?.toString() ?? '';
    
    if (rawDate.isEmpty) return const SizedBox.shrink();
    
    final DateTime date = DateTime.parse(rawDate);
    final String content = record['content']?.toString() ?? '';
    
    
    Color thematicStatusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'P') {
      thematicStatusColor = colorScheme.tertiary; 
      statusText = 'Presente';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'A') {
      thematicStatusColor = colorScheme.error; 
      statusText = 'Ausente';
      statusIcon = Icons.cancel_rounded;
    } else {
      thematicStatusColor = colorScheme.onSurfaceVariant; 
      statusText = 'N/A';
      statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), 
      elevation: 2,
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.primaryContainer, 
      child: ListTile(
        leading: Icon(
          statusIcon,
          color: thematicStatusColor, 
        ),
        title: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface), 
        ),
        subtitle: content.isNotEmpty
            ? Text(
                content,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: thematicStatusColor.withValues(alpha:0.1), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: thematicStatusColor, width: 1.0), 
          ),
          child: Text(
            statusText,
            style: textTheme.labelLarge?.copyWith( 
              color: thematicStatusColor, 
              fontWeight: FontWeight.w600,
              fontSize: 12, 
            ),
          ),
        ),
      ),
    );
  }
}