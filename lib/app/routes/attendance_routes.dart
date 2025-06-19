import 'package:get/get.dart';
import 'package:vocatus/app/modules/attendance/attendance_select/attendance_select_bindings.dart';
import 'package:vocatus/app/modules/attendance/attendance_select/attendance_select_page.dart';



class AttendanceRoutes {
  AttendanceRoutes._();
  static final routers = <GetPage>[
    GetPage(
      name: '/attendance/select',
      page:() => AttendanceSelectPage(),
      binding: AttendanceSelectBindings(),
    )
  ];
}
