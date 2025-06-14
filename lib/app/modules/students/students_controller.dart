import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/students/students_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

enum ClasseFilterStatus { active, archived, all }

class StudentsController extends GetxController {
  final StudentsRepository _studentRepository = StudentsRepository(
    DatabaseHelper.instance,
  );

  final Classe currentClasse = Get.arguments as Classe;

  final isLoading = false.obs;
  final students = <Student>[].obs;

  final studentNameEC = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final studentEditNameEC = TextEditingController();
  final formEditKey = GlobalKey<FormState>();

  final Rx<ClasseFilterStatus?> selectedFilterStatus = Rx<ClasseFilterStatus?>(null);
  final RxList<int> availableYears = <int>[].obs;
  final RxInt selectedYear = RxInt(0);

  final RxList<Classe> availableClasses = <Classe>[].obs;
  final Rx<Classe?> selectedClasseToImport = Rx<Classe?>(null);

  final studentsFromSelectedClasse = <Student>[].obs;
  final selectedStudentsToImport = <Student>[].obs;

  final RxList<Classe> classesForTransfer = <Classe>[].obs;
  final Rx<Classe?> selectedClasseForTransfer = Rx<Classe?>(null);

  @override
  void onInit() {
    readStudents();
    super.onInit();
  }

  Future<void> addStudent() async {
    try {
      final names = studentNameEC.text
          .split('\n')
          .map((e) => e.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (names.isEmpty) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Nenhum aluno para adicionar.'));
        return;
      }

      final studentsToAdd = names.map((name) => Student(name: name)).toList();

      await _studentRepository.addStudentsToClasse(studentsToAdd, currentClasse.id!);
      await readStudents();
      studentNameEC.clear();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Adicionar Alunos', message: e.toString()));
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      isLoading.value = true;
      await _studentRepository.updateStudent(student);
      await readStudents();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Atualizar Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStudent(Student student) async {
    try {
      isLoading.value = true;
      await _studentRepository.deleteStudentFromClasse(student, currentClasse.id!);
      students.remove(student);
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Apagar Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> readStudents() async {
    try {
      isLoading.value = true;
      final fetchedStudents = await _studentRepository.getStudentsByClasseId(
        currentClasse.id!,
      );
      students.assignAll(fetchedStudents);
      students.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Ler Alunos', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // --- Métodos para a lógica de IMPORTAR alunos de outra turma ---

  void resetImportFilters() {
    selectedFilterStatus.value = null;
    selectedYear.value = 0;
    selectedClasseToImport.value = null;
    availableYears.clear();
    availableClasses.clear();
    studentsFromSelectedClasse.clear();
    selectedStudentsToImport.clear();
  }

  Future<void> loadAvailableYears() async {
    try {
      if (selectedFilterStatus.value == null) {
        availableYears.clear();
        selectedYear.value = 0;
        availableClasses.clear();
        selectedClasseToImport.value = null;
        return;
      }

      bool? activeStatus;
      if (selectedFilterStatus.value == ClasseFilterStatus.active) {
        activeStatus = true;
      } else if (selectedFilterStatus.value == ClasseFilterStatus.archived) {
        activeStatus = false;
      }

      final years = await _studentRepository.getAvailableYears(activeStatus: activeStatus);
      availableYears.assignAll(years);

      if (!availableYears.contains(selectedYear.value)) {
        selectedYear.value = 0;
      }
      if (availableYears.length == 1) {
        selectedYear.value = availableYears.first;
      }

      await loadAvailableClasses();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar anos disponíveis: $e'));
    }
  }

  Future<void> loadAvailableClasses() async {
    try {
      if (selectedFilterStatus.value == null || selectedYear.value == 0) {
        availableClasses.clear();
        selectedClasseToImport.value = null;
        studentsFromSelectedClasse.clear();
        return;
      }

      bool? activeStatus;
      if (selectedFilterStatus.value == ClasseFilterStatus.active) {
        activeStatus = true;
      } else if (selectedFilterStatus.value == ClasseFilterStatus.archived) {
        activeStatus = false;
      }

      final classes = await _studentRepository.getClassesByStatusAndYear(
        activeStatus: activeStatus,
        year: selectedYear.value,
      );

      availableClasses.assignAll(classes.where((c) => c.id != currentClasse.id));

      if (!availableClasses.contains(selectedClasseToImport.value)) {
        selectedClasseToImport.value = null;
      }
      if (availableClasses.length == 1) {
        selectedClasseToImport.value = availableClasses.first;
      }

      await loadStudentsFromSelectedClasse();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar turmas disponíveis: $e'));
    }
  }

  Future<void> loadStudentsFromSelectedClasse() async {
    try {
      if (selectedClasseToImport.value == null) {
        studentsFromSelectedClasse.clear();
        selectedStudentsToImport.clear();
        return;
      }
      final students = await _studentRepository.getStudentsByClasseId(
        selectedClasseToImport.value!.id!,
      );
      studentsFromSelectedClasse.assignAll(students);
      selectedStudentsToImport.clear();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar alunos da turma selecionada: $e'));
    }
  }

  void toggleStudentToImport(Student student, bool selected) {
    if (selected) {
      selectedStudentsToImport.add(student);
    } else {
      selectedStudentsToImport.remove(student);
    }
  }

  Future<void> importSelectedStudentsToCurrentClasse() async {
    if (selectedStudentsToImport.isEmpty) {
      Get.dialog(CustomErrorDialog(title: 'Importar Alunos', message: 'Selecione pelo menos um aluno para importar.'));
      return;
    }
    try {
      isLoading.value = true;
      await _studentRepository.addStudentsToClasse(selectedStudentsToImport, currentClasse.id!);
      await readStudents();
      selectedStudentsToImport.clear();
      Get.back();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro de Importação', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // --- Métodos para a lógica de TRANSFERIR alunos ---

  Future<void> loadClassesForTransfer() async {
    try {
      classesForTransfer.assignAll(await _studentRepository.getAllClassesExcept(currentClasse.id!));
      classesForTransfer.removeWhere((c) => c.id == currentClasse.id); // Garante que a própria turma não seja uma opção
      selectedClasseForTransfer.value = null;
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar turmas para transferência: $e'));
    }
  }

  Future<void> moveStudentAcrossClasses(Student student) async {
    if (selectedClasseForTransfer.value == null) {
      Get.dialog(CustomErrorDialog(title: 'Transferir Aluno', message: 'Selecione uma turma de destino.'));
      return;
    }
    try {
      isLoading.value = true;
      await _studentRepository.moveStudentToClasse(student, currentClasse.id!, selectedClasseForTransfer.value!.id!);
      await readStudents();
      selectedClasseForTransfer.value = null;
      Get.back();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Mover Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }
}