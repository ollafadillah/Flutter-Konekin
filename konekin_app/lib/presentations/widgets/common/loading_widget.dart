import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;
  
  const LoadingWidget({super.key, this.message, this.fullScreen = false});
  
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
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