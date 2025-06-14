import 'package:get/get.dart';
import 'package:vocatus/app/modules/students/students_bindings.dart';
import 'package:vocatus/app/modules/students/students_page.dart';

class StudentsRoutes {
  StudentsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/students/home',
      page: () => StudentsPage(),
      binding: StudentsBindings(),
    ),
  ];
}
