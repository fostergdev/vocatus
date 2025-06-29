import 'package:get/get.dart';
import 'package:vocatus/app/modules/students/students_bindings.dart';
import 'package:vocatus/app/modules/students/students_page.dart';
import 'package:vocatus/app/modules/students/students_reports_bindings.dart';
import 'package:vocatus/app/modules/students/students_reports_page.dart';
import 'package:vocatus/app/modules/reports/reports_bindings.dart';
import 'package:vocatus/app/modules/reports/student_unified_report_page.dart';

class StudentsRoutes {
  StudentsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/students/home',
      page: () => StudentsPage(),
      binding: StudentsBindings(),
    ),
    GetPage(
      name: '/students/reports',
      page: () => StudentsReportsPage(),
      binding: StudentsReportsBindings(),
    ),
    GetPage(
      name: '/student/unified-report',
      page: () => StudentUnifiedReportPage(),
      binding: ReportsBindings(),
    ),
  ];
}
