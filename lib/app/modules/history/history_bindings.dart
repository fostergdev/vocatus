import 'package:get/get.dart';
import './history_controller.dart';

class HistoryBindings implements Bindings {
    @override
    void dependencies() {
        Get.put(HistoryController());
    }
}