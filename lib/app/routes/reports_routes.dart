import 'package:get/get.dart';
import 'package:vocatus/app/modules/reports/reports_bindings.dart';
import 'package:vocatus/app/modules/reports/reports_page.dart';
import 'package:vocatus/app/modules/reports/attendance_report_page.dart';


class ReportsRoutes {
  ReportsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/reports/home',
      page: () => ReportsPage(),
      binding: ReportsBindings(),
    ),
    GetPage(
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
  ];
}
