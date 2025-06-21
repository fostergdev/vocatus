import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/students/students_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

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

  // Variáveis para importação
  final RxList<int> availableYears = <int>[].obs;
  final Rx<int?> selectedYear = Rx<int?>(null);

  final RxList<Classe> availableClasses = <Classe>[].obs;
  final Rx<Classe?> selectedClasseToImport = Rx<Classe?>(null);

  final studentsFromSelectedClasse = <Student>[].obs;
  final selectedStudentsToImport = <Student>[].obs;

  // Variáveis para transferência
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
      if (currentClasse.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID da turma atual é nulo. Não foi possível adicionar alunos.'));
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
      if (student.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID do aluno é nulo. Não foi possível atualizar.'));
        return;
      }
      await _studentRepository.updateStudent(student);
      await readStudents();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Atualizar Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // --- NOVA FUNÇÃO PARA ARQUIVAR ALUNO (substitui toggleStudentStatus) ---
  Future<void> archiveStudent(Student student) async {
    try {
      isLoading.value = true;
      if (student.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID do aluno é nulo. Não foi possível arquivar.'));
        return;
      }
      // Chama a nova função no repositório para arquivar permanentemente
      await _studentRepository.archiveStudentPermanently(student);
      await readStudents();
      // Não chama Get.back() aqui, pois o diálogo de confirmação já fez isso.
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Arquivar Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> readStudents() async {
    try {
      isLoading.value = true;
      if (currentClasse.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID da turma atual é nulo. Não foi possível ler alunos.'));
        return;
      }
      final fetchedStudents = await _studentRepository.getStudentsByClasseId(
        currentClasse.id!,
      );
      // Ordena todos (ativos e inativos) em ordem alfabética
      fetchedStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      students.assignAll(fetchedStudents);
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Ler Alunos', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos para importação (ajuste/remova filtros de status)
  void resetImportFilters() {
    selectedYear.value = null;
    selectedClasseToImport.value = null;
    availableYears.clear();
    availableClasses.clear();
    studentsFromSelectedClasse.clear();
    selectedStudentsToImport.clear();
  }

  Future<void> loadAvailableYears() async {
    try {
      final years = await _studentRepository.getAvailableYears();
      availableYears.assignAll(years);
      if (selectedYear.value != null && !availableYears.contains(selectedYear.value)) {
        selectedYear.value = null;
      }
      if (availableYears.isEmpty) {
        selectedYear.value = null;
      } else if (availableYears.length == 1) {
        selectedYear.value = availableYears.first;
      }
      if (selectedYear.value != null) {
        await loadAvailableClasses();
      } else {
        availableClasses.clear();
        selectedClasseToImport.value = null;
        studentsFromSelectedClasse.clear();
      }
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar anos disponíveis: ${e.toString()}'));
    }
  }

  Future<void> loadAvailableClasses() async {
    try {
      if (selectedYear.value == null) {
        availableClasses.clear();
        selectedClasseToImport.value = null;
        studentsFromSelectedClasse.clear();
        return;
      }
      final classes = await _studentRepository.getClassesByStatusAndYear(
        year: selectedYear.value!,
      );
      availableClasses.assignAll(classes.where((c) => c.id != currentClasse.id));
      if (selectedClasseToImport.value != null && !availableClasses.contains(selectedClasseToImport.value)) {
        selectedClasseToImport.value = null;
      }
      if (availableClasses.isEmpty) {
        selectedClasseToImport.value = null;
        studentsFromSelectedClasse.clear();
      } else if (availableClasses.length == 1) {
        selectedClasseToImport.value = availableClasses.first;
      }
      if (selectedClasseToImport.value != null) {
        await loadStudentsFromSelectedClasse();
      } else {
        studentsFromSelectedClasse.clear();
      }
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar turmas disponíveis: ${e.toString()}'));
    }
  }

  Future<void> loadStudentsFromSelectedClasse() async {
    try {
      if (selectedClasseToImport.value == null || selectedClasseToImport.value!.id == null) {
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
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar alunos da turma selecionada: ${e.toString()}'));
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
    if (currentClasse.id == null) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID da turma atual é nulo. Não foi possível importar alunos.'));
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

  Future<void> loadClassesForTransfer() async {
    try {
      if (currentClasse.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID da turma atual é nulo. Não foi possível carregar turmas para transferência.'));
        return;
      }
      classesForTransfer.assignAll(await _studentRepository.getAllClassesExcept(currentClasse.id!));
      classesForTransfer.removeWhere((c) => c.id == currentClasse.id);
      selectedClasseForTransfer.value = null;
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar turmas para transferência: ${e.toString()}'));
    }
  }

  Future<void> moveStudentAcrossClasses(Student student) async {
    if (selectedClasseForTransfer.value == null || selectedClasseForTransfer.value!.id == null) {
      Get.dialog(CustomErrorDialog(title: 'Transferir Aluno', message: 'Selecione uma turma de destino válida.'));
      return;
    }
    if (student.id == null || currentClasse.id == null) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Dados do aluno ou da turma de origem insuficientes para a transferência.'));
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

  Future<void> duplicateStudentToOtherClasse(Student student, int toClasseId) async {
    try {
      isLoading.value = true;
      if (student.id == null) {
        Get.dialog(CustomErrorDialog(title: 'Erro', message: 'ID do aluno é nulo. Não foi possível duplicar.'));
        return;
      }
      if (toClasseId == currentClasse.id) {
         Get.dialog(CustomErrorDialog(title: 'Atenção', message: 'Não é possível duplicar o aluno para a mesma turma atual.'));
         return;
      }
      await _studentRepository.duplicateStudentToClasse(student, toClasseId);
      await readStudents();
      Get.back();
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro ao Duplicar Aluno', message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }
}