import 'package:get/get.dart';
import 'package:vocatus/app/modules/students/students_reports_controller.dart';

class StudentsReportsBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(StudentsReportsController());
  }
}
