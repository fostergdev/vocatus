import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vocatus/app/modules/settings/settings_controller.dart';
import 'package:vocatus/app/routes/attendance_routes.dart';
import 'package:vocatus/app/routes/classes_routes.dart';
import 'package:vocatus/app/routes/disciplines_routes.dart';
import 'package:vocatus/app/routes/home_routes.dart';
import 'package:vocatus/app/routes/homework_routes.dart';
import 'package:vocatus/app/routes/occurrence_routes.dart';
import 'package:vocatus/app/routes/reports_routes.dart';
import 'package:vocatus/app/routes/schedule_routes.dart';
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
        final Color seedColor = settingsController.primaryColor.value;

        return GetMaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          getPages: [
            ...HomeRoutes.routers,
            ...DisciplinesRoutes.routers,
            ...ClassesRoutes.routers,
            ...StudentsRoutes.routers,
            ...ScheduleRoutes.routers,
            ...AttendanceRoutes.routers,
            ...HomeworkRoutes.routers,
            ...OccurrenceRoutes.routes,
            ...ReportsRoutes.routers,
            ...SettingsRoutes.routers,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Vocatus',
          
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: seedColor,
              foregroundColor: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: seedColor,
              foregroundColor: Colors.white,
            ),
          ),

          themeMode: settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}