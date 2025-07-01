import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/models/classe.dart';
import './homework_select_controller.dart';

class HomeworkSelectPage extends GetView<HomeworkSelectController> {
  const HomeworkSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecionar Turma - Tarefas',
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
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme), // Passa colorScheme e textTheme
          _buildFilters(colorScheme, textTheme), // Passa colorScheme e textTheme
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
              }
              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); // Passa colorScheme e textTheme
              }
              return _buildClassesList(colorScheme, textTheme); // Passa colorScheme e textTheme
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione uma turma para gerenciar suas tarefas',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.filteredClasses.length} turma(s) disponível(eis)',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto de contagem
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.searchController,
                  hintText: 'Buscar turma...',
                  onChanged: (value) => controller.searchClasses(value),
                  // CustomTextField já cuida das cores de tema internamente
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 140,
                child: Obx(() => CustomDrop<int>(
                  items: controller.getAvailableYears(),
                  value: controller.selectedYear.value,
                  labelBuilder: (year) => controller.getYearDisplayText(year),
                  onChanged: (year) => controller.changeYear(year!),
                  hint: 'Ano',
                  // CustomDrop já cuida das cores de tema internamente
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma turma encontrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou criar uma nova turma',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do texto
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList(ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredClasses.length,
      itemBuilder: (context, index) {
        final classe = controller.filteredClasses[index];
        return _buildClasseCard(classe, colorScheme, textTheme); // Passa colorScheme e textTheme
      },
    );
  }

  Widget _buildClasseCard(Classe classe, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      shadowColor: colorScheme.shadow.withOpacity(0.1), // Sombra
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.selectClasse(classe),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  color: colorScheme.primary, // Cor do ícone
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classe.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface, // Cor do nome da turma
                      ),
                    ),
                    if (classe.description != null && classe.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        classe.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant, // Cor da descrição
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: colorScheme.onSurfaceVariant, // Cor do ícone de calendário
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ano: ${classe.schoolYear}',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant, // Cor do texto do ano
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor da seta
              ),
            ],
          ),
        ),
      ),
    );
  }
}