import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AttendanceReportPage extends GetView<ReportsController> {
  final int classId;
  final String className;

  const AttendanceReportPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAttendanceReport(classId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório Chamadas',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor.withValues(alpha: .9),
                Constants.primaryColor,
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingAttendance.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.attendanceReportData.isEmpty) {
          return const Center(
            child: Text('Nenhum dado de chamada encontrado para esta turma.'),
          );
        } else {
          final Map<String, Map<String, dynamic>> classesByDay = {};
          final Set<String> allStudentsNames = {};

          for (var record in controller.attendanceReportData) {
            final String rawDate = record['date'] as String;
            final String formattedDate = DateFormat(
              'dd/MM',
            ).format(DateTime.parse(rawDate));
            final String studentName = record['student_name'] as String;
            final String status = record['status'] as String;
            final String content = record['content'] as String? ?? '';

            if (!classesByDay.containsKey(formattedDate)) {
              classesByDay[formattedDate] = {
                'attendance_date': rawDate,
                'attendance_content': content,
                'students': [],
              };
            }
            classesByDay[formattedDate]!['students'].add({
              'student_name': studentName,
              'status': status,
            });

            allStudentsNames.add(studentName);
          }

          final List<String> sortedDays = classesByDay.keys.toList()
            ..sort((a, b) {
              final dateA = DateFormat('dd/MM').parse(a);
              final dateB = DateFormat('dd/MM').parse(b);
              return dateA.compareTo(dateB);
            });
          final List<String> sortedStudents = allStudentsNames.toList()..sort();

          final List<GridColumn> columns = <GridColumn>[
            GridColumn(
              columnName: 'studentName',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Aluno',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              width: 150,
            ),
            ...sortedDays.map(
              (day) => GridColumn(
                columnName: day,
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                width: 70,
              ),
            ),
            GridColumn(
              columnName: 'aulaDay',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Dia da Aula',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              width: 100,
            ),
            GridColumn(
              columnName: 'aulaContent',
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Conteúdo da Aula',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              width: 250,
            ),
          ];

          final List<DataGridRow> dataGridRows = sortedStudents.map((
            studentName,
          ) {
            final int studentIndex = sortedStudents.indexOf(studentName);

            String aulaDayText = '';
            String aulaContentText = '';
            if (studentIndex < sortedDays.length) {
              final String currentDayForContent = sortedDays[studentIndex];
              final Map<String, dynamic>? aulaDataForDay =
                  classesByDay[currentDayForContent];
              if (aulaDataForDay != null) {
                aulaDayText = currentDayForContent;
                String rawContent = aulaDataForDay['attendance_content'] ?? '-';
                if (rawContent.isNotEmpty && rawContent != '-') {
                  aulaContentText = rawContent;
                } else {
                  aulaContentText = '-';
                }
              }
            }

            return DataGridRow(
              cells: [
                DataGridCell<String>(
                  columnName: 'studentName',
                  value: studentName,
                ),
                ...sortedDays.map((day) {
                  final aulaDoDia = classesByDay[day];
                  final List<dynamic> studentsInThisClass =
                      aulaDoDia?['students'] ?? [];

                  final studentData = studentsInThisClass.firstWhere(
                    (s) => s['student_name'] == studentName,
                    orElse: () => null,
                  );

                  String presenceText;
                  Color textColor;

                  if (studentData == null) {
                    presenceText = '-';
                    textColor = Colors.grey.shade600;
                  } else {
                    presenceText = studentData['status'];

                    switch (presenceText) {
                      case 'P':
                        textColor = Colors.green.shade800;
                        break;
                      case 'F':
                        textColor = Colors.red.shade800;
                        break;
                      case 'A':
                        textColor = Colors.orange.shade800;
                        break;
                      default:
                        textColor = Colors.grey.shade600;
                    }
                  }
                  return DataGridCell<Widget>(
                    columnName: day,
                    value: Center(
                      child: Text(
                        presenceText,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                DataGridCell<String>(columnName: 'aulaDay', value: aulaDayText),
                DataGridCell<String>(
                  columnName: 'aulaContent',
                  value: aulaContentText,
                ),
              ],
            );
          }).toList();

          final attendanceDataSource = _AttendanceDataSource(dataGridRows);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  "Turma: $className",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: SfDataGrid(
                  source: attendanceDataSource,
                  columns: columns,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  gridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.fill,
                  allowColumnsResizing: true,
                  frozenColumnsCount: 1,
                  headerRowHeight: 40,
                  rowHeight: 60,
                  selectionMode: SelectionMode.none,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

class _AttendanceDataSource extends DataGridSource {
  _AttendanceDataSource(List<DataGridRow> dataGridRows) {
    _dataGridRows = dataGridRows;
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        if (e.value is Widget) {
          return e.value as Widget;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment:
              (e.columnName == 'studentName' ||
                  e.columnName == 'aulaDay' ||
                  e.columnName == 'aulaContent')
              ? Alignment.centerLeft
              : Alignment.center,
          child: Text(
            e.value?.toString() ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
