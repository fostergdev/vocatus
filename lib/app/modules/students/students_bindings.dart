import 'package:get/get.dart';
import './students_controller.dart';

class StudentsBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(StudentsController());
    }
}