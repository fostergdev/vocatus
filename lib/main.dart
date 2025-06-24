import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocatus/app/routes/attendance_routes.dart';
import 'package:vocatus/app/routes/classes_routes.dart';
import 'package:vocatus/app/routes/disciplines_routes.dart';
import 'package:vocatus/app/routes/grades_routers.dart';
import 'package:vocatus/app/routes/history_routes.dart';
import 'package:vocatus/app/routes/home_routes.dart';
import 'package:vocatus/app/routes/report_files_routes.dart';
import 'package:vocatus/app/routes/reports_routes.dart';
import 'package:vocatus/app/routes/students_routes.dart';

void main() {
  runApp(VocatusApp());
}

class VocatusApp extends StatelessWidget {
  const VocatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: [
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
        ...HistoryRoutes.routers,
        ...ReportFilesRoutes.routers,
        ...ReportsRoutes.routers,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Vocatus',
      theme: ThemeData(useMaterial3: true),
    );
  }
}
