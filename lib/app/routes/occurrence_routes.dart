import 'package:get/get.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_bindings.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_page.dart';


class OccurrenceRoutes {
  static const occurrence = '/occurrence';


  static List<GetPage> routes = [
    GetPage(
      name: occurrence,
      page: () => const OccurrencePage(),
      binding: OccurrenceBindings(),
    ),
  ];
}
