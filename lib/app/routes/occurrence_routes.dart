import 'package:get/get.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_binding.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_page.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_select_binding.dart';
import 'package:vocatus/app/modules/occurrence/occurrence_select_page.dart';

class OccurrenceRoutes {
  static const occurrence = '/occurrence';
  static const occurrenceSelect = '/occurrence/select';

  static List<GetPage> routes = [
    GetPage(
      name: occurrence,
      page: () => const OccurrencePage(),
      binding: OccurrenceBinding(),
    ),
    GetPage(
      name: occurrenceSelect,
      page: () => const OccurrenceSelectPage(),
      binding: OccurrenceSelectBinding(),
    ),
  ];
}
