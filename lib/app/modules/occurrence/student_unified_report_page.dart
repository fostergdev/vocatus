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
            color: colorScheme.onPrimary, // Texto da AppBar
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Usa a cor primária do tema
                colorScheme.primary, // Usa a cor primária do tema
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
      ),
      body: attendanceRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined, // Ícone mais relevante
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do tema
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro de presença encontrado.',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant, // Cor do texto
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifique as chamadas ou os filtros de relatório.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do texto
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0), // Adicionado padding
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                return _buildAttendanceItem(attendanceRecords[index], colorScheme, textTheme); // Passa colorscheme e texttheme
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
    
    // Mapeando status para cores do ColorScheme
    Color thematicStatusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'P') {
      thematicStatusColor = colorScheme.tertiary; // Geralmente verde para "Presente"
      statusText = 'Presente';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'A') {
      thematicStatusColor = colorScheme.error; // Vermelho para "Ausente"
      statusText = 'Ausente';
      statusIcon = Icons.cancel_rounded;
    } else {
      thematicStatusColor = colorScheme.onSurfaceVariant; // Cor neutra para "N/A"
      statusText = 'N/A';
      statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Padding horizontal
      elevation: 2,
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      child: ListTile(
        leading: Icon(
          statusIcon,
          color: thematicStatusColor, // Cor do ícone de status
        ),
        title: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface), // Estilo do título
        ),
        subtitle: content.isNotEmpty
            ? Text(
                content,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Estilo do subtítulo
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: thematicStatusColor.withOpacity(0.1), // Fundo suave da cor do status
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: thematicStatusColor, width: 1.0), // Borda com a cor do status
          ),
          child: Text(
            statusText,
            style: textTheme.labelLarge?.copyWith( // Usar labelLarge
              color: thematicStatusColor, // Cor do texto do status
              fontWeight: FontWeight.w600,
              fontSize: 12, // Mantendo o tamanho original
            ),
          ),
        ),
      ),
    );
  }
}