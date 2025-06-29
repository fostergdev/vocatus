import 'package:get/get.dart';
import 'occurrence_controller.dart';

class OccurrenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OccurrenceController>(() => OccurrenceController());
  }
}
