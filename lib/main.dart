import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vocatus/app/modules/settings/settings_controller.dart';
// Importe todas as suas rotas aqui
import 'package:vocatus/app/routes/attendance_routes.dart';
import 'package:vocatus/app/routes/classes_routes.dart';
import 'package:vocatus/app/routes/disciplines_routes.dart';
import 'package:vocatus/app/routes/grades_routers.dart';
import 'package:vocatus/app/routes/home_routes.dart';
import 'package:vocatus/app/routes/homework_routes.dart';
import 'package:vocatus/app/routes/occurrence_routes.dart';
import 'package:vocatus/app/routes/reports_routes.dart';
import 'package:vocatus/app/routes/settings_routes.dart';
import 'package:vocatus/app/routes/students_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(SettingsController()); 
  
  runApp(const VocatusApp());
}

class VocatusApp extends StatelessWidget {
  const VocatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    return Obx(
      () {
        // Define a cor semente para o tema claro e escuro
        final Color seedColor = settingsController.primaryColor.value;

        return GetMaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          getPages: [
            ...HomeRoutes.routers,
            ...DisciplinesRoutes.routers,
            ...ClassesRoutes.routers,
            ...StudentsRoutes.routers,
            ...GradesRoutes.routers,
            ...AttendanceRoutes.routers,
            ...HomeworkRoutes.routers,
            ...OccurrenceRoutes.routes,
            ...ReportsRoutes.routers,
            ...SettingsRoutes.routers,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Vocatus',
          
          // --- CONFIGURAÇÃO DO TEMA CLARO ---
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light, // Tema claro
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: seedColor, // Cor da AppBar no tema claro
              foregroundColor: Colors.white,
            ),
            // Adicione outras customizações para o tema claro aqui
          ),

          // --- CONFIGURAÇÃO DO TEMA ESCURO ---
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark, // Tema escuro
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: seedColor, // Cor da AppBar no tema escuro
              foregroundColor: Colors.white,
            ),
            // Adicione outras customizações para o tema escuro aqui
          ),

          // --- AQUI SELECIONAMOS QUAL TEMA USAR ---
          themeMode: settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}