import 'package:get/get.dart';
import 'package:vocatus/app/modules/disciplines/disciplines_bindings.dart';
import 'package:vocatus/app/modules/disciplines/disciplines_page.dart';

class DisciplinesRoutes {
  DisciplinesRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/disciplines/home',
      page:() => DisciplinesPage(),
      binding: DisciplinesBindings(),
    )
  ];
}
