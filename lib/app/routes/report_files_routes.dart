import 'package:get/get.dart';
import 'package:vocatus/app/modules/report_files/report_classe_details/report_classe_details_bindings.dart';
import 'package:vocatus/app/modules/report_files/report_classe_details/report_classe_details_page.dart';
import 'package:vocatus/app/modules/report_files/report_student_details/report_student_details_bindings.dart';
import 'package:vocatus/app/modules/report_files/report_student_details/report_student_details_page.dart';

class ReportFilesRoutes {
  ReportFilesRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/report_student_details',
      page: () => ReportStudentDetailsPage(),
      binding: ReportStudentDetailsBindings(),
    ),

    GetPage(
      name: '/report_classe_details',
      page: () => ReportClasseDetailsPage(),
      binding: ReportClasseDetailsBindings(),
    ),
  ];
}
