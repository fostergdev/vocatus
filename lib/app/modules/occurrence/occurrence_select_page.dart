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
            color: colorScheme.onPrimary, // Texto da AppBar
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Usa a cor primária do tema
                colorScheme.primary, // Usa a cor primária do tema
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Cores do gradiente de fundo, usando o colorScheme
            colors: [
              colorScheme.primary.withOpacity(0.05), // Um tom bem claro da cor primária
              colorScheme.background, // A cor de fundo principal do tema
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown de turmas
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
                    ),
                  );
                }

                if (controller.availableClasses.isEmpty) {
                  return Card(
                    color: colorScheme.errorContainer, // Fundo suave para aviso/erro
                    surfaceTintColor: colorScheme.onErrorContainer, // Tinta de elevação
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: colorScheme.error, // Cor do ícone de aviso/erro
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhuma turma ativa encontrada',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onErrorContainer, // Cor do texto
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certifique-se de que existem turmas cadastradas e ativas.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer.withOpacity(0.8), // Cor do texto
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
                  // CustomDrop já está configurado para usar o tema
                );
              }),

              const SizedBox(height: 32),

              // Lista de chamadas da turma selecionada
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
                  }

                  if (controller.selectedClasse.value == null) {
                    return Center(
                      child: Text(
                        'Selecione uma turma para visualizar as chamadas disponíveis',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant, // Cor do texto
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
                            color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma chamada encontrada para esta turma',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant, // Cor do texto
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
                        color: colorScheme.surface, // Fundo do Card
                        surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: colorScheme.primary, // Cor do ícone
                            ),
                          ),
                          title: Text(
                            'Chamada - ${controller.formatDate(attendance.date)}',
                            style: textTheme.titleSmall?.copyWith( // Estilo do título
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface, // Cor do texto do título
                            ),
                          ),
                          subtitle: Text(
                            attendance.content?.isNotEmpty == true
                                ? attendance.content!
                                : 'Sem conteúdo registrado',
                            style: textTheme.bodyMedium?.copyWith( // Estilo do subtítulo
                              color: colorScheme.onSurfaceVariant, // Cor do texto do subtítulo
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor da seta
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