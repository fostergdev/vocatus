import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();
  final String _primaryColorKey = 'primaryColor';
  final String _themeModeKey = 'themeMode';

  final Rx<Color> primaryColor = Color(0xFF2196F3).obs;
  final Rx<bool> isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrimaryColor();
    _loadThemeMode();
  }

  void _loadPrimaryColor() {
    final int? colorValue = _box.read(_primaryColorKey);
    if (colorValue != null) {
      primaryColor.value = Color(colorValue);
    }
  }

  void setPrimaryColor(Color color) {
    primaryColor.value = color;
    _box.write(_primaryColorKey, color.toARGB32());
  }

  void _loadThemeMode() {
    final bool? storedIsDarkMode = _box.read(_themeModeKey);
    isDarkMode.value = storedIsDarkMode ?? false;
    _applyThemeMode(isDarkMode.value);
  }

  void toggleThemeMode(bool value) {
    isDarkMode.value = value;
    _box.write(_themeModeKey, value);
    _applyThemeMode(value);
  }

  void _applyThemeMode(bool dark) {
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }
  
  List<Color> get availableColors => [
    Color(0xFF2196F3), 
    Color(0xFF4CAF50), 
    Color(0xFFF44336), 
    Color(0xFF9C27B0), 
    Color(0xFFFF9800), 
    Color(0xFF795548), 
    Color(0xFF607D8B), 
  ];
}