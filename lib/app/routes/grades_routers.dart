import 'package:get/get.dart';
import 'package:vocatus/app/modules/grade/grade_bindings.dart';
import 'package:vocatus/app/modules/grade/grade_page.dart';

class GradesRoutes {
  GradesRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/grade/home',
      page:() => GradesPage(),
      binding: GradeBindings(),
    )
  ];
}
