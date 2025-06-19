import 'package:get/get.dart';
import 'package:flutter/material.dart';
import './attendance_register_controller.dart';

class AttendanceRegisterPage extends GetView<AttendanceRegisterController> {
    
    const AttendanceRegisterPage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('AttendanceRegisterPage'),),
            body: Container(),
        );
    }
}