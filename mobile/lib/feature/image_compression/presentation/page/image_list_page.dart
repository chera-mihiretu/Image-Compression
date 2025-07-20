import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/cores/constants/app_theme.dart';
import 'package:mobile/cores/utils/file_utils.dart';
import 'package:mobile/cores/widgets/empty_state_widget.dart';
import 'package:mobile/cores/widgets/image_preview_dialog.dart';
import 'package:mobile/cores/widgets/loading_widget.dart';
import 'package:mobile/cores/widgets/upload_loading_dialog.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/auth/presentation/page/settings_page.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/presentation/bloc/image_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/page/preview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({super.key});
  static const routeName = '/images';

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _totalImages = '0';
  String _storageUsed = '0 B';
  String _avgQuality = '80%';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _startAnimations();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh settings when dependencies change (e.g., returning from settings page)
    _loadSettings();
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await _slideController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final quality = prefs.getDouble('compression_quality') ?? 0.8;
    setState(() {
      _avgQuality = '${(quality * 100).round()}%';
    });
  }

  Future<void> _updateStats(List<CompressedImage> images) async {
    if (images.isEmpty) {
      setState(() {
        _totalImages = '0';
        _storageUsed = '0 B';
      });
      return;
    }

    // Update total images count
    setState(() {
      _totalImages = images.length.toString();
    });

    // Calculate storage used by compressed images
    try {
      final compressedPaths = images.map((img) => img.compressedPath).toList();
      final storageUsed = await FileUtils.calculateTotalStorageUsed(
        compressedPaths,
      );

      setState(() {
        _storageUsed = storageUsed;
      });
    } catch (e) {
      setState(() {
        _storageUsed = '0 B';
      });
    }
  }

  void _showPreviewDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImagePreviewDialog(
        imagePath: imagePath,
        onCompress: () {
          Navigator.of(context).pop();
          context.read<ImageBloc>().add(ImageCompressRequested(imagePath));
        },
        onCancel: () {
          Navigator.of(context).pop();
          // Reset the state
          context.read<ImageBloc>().add(const ImageHistoryRequested());
        },
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UploadLoadingDialog(),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ImageBloc>().add(const ImageHistoryRequested());
          _loadSettings();
        },
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.backgroundColor,
        child: BlocListener<ImageBloc, ImageState>(
          listener: (context, state) {
            // Show preview dialog when needed
            if (state.showPreview && state.selectedImagePath != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showPreviewDialog(context, state.selectedImagePath!);
              });
            }

            // Show loading dialog during compression only (not during history loading)
            if (state.isCompressing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showLoadingDialog(context);
              });
            } else {
              // Hide loading dialog when not compressing
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 80,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppTheme.surfaceColor,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.compress,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Professional',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        'Image Compression',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pushNamed(SettingsPage.routeName),
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                          const AuthSignOutRequested(),
                                        );
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed('/login');
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stats Section
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.image,
                                  title: 'Total Images',
                                  value: _totalImages,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.storage,
                                  title: 'Storage Used',
                                  value: _storageUsed,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.speed,
                                  title: 'Quality Setting',
                                  value: _avgQuality,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Images Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: BlocBuilder<ImageBloc, ImageState>(
                      builder: (context, state) {
                        // Update stats when images change
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _updateStats(state.images);
                        });

                        if (state.isLoadingHistory && state.images.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: PrimaryLoadingWidget(
                                  message: 'Loading your images...',
                                  size: 50,
                                ),
                              ),
                            ),
                          );
                        }

                        if (state.images.isEmpty) {
                          return SliverToBoxAdapter(
                            child: NoImagesEmptyState(
                              onAddImage: () => context.read<ImageBloc>().add(
                                const ImagePickRequested(fromCamera: false),
                              ),
                            ),
                          );
                        }

                        return SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = state.images[index];
                            return SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildImageCard(item, context),
                              ),
                            );
                          }, childCount: state.images.length),
                        );
                      },
                    ),
                  ),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              // Show loading overlay for history loading
              BlocBuilder<ImageBloc, ImageState>(
                builder: (context, state) {
                  if (state.isLoadingHistory) {
                    return Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),

      // Enhanced Floating Action Buttons
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => context.read<ImageBloc>().add(
                    const ImagePickRequested(fromCamera: true),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  label: Text(
                    'Camera',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => context.read<ImageBloc>().add(
                    const ImagePickRequested(fromCamera: false),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  label: Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageCard(dynamic item, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(PreviewPage.routeName, arguments: item.compressedPath),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: FileImage(File(item.compressedPath)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Image Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Compressed',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image ${item.hashCode.toString().substring(0, 6)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
