import 'package:get/get.dart';
import './homework_select_controller.dart';

class HomeworkSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeworkSelectController>(
      () => HomeworkSelectController(),
    );
  }
}
