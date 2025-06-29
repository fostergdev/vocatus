import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart'; // Importe CustomDialog para a mensagem de erro de ano

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relatórios de Turmas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        actions: [
          Obx(() {
            final years =
                controller.yearsByTab[0] ?? []; // Assume tab 0 for classes
            if (years.isEmpty) {
              return IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () {
                  Get.dialog(
                    CustomDialog(
                      // Usando CustomDialog para aprimorar a estética
                      title: 'Sem Anos Disponíveis',
                      icon: Icons.info_outline,
                      content: const Text(
                        'Não há anos com relatórios de turmas para filtro.',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return CustomPopupMenu(
              textAlign: TextAlign.center,
              iconColor: Colors.white,
              icon: Icons.calendar_today,

              items: [
                for (var year in years)
                  CustomPopupMenuItem(
                    label: year.toString(),
                    onTap: () {
                      controller.selectedFilterYear.value = year;
                      controller.onYearSelected(0, year);
                    },
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => TextField(
                controller: controller.searchInputController,
                onChanged: controller.onSearchTextChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar turmas por nome...', // Hint mais específico
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.grey[100], // Cor de fundo mais clara
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Bordas mais arredondadas
                    borderSide: BorderSide.none, // Remover borda sólida
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Estilo da borda quando não focado
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Estilo da borda quando focado
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Constants.primaryColor,
                      width: 2.0,
                    ), // Cor primária ao focar
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: controller.searchText.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.searchText.value = '';
                            controller.searchInputController.clear();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0, // Ajuste para mais espaço
                    horizontal: 16.0,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ), // Ajuste de fonte
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final data = controller.filteredReportClasses;
              if (controller.isLoadingAttendance.value) {
                // Adiciona um indicador de carregamento aqui também
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Constants.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carregando relatórios...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (data.isEmpty &&
                  controller.searchText.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nenhuma turma encontrada com este termo de busca.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum relatório de turmas disponível para o ano ${controller.selectedFilterYear.value}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verifique outro ano ou adicione turmas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final classe = data[index];
                  final bool isActive =
                      classe.active ?? false; // Assuming 'active' property
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 4, // Aumentar elevação
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Mais arredondado
                    ),
                    shadowColor: Colors.purple.shade100.withOpacity(
                      0.6,
                    ), // Sombra suave
                    child: ExpansionTile(
                      collapsedBackgroundColor: isActive
                          ? Colors.white
                          : Colors
                                .grey
                                .shade50, // Cor de fundo diferente para inativos
                      backgroundColor: Colors.white,
                      iconColor: Constants.primaryColor,
                      collapsedIconColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      trailing: Icon(
                        Icons
                            .keyboard_arrow_down_rounded, // Ícone de seta para baixo mais suave
                        color: Constants.primaryColor,
                        size: 30,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? Constants.primaryColor.withOpacity(0.1)
                            : Colors
                                  .grey
                                  .shade100, // Fundo avatar baseado no status
                        child: Icon(
                          Icons.school, // Ícone mais cheio
                          color: isActive
                              ? Constants.primaryColor
                              : Colors.grey.shade600,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        classe.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isActive
                              ? Colors.purple.shade900
                              : Colors.grey.shade700,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            isActive ? 'Status: Ativa' : 'Status: Arquivada',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (classe.description != null &&
                              classe.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              classe.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${classe.schoolYear}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            0,
                          ), // Ajuste de padding
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons
                                    .checklist_rtl, // Ícone mais moderno para chamadas
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Ver Chamadas',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Constants.primaryColor, // Cor primária
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Mais arredondado
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, // Mais padding
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ), // Ajuste de fonte
                              ),
                              onPressed: () {
                                Get.toNamed(
                                  '/reports/attendance-report',
                                  arguments: {
                                    'classId': classe.id,
                                    'className': classe.name,
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(
                          indent: 16,
                          endIndent: 16,
                          height: 24,
                        ), // Separador mais robusto
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ), // Ajuste de padding
                          child: classe.schedules.isEmpty
                              ? Center(
                                  // Centraliza a mensagem
                                  child: Text(
                                    'Nenhum horário cadastrado para esta turma.',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Alinha à esquerda
                                  children: [
                                    const Text(
                                      'Horários da Turma:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...classe.schedules.map((gradeSchedule) {
                                      return Card(
                                        elevation:
                                            0.5, // Menor elevação para itens internos
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ), // Margem menor
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ), // Bordas mais suaves
                                          side: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ), // Borda sutil
                                        ),
                                        child: Padding(
                                          // Adicionar padding ao ListTile para melhor espaçamento
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .access_time, // Ícone para horários
                                                color: Colors.purple.shade400,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _getDayName(
                                                        gradeSchedule.dayOfWeek,
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${Grade.formatTimeDisplay(gradeSchedule.startTimeOfDay)} - ${Grade.formatTimeDisplay(gradeSchedule.endTimeOfDay)}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (gradeSchedule
                                                          .discipline
                                                          ?.name !=
                                                      null &&
                                                  gradeSchedule
                                                      .discipline!
                                                      .name
                                                      .isNotEmpty)
                                                Text(
                                                  gradeSchedule
                                                      .discipline!
                                                      .name,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7: // Mudança aqui: Domingo geralmente é 7 ou 0. Mantendo 7 baseado no seu switch.
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }
}
