import 'package:get/get.dart';
import 'occurrence_select_controller.dart';

class OccurrenceSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OccurrenceSelectController>(() => OccurrenceSelectController());
  }
}
