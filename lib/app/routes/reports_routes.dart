import 'package:get/get.dart';
import 'package:vocatus/app/modules/reports/attendance_report_page.dart';
import 'package:vocatus/app/modules/reports/reports_bindings.dart';
import 'package:vocatus/app/modules/reports/reports_page.dart';


import 'package:vocatus/app/modules/reports/reports_students_page.dart';
import 'package:vocatus/app/modules/reports/student_unified_report/student_unified_report_bindings.dart';
import 'package:vocatus/app/modules/reports/student_unified_report/student_unified_report_page.dart';

class ReportsRoutes {
  ReportsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/reports/home',
      page: () => ReportsPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/attendance-grid-report',
      page: () => AttendanceReportPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/students',
      page: () => ReportsStudentsPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/student-unified-report',
      page: () => const StudentUnifiedReportPage(),
      binding: StudentUnifiedReportBindings(),
    ),
/*     GetPage(
      name: '/reports/attendance-report',
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return AttendanceReportPage(
          classId: args['classId'] as int,
          className: args['className'] as String,
        );
      },
      binding: ReportsBindings(),
    ),

    GetPage(
      name: '/reports/schedules-report',
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ClassSchedulesReportPage(
          classId: args['classId'] as int,
          className: args['className'] as String,
        );
      },
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/class-unified',
      page: () => const ClassUnifiedReportPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/homework-report',
      page: () => const ClassHomeworkReportPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
      name: '/reports/attendance-report-class',
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ClassAttendanceReportPage(
          classId: args['classId'] as int,
          className: args['className'] as String,
        );
      },
      binding: ReportsBindings(),
    ), */
  ];
}
