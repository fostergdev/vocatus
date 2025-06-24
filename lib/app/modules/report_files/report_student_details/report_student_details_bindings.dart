import 'package:get/get.dart';
import './report_student_details_controller.dart';

class ReportStudentDetailsBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(ReportStudentDetailsController());
    }
}