import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/constants/constants.dart';
import 'viewimage.dart';
import 'result.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isBarcodeMode = false;
  final ImagePicker _picker = ImagePicker();
  MobileScannerController? _barcodeController;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestAllPermissions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    if (_isBarcodeMode) {
      _scanController.repeat();
    }
  }

  Future<void> _requestAllPermissions() async {
    final cameraGranted = await _requestCameraPermission();
    final galleryGranted = await _requestGalleryPermission();
    if (!mounted) return;
    if (cameraGranted) {
      await _initCamera();
      _startAnimations();
    } else {
      _showEnhancedMessage('Camera permission denied', isError: true);
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<int> _getAndroidVersion() async {
    try {
      final version =
          (await File('/system/build.prop').readAsString())
              .split('\n')
              .firstWhere((line) => line.startsWith('ro.build.version.sdk'))
              .split('=')[1];
      return int.tryParse(version) ?? 32;
    } catch (_) {
      return 32;
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    HapticFeedback.mediumImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    final file = await _cameraController!.takePicture();

    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ViewImagePage(imagePath: file.path),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  ViewImagePage(imagePath: pickedFile.path),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  Future<void> _handleBarcodeScanned(String barcode) async {
    HapticFeedback.heavyImpact();

    // Show scanning feedback
    _showEnhancedMessage('Barcode detected! Processing...', isSuccess: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        _showEnhancedMessage(
          'Token not found. Please login again.',
          isError: true,
        );
        return;
      }

      final uri = Uri.parse(
        'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/produk?barcode=$barcode',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final nutrition = decoded['nutrition'] ?? {};
        final mapped = {
          'nama_makanan':
              decoded['nama_makanan'] ??
              decoded['name'] ??
              decoded['product_name'] ??
              'Unknown Product',
          'image_url': decoded['image_url'] ?? '',
          'nutrition_total': {
            'kalori': nutrition['kalori'] ?? 0,
            'karbohidrat': nutrition['karbohidrat'] ?? 0,
            'protein': nutrition['protein'] ?? 0,
            'lemak': nutrition['lemak'] ?? 0,
          },
        };

        final isZeroNutrition =
            (mapped['nutrition_total']['kalori'] == 0 &&
                mapped['nutrition_total']['karbohidrat'] == 0 &&
                mapped['nutrition_total']['protein'] == 0 &&
                mapped['nutrition_total']['lemak'] == 0);

        if (!mounted) return;

        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ResultPage(
                  foodListText: mapped['nama_makanan'],
                  nutritionResult: [mapped],
                  imagePath: '',
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        );

        if (isZeroNutrition) {
          _showEnhancedMessage(
            'Nutrition not found for this product. Data will be saved with zero nutrition values.',
            isWarning: true,
          );
        }
      } else if (response.statusCode == 401) {
        _showEnhancedMessage(
          'Unauthorized. Please login again.',
          isError: true,
        );
      } else {
        _showEnhancedMessage(
          'Error occurred: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      _showEnhancedMessage('Failed to connect to server: $e', isError: true);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    HapticFeedback.lightImpact();
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  void _showEnhancedMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppColors.error;
      icon = Icons.error_rounded;
    } else if (isSuccess) {
      backgroundColor = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (isWarning) {
      backgroundColor = AppColors.warning;
      icon = Icons.warning_rounded;
    } else {
      backgroundColor = AppColors.info;
      icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeController?.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: AppIcons.sm,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
        title: Text(
          'Smart Scanner',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: AppTexts.bold,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),
        centerTitle: true,
        actions: [
          Container(
                margin: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.white,
                    size: AppIcons.sm,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showHelpDialog();
                  },
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
      body:
          !_isCameraInitialized
              ? _buildLoadingState()
              : AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeController,
                  _slideController,
                ]),
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Camera/Scanner view
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child:
                              _isBarcodeMode
                                  ? Stack(
                                    children: [
                                      MobileScanner(
                                        controller:
                                            _barcodeController ??=
                                                MobileScannerController(),
                                        onDetect: (capture) {
                                          final barcode =
                                              capture.barcodes.first.rawValue;
                                          if (barcode != null) {
                                            _barcodeController?.stop();
                                            _handleBarcodeScanned(barcode);
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                  : CameraPreview(_cameraController!),
                        ),
                      ),

                      // Top gradient overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom controls
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildModeSwitch()
                                      .animate()
                                      .fadeIn(delay: 500.ms)
                                      .slideY(begin: 0.5),
                                  SizedBox(height: AppSpacing.xl),
                                  _buildControlButtons()
                                      .animate()
                                      .fadeIn(delay: 600.ms)
                                      .slideY(begin: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Instructions overlay
                      if (_isBarcodeMode)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          child: _buildInstructionsCard()
                              .animate()
                              .fadeIn(delay: 700.ms)
                              .slideY(begin: -0.3),
                        ),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton('Snap', false),
          _buildModeButton('Barcode', true),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isBarcode) {
    final isSelected = _isBarcodeMode == isBarcode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isBarcodeMode = isBarcode;
          if (_isBarcodeMode) {
            _barcodeController?.start();
            _scanController.repeat();
          } else {
            _barcodeController?.stop();
            _scanController.stop();
          }
        });
      },
      child: AnimatedContainer(
        duration: AppAnimations.medium,
        curve: AppAnimations.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: isSelected ? AppShadows.primaryButton : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBarcode
                  ? Icons.qr_code_scanner_rounded
                  : Icons.camera_alt_rounded,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              size: AppIcons.sm,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? AppTexts.semiBold : AppTexts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery button
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.photo_library_rounded,
              color: AppColors.white,
              size: AppIcons.lg,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _pickFromGallery();
            },
          ),
        ),

        // Main capture/scan button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: GestureDetector(
                onTap: _isBarcodeMode ? null : _captureImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        _isBarcodeMode
                            ? AppColors.white.withOpacity(0.3)
                            : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow:
                        _isBarcodeMode
                            ? null
                            : [
                              BoxShadow(
                                color: AppColors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                  ),
                  child: Icon(
                    _isBarcodeMode
                        ? Icons.qr_code_scanner_rounded
                        : Icons.camera_alt_rounded,
                    color:
                        _isBarcodeMode
                            ? AppColors.white.withOpacity(0.7)
                            : AppColors.black,
                    size: AppIcons.xl,
                  ),
                ),
              ),
            );
          },
        ),

        // Flash button
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color:
                _isFlashOn
                    ? AppColors.primary.withOpacity(0.8)
                    : AppColors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  _isFlashOn
                      ? AppColors.primary
                      : AppColors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: AppColors.white,
              size: AppIcons.lg,
            ),
            onPressed: _toggleFlash,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2000.ms),

            SizedBox(height: AppSpacing.xl),

            Text(
              'Initializing Camera',
              style: AppTextStyles.h4.copyWith(color: AppColors.white),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

            SizedBox(height: AppSpacing.md),

            Text(
              'Please wait while we set up your camera',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.lgCard,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.primary,
              size: AppIcons.lg,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Barcode',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: AppTexts.semiBold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Point your camera at a product barcode to get nutrition information',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.primary,
                    size: AppIcons.xl,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'How to Use Smart Scanner',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _buildHelpItem(
                    Icons.camera_alt_rounded,
                    'Snap Mode',
                    'Take photos of your food to get nutrition estimates using AI',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildHelpItem(
                    Icons.qr_code_scanner_rounded,
                    'Barcode Mode',
                    'Scan product barcodes to get accurate nutrition information',
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildHelpItem(
                    Icons.photo_library_rounded,
                    'Gallery',
                    'Choose existing photos from your gallery to analyze',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                          ),
                          child: Text(
                            'Got it!',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: AppIcons.md),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: AppTexts.semiBold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
