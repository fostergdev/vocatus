import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/models/classe.dart';
import './occurrence_select_controller.dart';

class OccurrenceSelectPage extends GetView<OccurrenceSelectController> {
  const OccurrenceSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecionar Turma - Ocorrências',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor.withValues(alpha: .9),
                Constants.primaryColor,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.white,
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (controller.availableClasses.isEmpty) {
                  return Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhuma turma ativa encontrada',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certifique-se de que existem turmas cadastradas e ativas.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
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
                  labelBuilder: (classe) => '${classe.name} (${classe.schoolYear})',
                  onChanged: (classe) => controller.selectedClasse.value = classe,
                  hint: 'Selecione uma turma',
                );
              }),
              
              const SizedBox(height: 32),
              
              // Lista de chamadas da turma selecionada
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.selectedClasse.value == null) {
                    return const Center(
                      child: Text(
                        'Selecione uma turma para visualizar as chamadas disponíveis',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  if (controller.availableAttendances.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma chamada encontrada para esta turma',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
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
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: Constants.primaryColor,
                            ),
                          ),
                          title: Text(
                            'Chamada - ${controller.formatDate(attendance.date)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            attendance.content?.isNotEmpty == true 
                                ? attendance.content!
                                : 'Sem conteúdo registrado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => controller.navigateToOccurrences(attendance),
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
