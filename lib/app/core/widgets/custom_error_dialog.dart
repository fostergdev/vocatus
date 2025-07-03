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
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      
      backgroundColor: colorScheme.errorContainer, 
      surfaceTintColor: colorScheme.error, 

      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Icon(
              Icons.error_outline,
              color: colorScheme.error, 
              size: 48,
            ),
            const SizedBox(height: 16),
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.onErrorContainer, 
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onErrorContainer, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onOk ?? () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error, 
                foregroundColor: colorScheme.onError, 
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}