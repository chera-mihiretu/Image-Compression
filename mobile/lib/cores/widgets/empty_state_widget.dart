import 'package:flutter/material.dart';
import 'package:mobile/cores/constants/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.largePadding,
      margin: AppTheme.standardPadding,
      decoration: AppTheme.cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppTheme.primaryColor,
            ),
          ),

          SizedBox(height: AppTheme.spacingL),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppTheme.spacingM),

          // Subtitle
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // Action Button
          if (actionText != null && onActionPressed != null) ...[
            SizedBox(height: AppTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Predefined empty state widgets
class NoImagesEmptyState extends StatelessWidget {
  final VoidCallback? onAddImage;

  const NoImagesEmptyState({super.key, this.onAddImage});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.photo_library_outlined,
      title: 'No Images Yet',
      subtitle:
          'Start by uploading your first image to compress and save storage space.',
      actionText: 'Add Your First Image',
      onActionPressed: onAddImage,
      iconColor: AppTheme.primaryColor,
    );
  }
}

class NoResultsEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NoResultsEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      subtitle:
          'No images match "$searchQuery". Try adjusting your search terms.',
      actionText: 'Clear Search',
      onActionPressed: onClearSearch,
      iconColor: AppTheme.warningColor,
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorEmptyState({super.key, required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      subtitle: errorMessage,
      actionText: 'Try Again',
      onActionPressed: onRetry,
      iconColor: AppTheme.errorColor,
    );
  }
}

class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      subtitle:
          'Please check your connection and try again to access your images.',
      actionText: 'Retry',
      onActionPressed: onRetry,
      iconColor: AppTheme.infoColor,
    );
  }
}
