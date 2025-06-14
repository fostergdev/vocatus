import 'package:get/get.dart';
import 'package:vocatus/app/modules/classes/classes_page.dart';
import 'package:vocatus/app/modules/classes/classes_bindings.dart';


class ClassesRoutes {
  ClassesRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/classes/home',
      page:() => ClassesPage(),
      binding: ClassesBindings(),
    )
  ];
}
