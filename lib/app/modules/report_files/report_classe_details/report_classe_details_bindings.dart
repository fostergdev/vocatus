import 'package:get/get.dart';
import './report_classe_details_controller.dart';

class ReportClasseDetailsBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(ReportClasseDetailsController());
    }
}