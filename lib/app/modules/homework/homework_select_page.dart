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
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme), 
          _buildFilters(colorScheme, textTheme), 
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); 
              }
              if (controller.filteredClasses.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); 
              }
              return _buildClassesList(colorScheme, textTheme); 
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
              color: colorScheme.onSurfaceVariant, 
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.filteredClasses.length} turma(s) disponível(eis)',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, 
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
            color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma turma encontrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, 
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou criar uma nova turma',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
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
        return _buildClasseCard(classe, colorScheme, textTheme); 
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
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.primaryContainer, 
      shadowColor: colorScheme.shadow.withValues(alpha:0.1), 
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
                  color: colorScheme.primary.withValues(alpha:0.1), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  color: colorScheme.primary, 
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
                        color: colorScheme.onSurface, 
                      ),
                    ),
                    if (classe.description != null && classe.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        classe.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant, 
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
                          color: colorScheme.onSurfaceVariant, 
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ano: ${classe.schoolYear}',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant, 
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
                color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}