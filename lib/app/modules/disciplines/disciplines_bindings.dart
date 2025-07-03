import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/repositories/disciplines/discipline_repository.dart';
import './disciplines_controller.dart';

class DisciplinesBindings implements Bindings {
    @override
    void dependencies() {
        Get.put<DisciplineRepository>(DisciplineRepository(DatabaseHelper.instance));
        Get.put<DisciplinesController>(DisciplinesController(Get.find<DisciplineRepository>()));
    }
}