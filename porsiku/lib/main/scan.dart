import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'viewimage.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isBarcodeMode = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
  }

  Future<void> _requestAllPermissions() async {
    final cameraGranted = await _requestCameraPermission();
    final galleryGranted = await _requestGalleryPermission();
    if (!mounted) return;
    if (cameraGranted) {
      await _initCamera();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
    if (!galleryGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
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
    final file = await _cameraController!.takePicture();
    setState(() {
      _imageFile = File(file.path);
    });
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ViewImagePage(imagePath: file.path)),
    );
    // TODO: Kirim _imageFile ke API untuk analisa
  }

  Future<void> _pickFromGallery() async {
    if (!mounted) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // TODO: Kirim _imageFile ke API untuk analisa
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body:
          !_isCameraInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Camera preview
                  Positioned.fill(child: CameraPreview(_cameraController!)),
                  // UI controls
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Snap/Barcode switch dengan animasi
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => _isBarcodeMode = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !_isBarcodeMode
                                            ? Colors.black
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color:
                                          !_isBarcodeMode
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    child: const Text('Snap'),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => setState(() => _isBarcodeMode = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _isBarcodeMode
                                            ? Colors.black
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      color:
                                          _isBarcodeMode
                                              ? Colors.white
                                              : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    child: const Text('Barcode'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Capture & controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                              iconSize: 32,
                              onPressed: _pickFromGallery,
                            ),
                            const SizedBox(width: 32),
                            GestureDetector(
                              onTap: _isBarcodeMode ? null : _captureImage,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color:
                                      _isBarcodeMode
                                          ? Colors.grey
                                          : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isBarcodeMode
                                      ? Icons.qr_code_scanner
                                      : Icons.camera_alt,
                                  color:
                                      _isBarcodeMode
                                          ? Colors.black54
                                          : Colors.black,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              icon: Icon(
                                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white,
                              ),
                              iconSize: 32,
                              onPressed: _toggleFlash,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
