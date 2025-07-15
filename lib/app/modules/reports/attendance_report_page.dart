import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import './reports_controller.dart';

class AttendanceReportPage extends GetView<ReportsController> {
  const AttendanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            controller.classe.value.name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          );
        }),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        if (controller.isLoadingAttendanceGrid.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.attendanceStudentsData.isEmpty) {
          return const Center(
            child: Text('Nenhum dado de presença encontrado.'),
          );
        } else {
          final attendanceDataSource = AttendanceDataSource(
            studentsData: controller.attendanceStudentsData,
            sessions: controller.attendanceSessions,
          );
          return SfDataGrid(
            source: attendanceDataSource,
            columnWidthMode: ColumnWidthMode.auto,
            frozenColumnsCount: 1,
            columns: <GridColumn>[
              GridColumn(
                columnName: 'name',
                width: 150,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Aluno',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              for (var session in controller.attendanceSessions)
                GridColumn(
                  columnName: session['attendance_id'].toString(),
                  width: 80,
                  label: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd/MM').format(DateTime.parse(session['date'])),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          session['start_time']?.substring(0, 5) ?? '',
                          style: const TextStyle(fontSize: 8),
                        ),
                        Text(
                          session['discipline_name']?.substring(0, 3) ?? '',
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              GridColumn(
                columnName: 'content',
                width: 250, // Adjust width as needed
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Conteúdo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
          );
        }
      }),
    );
  }
}

class AttendanceDataSource extends DataGridSource {
  late List<DataGridRow> _attendanceData;

  AttendanceDataSource({
    required List<Map<String, dynamic>> studentsData,
    required List<Map<String, dynamic>> sessions,
  }) {
    _attendanceData = List.generate(studentsData.length, (int studentIndex) {
      final student = studentsData[studentIndex];

      // Células de presença
      final List<DataGridCell> cells = [
        DataGridCell<String>(columnName: 'name', value: student['name'] as String),
        ...sessions.map((session) {
          final attendanceId = session['attendance_id'].toString();
          return DataGridCell<String>(
            columnName: attendanceId,
            value: student[attendanceId] as String? ?? '-',
          );
        }).toList(),
      ];

      // Célula de conteúdo
      String contentValue = '-';
      if (studentIndex < sessions.length) {
        final session = sessions[studentIndex];
        final date = DateFormat('dd/MM').format(DateTime.parse(session['date']));
        final content = session['content'] as String? ?? 'Sem conteúdo';
        contentValue = '$date - $content';
      }

      cells.add(DataGridCell<String>(columnName: 'content', value: contentValue));

      return DataGridRow(cells: cells);
    });
  }

  @override
  List<DataGridRow> get rows => _attendanceData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: (cell.columnName == 'name' || cell.columnName == 'content')
              ? Alignment.centerLeft
              : Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell.value.toString(),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}