import 'package:get/get.dart';
import 'package:vocatus/app/modules/reports/reports_bindings.dart';
import 'package:vocatus/app/modules/reports/reports_page.dart';

class ReportsRoutes {
  ReportsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/reports/home',
      page: () => ReportsPage(),
      binding: ReportsBindings(),
    ),
  ];
}
