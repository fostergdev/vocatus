import 'package:get/get.dart';
import 'package:vocatus/app/modules/schedule/schedule_bindings.dart';
import 'package:vocatus/app/modules/schedule/schedule_page.dart';

class ScheduleRoutes {
  ScheduleRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/schedule/home',
      page:() => const SchedulePage(),
      binding: ScheduleBindings(),
    )
  ];
}
