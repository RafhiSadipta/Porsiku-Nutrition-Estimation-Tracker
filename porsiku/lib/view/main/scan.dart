import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'viewimage.dart';
import 'result.dart';

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
  MobileScannerController? _barcodeController;

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
      _showMessage('Camera permission denied');
    }
    if (!galleryGranted) {
      _showMessage('Gallery permission denied');
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
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ViewImagePage(imagePath: pickedFile.path),
        ),
      );
    }
  }

  Future<void> _handleBarcodeScanned(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        _showMessage('Token tidak ditemukan. Silakan login ulang.');
        return;
      }

      final uri = Uri.parse(
        'http://192.168.100.110:8080/api/produk?barcode=$barcode',
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

        // Cek apakah response berupa Map<String, dynamic>
        if (decoded != null && decoded is Map<String, dynamic>) {
          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => ResultPage(
                    foodListText: 'Ditemukan dari barcode',
                    nutritionResult: [decoded], // Bungkus Map jadi List
                    imagePath: '',
                  ),
            ),
          );
        } else {
          _showMessage('Format data tidak valid');
        }
      } else if (response.statusCode == 401) {
        _showMessage('Tidak terautentikasi. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        _showMessage('Produk tidak ditemukan');
      } else {
        _showMessage('Terjadi kesalahan: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Gagal menghubungi server: $e');
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeController?.dispose();
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
                  Positioned.fill(
                    child:
                        _isBarcodeMode
                            ? MobileScanner(
                              controller:
                                  _barcodeController ??=
                                      MobileScannerController(),
                              onDetect: (capture) {
                                final barcode = capture.barcodes.first.rawValue;
                                if (barcode != null) {
                                  _barcodeController?.stop();
                                  _handleBarcodeScanned(barcode);
                                }
                              },
                            )
                            : CameraPreview(_cameraController!),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeSwitch(),
                        const SizedBox(height: 32),
                        _buildControlButtons(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      onTap: () => setState(() => _isBarcodeMode = isBarcode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white),
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
              color: _isBarcodeMode ? Colors.grey : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isBarcodeMode ? Icons.qr_code_scanner : Icons.camera_alt,
              color: _isBarcodeMode ? Colors.black54 : Colors.black,
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
    );
  }
}
