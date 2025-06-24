import 'package:get/get.dart';
import 'package:vocatus/app/modules/history/history_bindings.dart';
import 'package:vocatus/app/modules/history/history_page.dart';

class HistoryRoutes {
  HistoryRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/history/home',
      page:() => HistoryPage(),
      binding: HistoryBindings(),
    )
  ];
}
