import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/models/classe.dart';
import './occurrence_select_controller.dart';

class OccurrenceSelectPage extends GetView<OccurrenceSelectController> {
  const OccurrenceSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecionar Turma - Ocorrências',
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
                colorScheme.primary.withValues(alpha:0.9), 
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            
            colors: [
              colorScheme.primary.withValues(alpha:0.05), 
              colorScheme.surface, 
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: colorScheme.primary), 
                    ),
                  );
                }

                if (controller.availableClasses.isEmpty) {
                  return Card(
                    color: colorScheme.errorContainer, 
                    surfaceTintColor: colorScheme.onErrorContainer, 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: colorScheme.error, 
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhuma turma ativa encontrada',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onErrorContainer, 
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certifique-se de que existem turmas cadastradas e ativas.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer.withValues(alpha:0.8), 
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return CustomDrop<Classe>(
                  items: controller.availableClasses,
                  value: controller.selectedClasse.value,
                  labelBuilder: (classe) =>
                      '${classe.name} (${classe.schoolYear})',
                  onChanged: (classe) =>
                      controller.selectedClasse.value = classe,
                  hint: 'Selecione uma turma',
                  
                );
              }),

              const SizedBox(height: 32),

              
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary)); 
                  }

                  if (controller.selectedClasse.value == null) {
                    return Center(
                      child: Text(
                        'Selecione uma turma para visualizar as chamadas disponíveis',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant, 
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (controller.availableAttendances.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma chamada encontrada para esta turma',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant, 
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.availableAttendances.length,
                    itemBuilder: (context, index) {
                      final attendance = controller.availableAttendances[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: colorScheme.surface, 
                        surfaceTintColor: colorScheme.primaryContainer, 
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha:0.1), 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: colorScheme.primary, 
                            ),
                          ),
                          title: Text(
                            'Chamada - ${controller.formatDate(attendance.date)}',
                            style: textTheme.titleSmall?.copyWith( 
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface, 
                            ),
                          ),
                          subtitle: Text(
                            attendance.content?.isNotEmpty == true
                                ? attendance.content!
                                : 'Sem conteúdo registrado',
                            style: textTheme.bodyMedium?.copyWith( 
                              color: colorScheme.onSurfaceVariant, 
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
                          ),
                          onTap: () =>
                              controller.navigateToOccurrences(attendance),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}