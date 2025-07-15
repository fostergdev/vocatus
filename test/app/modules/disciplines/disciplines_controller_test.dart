import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/modules/disciplines/disciplines_controller.dart';
import 'package:vocatus/app/repositories/disciplines/discipline_repository.dart';

import 'disciplines_controller_test.mocks.dart';

@GenerateMocks([DisciplineRepository])
void main() {
  group('DisciplinesController', () {
    late DisciplinesController controller;
    late MockDisciplineRepository mockDisciplineRepository;

    setUp(() {
      mockDisciplineRepository = MockDisciplineRepository();
      Get.put<DisciplineRepository>(mockDisciplineRepository);
      controller = DisciplinesController(mockDisciplineRepository);
    });

    tearDown(() {
      Get.delete<DisciplineRepository>();
      controller.dispose();
    });

    test('readDisciplines should fetch and update disciplines list', () async {
      final mockDisciplines = [
        Discipline(id: 1, name: 'Math', createdAt: DateTime.now()),
        Discipline(id: 2, name: 'Science', createdAt: DateTime.now()),
      ];

      when(mockDisciplineRepository.readDisciplines())
          .thenAnswer((_) async => mockDisciplines);

      expect(controller.isLoading.value, false);
      await controller.readDisciplines();

      expect(controller.isLoading.value, false);
      expect(controller.disciplines.length, 2);
      expect(controller.disciplines[0].name, 'Math');
      expect(controller.disciplines[1].name, 'Science');
      verify(mockDisciplineRepository.readDisciplines()).called(1); // Called once explicitly, onInit is handled by setUp
    });

    test('createDiscipline should add a new discipline to the list', () async {
      final newDiscipline = Discipline(name: 'History', createdAt: DateTime.now());
      final createdDiscipline = Discipline(id: 3, name: 'History', createdAt: DateTime.now());

      when(mockDisciplineRepository.createDiscipline(any))
          .thenAnswer((_) async => createdDiscipline);

      await controller.createDiscipline(newDiscipline);

      expect(controller.disciplines.length, 1); // Assuming initial list is empty after setup
      expect(controller.disciplines[0].name, 'History');
      verify(mockDisciplineRepository.createDiscipline(newDiscipline)).called(1);
    });

    test('updateDiscipline should update an existing discipline in the list', () async {
      final initialDiscipline = Discipline(id: 1, name: 'Math', createdAt: DateTime.now());
      controller.disciplines.add(initialDiscipline);

      final updatedDiscipline = Discipline(id: 1, name: 'Mathematics', createdAt: DateTime.now());

      when(mockDisciplineRepository.updateDiscipline(any))
          .thenAnswer((_) async => Future.value());

      await controller.updateDiscipline(updatedDiscipline);

      expect(controller.disciplines.length, 1);
      expect(controller.disciplines[0].name, 'Mathematics');
      verify(mockDisciplineRepository.updateDiscipline(updatedDiscipline)).called(1);
    });

    test('deleteDiscipline should remove a discipline from the list', () async {
      final disciplineToDelete = Discipline(id: 1, name: 'Math', createdAt: DateTime.now());
      controller.disciplines.add(disciplineToDelete);

      when(mockDisciplineRepository.deleteDiscipline(any))
          .thenAnswer((_) async => Future.value());

      await controller.deleteDiscipline(1);

      expect(controller.disciplines.length, 0);
      verify(mockDisciplineRepository.deleteDiscipline(1)).called(1);
    });

    test('readDisciplines should handle errors', () async {
      when(mockDisciplineRepository.readDisciplines())
          .thenThrow(Exception('Failed to fetch disciplines'));

      expect(() => controller.readDisciplines(), throwsA(isA<Exception>()));
      expect(controller.isLoading.value, false);
    });

    test('createDiscipline should handle errors', () async {
      final newDiscipline = Discipline(name: 'History', createdAt: DateTime.now());
      when(mockDisciplineRepository.createDiscipline(any))
          .thenThrow('Já existe uma disciplina com esse nome!|DB Error');

      expect(() => controller.createDiscipline(newDiscipline), throwsA(isA<String>()));
      expect(controller.isLoading.value, false);
    });

    test('updateDiscipline should handle errors', () async {
      final updatedDiscipline = Discipline(id: 1, name: 'Mathematics', createdAt: DateTime.now());
      when(mockDisciplineRepository.updateDiscipline(any))
          .thenThrow('Erro ao atualizar disciplina!|DB Error');

      expect(() => controller.updateDiscipline(updatedDiscipline), throwsA(isA<String>()));
      expect(controller.isLoading.value, false);
    });

    test('deleteDiscipline should handle errors', () async {
      when(mockDisciplineRepository.deleteDiscipline(any))
          .thenThrow('Erro ao deletar disciplina!|DB Error');

      expect(() => controller.deleteDiscipline(1), throwsA(isA<String>()));
      expect(controller.isLoading.value, false);
    });
  });
}