import 'package:get/get.dart';
import 'package:vocatus/app/modules/reports/student_unified_report/student_unified_report_controller.dart';

class StudentUnifiedReportBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentUnifiedReportController>(
      () => StudentUnifiedReportController(),
    );
  }
}
