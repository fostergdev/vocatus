import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      if (!controller.isLoadingAttendance.value &&
          controller.attendanceReportData.isEmpty) {
        controller.loadAttendanceReport(classId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório Chamadas',
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
                colorScheme.primary.withValues(
                  alpha: 0.9,
                ), 
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
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ), 
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: colorScheme.onPrimary,
            ), 
            tooltip: 'Compartilhar',
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingAttendance.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ); 
        } else if (controller.attendanceReportData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined, 
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ), 
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum dado de chamada encontrado para esta turma.',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, 
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifique as chamadas registradas ou o ano de filtro da turma.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ), 
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final Map<String, Map<String, dynamic>> classesByDay = {};
          final Set<String> allStudentsNames = {};

          for (var record in controller.attendanceReportData) {
            final String rawDate = record['date']?.toString() ?? '';
            if (rawDate.isEmpty) continue;

            final String formattedDate = DateFormat(
              'dd/MM',
            ).format(DateTime.parse(rawDate));
            final String studentName =
                record['student_name']?.toString() ?? 'Nome não informado';
            final String status = record['status']?.toString() ?? 'P';
            final String content = record['content']?.toString() ?? '';

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
                color: colorScheme
                    .surfaceContainerHighest, 
                child: Text(
                  'Aluno',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme
                        .onSurfaceVariant, 
                  ),
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
                  color: colorScheme
                      .surfaceContainerHighest, 
                  child: Text(
                    day,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme
                          .onSurfaceVariant, 
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
                color: colorScheme
                    .surfaceContainerHighest, 
                child: Text(
                  'Dia da Aula',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme
                        .onSurfaceVariant, 
                  ),
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
                color: colorScheme
                    .surfaceContainerHighest, 
                child: Text(
                  'Conteúdo da Aula',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme
                        .onSurfaceVariant, 
                  ),
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

                  final studentData = studentsInThisClass.firstWhereOrNull(
                    
                    (s) => s['student_name'] == studentName,
                  );

                  String presenceText;
                  Color textColor;

                  if (studentData == null) {
                    presenceText = '-'; 
                    textColor = colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    );
                  } else {
                    presenceText = studentData['status'];

                    switch (presenceText) {
                      case 'P': 
                        textColor = colorScheme.tertiary; 
                        break;
                      case 'F': 
                        textColor = colorScheme.error; 
                        break;
                      case 'A': 
                        textColor =
                            colorScheme.secondary; 
                        break;
                      default: 
                        textColor = colorScheme.onSurfaceVariant;
                    }
                  }
                  return DataGridCell<Widget>(
                    columnName: day,
                    value: Center(
                      child: Text(
                        presenceText,
                        style: textTheme.bodyMedium?.copyWith(
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

          final attendanceDataSource = _AttendanceDataSource(
            dataGridRows,
            colorScheme,
            textTheme,
          ); 

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  "Turma: $className",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme
                        .onSurface, 
                  ),
                ),
              ),
              Expanded(
                child: SfDataGrid(
                  source: attendanceDataSource,
                  columns: columns,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  headerRowHeight: 48,
                  rowHeight: 56,
                  columnWidthMode: ColumnWidthMode.fill,
                  allowColumnsResizing: true,
                  frozenColumnsCount: 1,
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
  _AttendanceDataSource(
    List<DataGridRow> dataGridRows,
    this._colorScheme, 
    this._textTheme, 
  ) {
    _dataGridRows = dataGridRows;
  }

  List<DataGridRow> _dataGridRows = [];
  final ColorScheme _colorScheme; 
  final TextTheme _textTheme; 

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
            style: _textTheme.bodyMedium?.copyWith(
              color: _colorScheme.onSurface, 
            ),
          ),
        );
      }).toList(),
    );
  }
}
