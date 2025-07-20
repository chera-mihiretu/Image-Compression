import 'package:flutter/material.dart';
import 'package:mobile/cores/constants/app_theme.dart';

class UploadLoadingDialog extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const UploadLoadingDialog({
    super.key,
    this.message = 'Compressing image...',
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation or Success Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isSuccess ? null : AppTheme.primaryGradient,
                color: isSuccess ? AppTheme.successColor : null,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: isSuccess
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              isSuccess ? 'Image Compressed Successfully!' : message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              isSuccess
                  ? 'Your image has been saved locally'
                  : 'Please wait while we compress your image',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
