import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/modules/settings/settings_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Importe o pacote

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Seção de Modo do Tema ---
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo do Tema',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        controller.isDarkMode.value ? 'Modo Escuro' : 'Modo Claro',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      secondary: Icon(
                        controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                        color: colorScheme.primary,
                      ),
                      value: controller.isDarkMode.value,
                      onChanged: (bool value) {
                        controller.toggleThemeMode(value);
                      },
                      activeColor: colorScheme.primary,
                      inactiveThumbColor: colorScheme.onSurfaceVariant,
                      inactiveTrackColor: colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Seção de Cor Primária ---
          Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cor Primária',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cor Atual:',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: controller.primaryColor.value,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline, width: 2),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Chama a nova função simplificada para mostrar o Color Picker
                            _showColorPickerBottomSheet(context, colorScheme);
                          },
                          icon: Icon(Icons.color_lens, color: colorScheme.onPrimary),
                          label: Text('Mudar Cor', style: TextStyle(color: colorScheme.onPrimary)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Função _showColorPickerBottomSheet simplificada para BlockPicker ---
  void _showColorPickerBottomSheet(BuildContext context, ColorScheme colorScheme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: colorScheme.surface, // Fundo do bottom sheet
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para o conteúdo se ajustar
          children: [
            Text(
              'Selecione uma Cor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // --- AQUI ESTÁ O BlockPicker ---
            SingleChildScrollView( // Para garantir que o picker seja rolável se houver muitas cores
              child: BlockPicker(
                pickerColor: controller.primaryColor.value, // Cor inicial do picker
                onColorChanged: (color) {
                  controller.setPrimaryColor(color); // Define a nova cor
                  Get.back(); // Fecha o bottom sheet IMEDIATAMENTE ao selecionar
                },
                availableColors: const [ // Cores que serão exibidas em blocos
                  Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                  Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                  Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                  Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
                  Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
                  // Adicione ou remova cores conforme sua paleta desejada
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Não precisamos de botões "Confirmar" ou "Fechar"
            // pois o bottom sheet fecha automaticamente.
          ],
        ),
      ),
      isScrollControlled: true, // Permite que o bottom sheet seja maior se necessário
    );
  }
}