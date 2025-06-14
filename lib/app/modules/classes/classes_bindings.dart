import 'package:get/get.dart';
import './classes_controller.dart';

class ClassesBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(ClassesController());
    }
}