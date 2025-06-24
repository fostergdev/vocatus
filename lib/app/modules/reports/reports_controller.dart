import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe_report.dart';
import 'dart:developer' as developer;
import 'package:vocatus/app/repositories/reports/reports_repository.dart';

class ReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );

  final RxList<ClasseReport> classesReport = <ClasseReport>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchClassesReport(DateTime.now().year);
  }

  Future<void> fetchClassesReport(int year) async {
    try {
      developer.log(
        'Buscando relatórios de turmas para o ano: $year',
        name: 'ReportsController',
      );
      final rawData = await _reportsRepository.getClassesRawReport(year);

      // Limpa a lista atual para recarregar
      classesReport.clear();

      // Mapeia e agrupa os dados brutos em uma estrutura de ClasseReport
      final Map<int, ClasseReport> classMap = {};

      for (var row in rawData) {
        final int classeId = row['classe_id'];
        final String classeName = row['classe_name'];
        final String? disciplineName = row['discipline_name'];
        final int dayOfWeek = row['day_of_week'];
        final String startTime = row['start_time'];
        final String endTime = row['end_time'];

        // Cria o detalhe do horário
        final scheduleDetail = ScheduleDetail(
          disciplineName: disciplineName,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
        );

        // Se a classe ainda não está no mapa, adiciona
        if (!classMap.containsKey(classeId)) {
          classMap[classeId] = ClasseReport(
            id: classeId,
            name: classeName,
            schedules: [],
          );
        }
        // Adiciona o detalhe do horário à classe correspondente
        classMap[classeId]!.schedules.add(scheduleDetail);
      }

      // Adiciona todas as classes processadas à lista observável
      classesReport.addAll(classMap.values.toList());

      developer.log(
        'Relatórios de turmas carregados com sucesso: ${classesReport.length} turmas',
        name: 'ReportsController',
      );
    } catch (e) {
      developer.log(
        'Erro ao buscar relatórios de turmas: $e',
        name: 'ReportsController',
        error: e,
      );
      // Aqui você pode adicionar uma forma de notificar o usuário sobre o erro
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os relatórios de turmas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Você pode adicionar uma propriedade para o ano selecionado no futuro,
  // caso o usuário possa selecionar outros anos no CustomPopupMenu
  final RxInt selectedReportYear = DateTime.now().year.obs;

  void onYearSelected(int year) {
    selectedReportYear.value = year;
    fetchClassesReport(year); // Recarrega os dados para o novo ano
    developer.log(
      'Ano de relatório selecionado: $year',
      name: 'ReportsController',
    );
  }
}
