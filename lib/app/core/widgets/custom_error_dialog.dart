import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomErrorDialog extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onOk;

  const CustomErrorDialog({
    super.key,
    this.title,
    required this.message,
    this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onOk ?? () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}