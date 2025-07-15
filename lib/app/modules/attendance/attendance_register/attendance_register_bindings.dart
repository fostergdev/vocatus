import 'package:get/get.dart';
import './attendance_register_controller.dart';

class AttendanceRegisterBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AttendanceRegisterController());
  }
}