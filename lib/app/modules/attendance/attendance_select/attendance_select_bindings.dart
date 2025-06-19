import 'package:get/get.dart';
import './attendance_select_controller.dart';

class AttendanceSelectBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(AttendanceSelectController());
    }
}