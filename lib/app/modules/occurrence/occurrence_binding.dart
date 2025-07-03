import 'package:get/get.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_controller.dart';

class OccurrenceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OccurrenceController>(() => OccurrenceController());
  }
}
