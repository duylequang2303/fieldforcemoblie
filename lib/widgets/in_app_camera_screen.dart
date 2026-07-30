import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class InAppCameraScreen extends StatefulWidget {
  const InAppCameraScreen({super.key});

  @override
  State<InAppCameraScreen> createState() => _InAppCameraScreenState();
}

class _InAppCameraScreenState extends State<InAppCameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      // Chọn camera sau (back camera), nếu không có thì lấy camera đầu tiên
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.low, // Preview nhẹ RAM
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) Navigator.pop(context, null);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, image.path);
    } catch (e) {
      if (mounted) Navigator.pop(context, null);
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      await _controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Camera (in-app, thử nghiệm)'),
      ),
      body: _isInitialized && _controller != null
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: CameraPreview(_controller!),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: FloatingActionButton.large(
                    heroTag: 'capture_button',
                    backgroundColor: Colors.white,
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}