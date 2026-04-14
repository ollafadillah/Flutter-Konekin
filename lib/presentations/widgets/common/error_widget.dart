import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool fullScreen;
  
  const ErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.fullScreen = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
    
    if (fullScreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: child,
      );
    }
    
    return child;
  }
}