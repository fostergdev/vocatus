import 'package:get/get.dart';
import 'package:vocatus/app/modules/home/home_bindings.dart';
import 'package:vocatus/app/modules/home/home_page.dart';

class HomeRoutes {
  HomeRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/',
      page: () => HomePage(),
      binding: HomeBindings(),
    )
  ];
}
