import 'package:get/get.dart';
import './disciplines_controller.dart';

class DisciplinesBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(DisciplinesController());
    }
}