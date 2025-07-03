import 'package:get/get.dart';
import 'package:vocatus/app/modules/schedule/schedule_controller.dart';


class ScheduleBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(ScheduleController());
    }
}