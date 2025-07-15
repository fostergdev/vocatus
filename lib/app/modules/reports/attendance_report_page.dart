import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart';
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
        actions: [
          CustomPopupMenu(
            icon: Icons.file_download,
            iconColor: colorScheme.onPrimary,
            items: [
              CustomPopupMenuItem(
                label: 'Exportar Excel (Abas)',
                icon: Icons.table_chart,
                onTap: () => _exportToExcel(),
              ),
              CustomPopupMenuItem(
                label: 'Exportar PDF',
                icon: Icons.picture_as_pdf,
                onTap: () => _exportToPdf(),
              ),
            ],
          ),
        ],
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
                          DateFormat(
                            'dd/MM',
                          ).format(DateTime.parse(session['date'])),
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

void _exportToExcel() async {
  try {
    // Verificar se há dados para exportar
    if (controller.attendanceSessions.isEmpty || 
        controller.attendanceStudentsData.isEmpty) {
      Get.snackbar(
        'Aviso',
        'Não há dados de presença para exportar',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Agrupar e ordenar sessões por mês
    final Map<String, List<Map<String, dynamic>>> sessionsByMonth = {};
    for (var session in controller.attendanceSessions) {
      final date = DateTime.parse(session['date']);
      final monthKey = DateFormat('yyyy-MM').format(date);
      sessionsByMonth.putIfAbsent(monthKey, () => []).add(session);
    }

    // Ordenar meses cronologicamente
    final sortedMonthKeys = sessionsByMonth.keys.toList()..sort();

    // Criar Excel de forma mais robusta
    final excel = Excel.createExcel();
    
    // Gerar nome do arquivo
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final className = controller.classe.value.name.replaceAll(' ', '_');
    final fileName = 'presenca_${className}_$timestamp.xlsx';

    // Processar cada mês
    for (var i = 0; i < sortedMonthKeys.length; i++) {
      final monthKey = sortedMonthKeys[i];
      final sessions = sessionsByMonth[monthKey]!;
      final date = DateTime.parse(sessions.first['date']);
      final monthName = DateFormat('MMM_yyyy', 'pt_BR').format(date);
      
      // Criar nome seguro para a aba (máximo 31 caracteres)
      var sheetName = _cleanSheetName(monthName);
      if (sheetName.length > 31) {
        sheetName = sheetName.substring(0, 31);
      }
      
      // Garantir que o nome da aba seja único
      var finalSheetName = sheetName;
      var counter = 1;
      while (excel.tables.containsKey(finalSheetName)) {
        finalSheetName = '${sheetName.substring(0, 28)}_$counter';
        counter++;
      }
      
      // Criar a aba
      final sheet = excel[finalSheetName];
      
      try {
        // Construir conteúdo da planilha
        _buildExcelSheet(sheet, sessions);
      } catch (e) {
        print('Erro ao construir sheet $finalSheetName: $e');
        // Continuar com as outras abas mesmo se uma falhar
      }
    }
    
    // Remover Sheet1 padrão se ainda existir
    if (excel.tables.containsKey('Sheet1') && excel.tables.length > 1) {
      try {
        excel.delete('Sheet1');
      } catch (e) {
        print('Não foi possível remover Sheet1: $e');
      }
    }

    // Salvar e exportar o arquivo
    final fileBytes = excel.save();
    if (fileBytes == null) {
      throw Exception('Falha ao gerar arquivo Excel');
    }

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar Relatório de Presença',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: Uint8List.fromList(fileBytes),
    );

    if (outputFile != null) {
      Get.snackbar(
        'Sucesso!',
        'Relatório exportado com ${sortedMonthKeys.length} meses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(Get.context!).colorScheme.primaryContainer,
        colorText: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 4),
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(Get.context!).colorScheme.primary,
        ),
      );
    }
  } catch (e) {
    print('Erro na exportação: $e');
    Get.snackbar(
      'Erro na Exportação',
      'Ocorreu um erro ao gerar o arquivo Excel: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
      colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
      duration: const Duration(seconds: 4),
    );
  }
}

// Função auxiliar para limpar nomes de abas
String _cleanSheetName(String name) {
  // Remove caracteres inválidos para nomes de abas no Excel
  return name.replaceAll(RegExp(r'[\\/*?[\]:]'), '_');
}

// Função para construir uma aba completa
void _buildExcelSheet(Sheet sheet, List<Map<String, dynamic>> sessions) {
  // Cabeçalho
  sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Aluno');
  
  // Cabeçalhos das datas
  int colIndex = 1;
  for (final session in sessions) {
    final date = DateFormat('dd/MM').format(DateTime.parse(session['date']));
    final discipline = session['discipline_name']?.substring(0, 3) ?? '';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
      .value = TextCellValue('$date $discipline');
    colIndex++;
  }

  // Colunas adicionais
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
    .value = TextCellValue('Conteúdos');
  colIndex++;
  
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
    .value = TextCellValue('Total');

  // Dados dos alunos
  int rowIndex = 1;
  for (final student in controller.attendanceStudentsData) {
    // Nome do aluno
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      .value = TextCellValue(student['name']);

    int presencas = 0;
    colIndex = 1;

    // Status de presença
    for (final session in sessions) {
      final attendanceId = session['attendance_id'].toString();
      final status = student[attendanceId] as String? ?? '-';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
        .value = TextCellValue(status);
      
      if (status == 'P') presencas++;
      colIndex++;
    }

    // Conteúdos - simplificado sem quebras de linha
    final contents = sessions
      .where((s) => s['content']?.toString().isNotEmpty ?? false)
      .map((s) => '${DateFormat('dd/MM').format(DateTime.parse(s['date']))}: ${s['content']}')
      .join('; ');
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
      .value = TextCellValue(contents.isNotEmpty ? contents : 'Sem conteúdo');
    colIndex++;

    // Total
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex))
      .value = TextCellValue('$presencas/${sessions.length}');

    rowIndex++;
  }
}
  void _exportToPdf() {
    Get.snackbar(
      'Exportar PDF',
      'Funcionalidade de exportação para PDF em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
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
        DataGridCell<String>(
          columnName: 'name',
          value: student['name'] as String,
        ),
        ...sessions.map((session) {
          final attendanceId = session['attendance_id'].toString();
          return DataGridCell<String>(
            columnName: attendanceId,
            value: student[attendanceId] as String? ?? '-',
          );
        }),
      ];

      // Célula de conteúdo
      String contentValue = '-';
      if (studentIndex < sessions.length) {
        final session = sessions[studentIndex];
        final date = DateFormat(
          'dd/MM',
        ).format(DateTime.parse(session['date']));
        final content = session['content'] as String? ?? 'Sem conteúdo';
        contentValue = '$date - $content';
      }

      cells.add(
        DataGridCell<String>(columnName: 'content', value: contentValue),
      );

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
