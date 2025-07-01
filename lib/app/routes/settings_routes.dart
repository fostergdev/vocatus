import 'package:get/get.dart';
import 'package:vocatus/app/modules/settings/settings_bindings.dart';
import 'package:vocatus/app/modules/settings/settings_page.dart';

class SettingsRoutes {
  SettingsRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/settings',
      page:() => SettingsPage(),
      binding: SettingsBindings(),
    )
  ];
}
