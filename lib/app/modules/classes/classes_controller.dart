import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/classes/classes_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

class ClassesController extends GetxController {
  final ClasseRepository _classeRepository = ClasseRepository(
    DatabaseHelper.instance,
  );
  final isLoading = false.obs;
  final classes = <Classe>[].obs;

  final classeDescriptionEC = TextEditingController();
  final classeNameEC = TextEditingController();
  final classeSchoolYearEC = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final formKey = GlobalKey<FormState>();

  final RxInt selectedYear = RxInt(DateTime.now().year);

  final classeEditNameEC = TextEditingController();
  final formEditKey = GlobalKey<FormState>();

  @override
  void onInit() {
    readClasses();
    super.onInit();
  }

  Future<void> createClasse(Classe classe) async {
    try {
      isLoading.value = true;
      await _classeRepository.createClasse(classe);
      await readClasses(year: classe.schoolYear);
    } catch (e) {
      String userMessage = 'Erro desconhecido';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      throw userMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> readClasses({bool? active, int? year}) async {
    isLoading.value = true;
    try {
      final filterActive = active ?? true;
      final filterYear = year ?? DateTime.now().year;

      classes.value = await _classeRepository.readClasses(
        active: filterActive,
        year: filterYear,
      );
    } catch (e) {
      String userMessage = 'Erro ao carregar turmas.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClasse(Classe classe) async {
    isLoading.value = true;
    try {
      await _classeRepository.updateClasse(classe);
      await readClasses(year: classe.schoolYear);
      classeEditNameEC.clear();
    } catch (e) {
      String userMessage = 'Erro desconhecido';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      throw userMessage;
    } finally {
      isLoading.value = false;
    }
  }

  /*  Future<void> toggleClasseActiveStatus(Classe classe) async {
    isLoading.value = true;
    try {
      final newStatus = !(classe.active ?? true);
      await _classeRepository.updateClasse(
        Classe(
          id: classe.id,
          name: classe.name,
          description: classe.description,
          schoolYear: classe.schoolYear,
          createdAt: classe.createdAt,
          active: newStatus,
        ),
      );
      await readClasses();
    } catch (e) {
      String userMessage = 'Erro desconhecido ao mudar status da turma.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  } */
}
