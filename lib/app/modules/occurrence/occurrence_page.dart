import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './occurrence_controller.dart';

class OccurrencePage extends GetView<OccurrenceController> {
  const OccurrencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ocorrências',
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
                colorScheme.primary.withValues(alpha: 0.9),
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        } else if (controller.attendance.value == null) {
          return Center(
            child: Text(
              'Nenhuma chamada selecionada.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turma: ${controller.attendance.value!.classe?.name ?? 'N/A'}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(controller.attendance.value!.date)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.groupedOccurrences.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma ocorrência registrada para esta chamada.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.groupedOccurrences.length,
                        itemBuilder: (context, index) {
                          final type = controller.groupedOccurrences.keys
                              .elementAt(index);
                          final occurrencesOfType =
                              controller.groupedOccurrences[type]!;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: colorScheme.surface,
                            child: ExpansionTile(
                              title: Text(
                                type,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              children: occurrencesOfType.map((occurrence) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Descrição: ${occurrence['description'] ?? 'Sem descrição'}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Aluno: ${occurrence['student_name'] ?? 'Geral'}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Data: ${occurrence['date'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(occurrence['date'])) : 'Data não informada'}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const Divider(height: 20),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
      }),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showAddOccurrenceDialog(context),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  void _showAddOccurrenceDialog(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        return AlertDialog(
          title: Text(
            'Registrar Ocorrência',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: controller.selectedOccurrenceType.value,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Ocorrência',
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items:
                        <String>[
                          'Comportamento',
                          'Saúde',
                          'Material',
                          'Outros',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedOccurrenceType.value = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      'Ocorrência Geral (para toda a turma)',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    value: controller.isGeneralOccurrence.value,
                    onChanged: (bool? value) {
                      controller.isGeneralOccurrence.value = value ?? false;
                      if (controller.isGeneralOccurrence.value) {
                        controller.selectedStudents.clear();
                      }
                    },
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                  ),
                  if (!controller.isGeneralOccurrence.value) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Alunos Envolvidos:',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.studentsInClass.length,
                        itemBuilder: (context, index) {
                          final student = controller.studentsInClass[index];
                          return Obx(
                            () => CheckboxListTile(
                              title: Text(
                                student.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              value: controller.selectedStudents.contains(
                                student,
                              ),
                              onChanged: (bool? selected) {
                                controller.toggleStudentSelection(student);
                              },
                              activeColor: colorScheme.primary,
                              checkColor: colorScheme.onPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                controller.descriptionController.clear();
                controller.selectedStudents.clear();
                controller.isGeneralOccurrence.value = false;
              },
              child: Text(
                'Cancelar',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.addOccurrence();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'Registrar',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
