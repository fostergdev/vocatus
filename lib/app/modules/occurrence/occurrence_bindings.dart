import 'package:get/get.dart';
import './occurrence_controller.dart';

class OccurrenceBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(OccurrenceController());
    }
}