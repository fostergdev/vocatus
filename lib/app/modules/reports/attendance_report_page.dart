import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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
                label: 'Exportar Excel',
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
            students: controller.attendanceStudentsData,
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
                          session['discipline_name'] ?? '',
                          style: const TextStyle(fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              GridColumn(
                columnName: 'content',
                width: 250,
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
      final timestamp = DateFormat('yyyy').format(DateTime.now());
      final className = controller.classe.value.name.replaceAll(' ', '_');
      final fileName = '${className}_$timestamp.xlsx';

      // Processar cada mês
      for (var i = 0; i < sortedMonthKeys.length; i++) {
        final monthKey = sortedMonthKeys[i];
        final sessions = sessionsByMonth[monthKey]!;
        final date = DateTime.parse(sessions.first['date']);
        final monthName = DateFormat('MMM', 'pt_BR').format(date).toLowerCase();

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

  void _buildExcelSheet(Sheet sheet, List<Map<String, dynamic>> sessions) {
    // Cabeçalho
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Aluno');

    // Cabeçalhos das datas
    int colIndex = 1;
    for (final session in sessions) {
      print(session['discipline_name']);
      final date = DateFormat('dd/MM').format(DateTime.parse(session['date']));
      final discipline = session['discipline_name'] ?? '';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
          .value = TextCellValue(
        '$date\n$discipline',
      );
      colIndex++;
    }

    // Cabeçalho da coluna Conteúdo
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
        .value = TextCellValue(
      'Conteúdo',
    );

    // Dados dos alunos
    int rowIndex = 1;

    for (int i = 0; i < controller.attendanceStudentsData.length; i++) {
      final student = controller.attendanceStudentsData[i];
      final row = rowIndex++;

      // Nome do aluno
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        student['name'],
      );

      int presencas = 0;
      colIndex = 1;

      // Marcar presença
      for (final session in sessions) {
        final attendanceId = session['attendance_id'].toString();
        final status = student[attendanceId] as String? ?? '-';
        if (status == 'P') presencas++;
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: row),
            )
            .value = TextCellValue(
          status,
        );
        colIndex++;
      }

      // Conteúdo: apenas nas N primeiras linhas, onde N = sessões com conteúdo
      final contentColIndex = colIndex;
      String? contentValue;

      if (i < sessions.length) {
        final session = sessions[i];
        final content = session['content']?.toString().trim();
        final dateStr = DateFormat(
          'dd/MM',
        ).format(DateTime.parse(session['date']));
        if (content != null && content.isNotEmpty) {
          contentValue = '$dateStr - $content';
        } else {
          contentValue = '-';
        }
      } else {
        contentValue = '';
      }

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: contentColIndex,
              rowIndex: row,
            ),
          )
          .value = TextCellValue(
        contentValue,
      );
    }
  }

  void _exportToPdf() async {
    try {
      final sessions = controller.attendanceSessions;
      final students = controller.attendanceStudentsData;

      if (sessions.isEmpty || students.isEmpty) {
        Get.snackbar(
          'Aviso',
          'Não há dados de presença para exportar em PDF',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final pdf = pw.Document();

      // Cabeçalhos
      final headers = <String>[
        'Aluno',
        ...sessions.map(
          (s) => DateFormat('dd/MM').format(DateTime.parse(s['date'])),
        ),
        'Conteúdo',
      ];

      // Construir linhas da tabela
      final List<List<String>> tableRows = [];

      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        final row = <String>[];

        row.add(student['name']);

        for (final session in sessions) {
          final status =
              student[session['attendance_id'].toString()] as String? ?? '-';
          row.add(status);
        }

        // Conteúdo apenas nas N primeiras linhas (N = nº de sessões)
        if (i < sessions.length) {
          final session = sessions[i];
          final content = session['content']?.toString().trim();
          final dateStr = DateFormat(
            'dd/MM',
          ).format(DateTime.parse(session['date']));
          if (content != null && content.isNotEmpty) {
            row.add('$dateStr - $content');
          } else {
            row.add('-');
          }
        } else {
          row.add('');
        }

        tableRows.add(row);
      }

      // Adiciona página ao PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return [
              pw.Text(
                'Relatório de Presença: ${controller.classe.value.name}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: tableRows,
                cellAlignment: pw.Alignment.center,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellStyle: pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  for (var i = 1; i <= sessions.length; i++)
                    i: const pw.FlexColumnWidth(1.2),
                  headers.length - 1: const pw.FlexColumnWidth(3),
                },
              ),
            ];
          },
        ),
      );

      // Nome do arquivo
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final className = controller.classe.value.name.replaceAll(' ', '_');
      final fileName = 'presenca_${className}_$timestamp.pdf';

      // Salvar arquivo
      final fileBytes = await pdf.save();

      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: Uint8List.fromList(fileBytes),
      );

      if (outputFile != null) {
        Get.snackbar(
          'Sucesso!',
          'PDF exportado com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(Get.context!).colorScheme.primaryContainer,
          colorText: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
        );
      }
    } catch (e) {
      print('Erro ao exportar PDF: $e');
      Get.snackbar(
        'Erro na Exportação',
        'Ocorreu um erro ao gerar o PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
        colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
      );
    }
  }
}

class AttendanceDataSource extends DataGridSource {
  late final List<DataGridRow> _attendanceData;
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> students;

  AttendanceDataSource({required this.students, required this.sessions}) {
    _attendanceData = List.generate(students.length, (int studentIndex) {
      final student = students[studentIndex];

      // Conteúdo: para cada linha de aluno, pega o conteúdo da sessão de mesmo índice
      String contentValue = '';
      if (studentIndex < sessions.length) {
        final session = sessions[studentIndex];
        final date = DateFormat(
          'dd/MM',
        ).format(DateTime.parse(session['date']));
        final content = session['content']?.toString().trim() ?? '';
        contentValue = content.isNotEmpty ? '$date - $content' : '';
      }

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
        DataGridCell<String>(columnName: 'content', value: contentValue),
      ];
      return DataGridRow(cells: cells);
    });

    // Linha de conteúdo ao final (opcional)
    final List<DataGridCell<String>> contentRow = [
      const DataGridCell<String>(columnName: 'name', value: 'Conteúdo'),
      ...sessions.map((session) {
        final date = DateFormat(
          'dd/MM',
        ).format(DateTime.parse(session['date']));
        final content = session['content']?.toString().trim() ?? '';
        return DataGridCell<String>(
          columnName: session['attendance_id'].toString(),
          value: content.isNotEmpty ? '$date - $content' : '',
        );
      }),
      const DataGridCell<String>(columnName: 'content', value: ''),
    ];
    _attendanceData.add(DataGridRow(cells: contentRow));
  }

  @override
  List<DataGridRow> get rows => _attendanceData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isContentRow = row.getCells().first.value == 'Conteúdo';

    return DataGridRowAdapter(
      color: isContentRow ? Colors.grey[200] : null,
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
            style: TextStyle(
              fontWeight: isContentRow ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
