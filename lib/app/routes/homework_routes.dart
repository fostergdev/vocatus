import 'package:get/get.dart';
import 'package:vocatus/app/modules/homework/homework_binding.dart';
import 'package:vocatus/app/modules/homework/homework_page.dart';
import 'package:vocatus/app/modules/homework/homework_select_binding.dart';
import 'package:vocatus/app/modules/homework/homework_select_page.dart';

class HomeworkRoutes {
  HomeworkRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/homework/select',
      page: () => HomeworkSelectPage(),
      binding: HomeworkSelectBinding(),
    ),
    GetPage(
      name: '/homework/home',
      page: () => HomeworkPage(),
      binding: HomeworkBinding(),
    ),
  ];
}
