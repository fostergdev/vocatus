import 'package:get/get.dart';
import 'package:vocatus/app/modules/grade/grade_controller.dart';


class GradeBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(GradesController());
    }
}