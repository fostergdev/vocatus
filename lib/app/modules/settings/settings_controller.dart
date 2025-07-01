import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();
  final String _primaryColorKey = 'primaryColor';
  final String _themeModeKey = 'themeMode'; // Chave para o modo do tema

  // Variável observável para a cor primária
  final Rx<Color> primaryColor = Colors.blue.obs; // Cor padrão inicial

  // Variável observável para o modo escuro (true = escuro, false = claro)
  final Rx<bool> isDarkMode = false.obs; // Padrão: tema claro

  @override
  void onInit() {
    super.onInit();
    _loadPrimaryColor();
    _loadThemeMode(); // Carrega o modo do tema ao iniciar
  }

  // --- Métodos para Cor Primária ---
  void _loadPrimaryColor() {
    final int? colorValue = _box.read(_primaryColorKey);
    if (colorValue != null) {
      primaryColor.value = Color(colorValue);
    }
  }

  void setPrimaryColor(Color color) {
    primaryColor.value = color;
    _box.write(_primaryColorKey, color.value);
    print('Cor primária alterada para: ${color.value} (no SettingsController)');
  }

  // --- Métodos para Modo do Tema ---
  void _loadThemeMode() {
    // Lê do GetStorage. Se não houver, usa false (claro) como padrão.
    final bool? storedIsDarkMode = _box.read(_themeModeKey);
    isDarkMode.value = storedIsDarkMode ?? false;
    // Aplica o tema imediatamente ao carregar
    _applyThemeMode(isDarkMode.value);
  }

  void toggleThemeMode(bool value) {
    isDarkMode.value = value;
    _box.write(_themeModeKey, value); // Salva a preferência
    _applyThemeMode(value); // Aplica o novo tema
    print('Modo escuro alterado para: $value (no SettingsController)');
  }

  void _applyThemeMode(bool dark) {
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }
}