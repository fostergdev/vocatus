import 'package:flutter/material.dart'; // Importa widgets do Flutter
import 'package:get/get.dart'; // Importa o GetX para gerenciamento de estado

import 'package:vocatus/app/models/discipline.dart'; // Importa o modelo de Disciplina
import 'package:vocatus/app/repositories/disciplines/discipline_repository.dart'; // Importa o repositório de disciplinas

class DisciplinesController extends GetxController {
  final DisciplineRepository _disciplineRepository;

  DisciplinesController(this._disciplineRepository);
  final isLoading = false.obs; // Observável para indicar carregamento
  final disciplines = <Discipline>[].obs; // Lista observável de disciplinas

  final nameEC = TextEditingController(); // Controller para nome da disciplina (cadastro)
  final formKey = GlobalKey<FormState>(); // Chave do formulário de cadastro

  final nameEditEC = TextEditingController(); // Controller para edição do nome da disciplina
  final formEditKey = GlobalKey<FormState>(); // Chave do formulário de edição

  /// Busca todas as disciplinas do banco e atualiza a lista local.
  Future<void> readDisciplines() async {
    try {
      isLoading.toggle(); // Inicia carregamento
      disciplines.value = await _disciplineRepository.readDisciplines(); // Atualiza lista local com dados do banco
    } catch (e) {
      rethrow; // Propaga erro para ser tratado na UI
    } finally {
      isLoading.toggle(); // Finaliza carregamento
    }
  }

  /// Cria uma nova disciplina e adiciona à lista local.
  Future<void> createDiscipline(Discipline discipline) async {
    try {
      isLoading.toggle(); // Inicia carregamento
      Discipline newDiscipline = await _disciplineRepository.createDiscipline(
        discipline,
      ); // Cria a disciplina no banco
      disciplines.add(newDiscipline); // Adiciona à lista local
    } catch (e) {
      String userMessage = 'Erro desconhecido'; // Mensagem padrão
      if (e is String && e.contains('|')) {
        final parts = e.split('|'); // Separa mensagem amigável do erro técnico
        userMessage = parts[0];
      } else {
        userMessage = e.toString().replaceAll('Exception: ', ''); // Remove prefixo padrão de exceção
      }

      throw userMessage; // Lança mensagem para ser tratada na UI
    } finally {
      isLoading.toggle(); // Finaliza carregamento
    }
  }

  /// Atualiza uma disciplina no banco e na lista local.
  Future<void> updateDiscipline(Discipline discipline) async {
    try {
      isLoading.toggle(); // Inicia carregamento
      await _disciplineRepository.updateDiscipline(discipline); // Atualiza no banco
      int index = disciplines.indexWhere((d) => d.id == discipline.id); // Busca índice da disciplina na lista local
      if (index != -1) {
        disciplines[index] = discipline; // Atualiza na lista local
      }
    } catch (e) {
      String userMessage = 'Erro desconhecido'; // Mensagem padrão
      if (e is String && e.contains('|')) {
        final parts = e.split('|'); // Separa mensagem amigável do erro técnico
        userMessage = parts[0];
      } else {
        userMessage = e.toString().replaceAll('Exception: ', ''); // Remove prefixo padrão de exceção
      }

      throw userMessage; // Lança mensagem para ser tratada na UI
    } finally {
      isLoading.toggle(); // Finaliza carregamento
    }
  }

  /// Deleta uma disciplina do banco e remove da lista local.
  Future<void> deleteDiscipline(int id) async {
    try {
      isLoading.toggle(); // Inicia carregamento
      await _disciplineRepository.deleteDiscipline(id); // Deleta no banco
      disciplines.removeWhere((d) => d.id == id); // Remove da lista local
    } catch (e) {
      String userMessage = 'Erro desconhecido'; // Mensagem padrão
      if (e is String && e.contains('|')) {
        final parts = e.split('|'); // Separa mensagem amigável do erro técnico
        userMessage = parts[0];
      } else {
        userMessage = e.toString().replaceAll('Exception: ', ''); // Remove prefixo padrão de exceção
      }

      throw userMessage; // Lança mensagem para ser tratada na UI
    } finally {
      isLoading.toggle(); // Finaliza carregamento
    }
  }

  /// Executa ao inicializar o controller: carrega as disciplinas.
  @override
  void onInit() {
    readDisciplines(); // Carrega as disciplinas ao iniciar
    super.onInit();
  }

  /// Executa ao fechar o controller: libera os controllers de texto.
  @override
  void onClose() {
    nameEC.dispose(); // Libera o controller de cadastro
    nameEditEC.dispose(); // Libera o controller de edição
    super.onClose();
  }
}
