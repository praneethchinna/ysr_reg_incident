import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key});

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isRecording = false;
  bool _recordingFinished = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initCamera(_selectedCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint("❌ No cameras found");
        return;
      }

      _controller?.dispose();
      _controller = CameraController(
        _cameras![cameraIndex],
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("❌ Error initializing camera: $e");
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    // Dispose of the current controller first
    _controller?.dispose();
    _controller = null; // Set to null to indicate it's not available

    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;

    // Add a small delay to give the camera time to close completely
    await Future.delayed(const Duration(milliseconds: 500));

    // Now, initialize the new camera
    _initCamera(_selectedCameraIndex);
  }

  void _startRecording() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        debugPrint("❌ Camera is not initialized");
        return;
      }

      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingFinished = false;
        _recordDuration = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {

        if(timer.tick == 60) {
          _stopRecording();
        }

        setState(() {
          _recordDuration++;
        });
      });
    } catch (e) {
      debugPrint("❌ Error starting video recording: $e");
    }
  }

  void _stopRecording() async {
    try {
      if (_controller == null || !_controller!.value.isRecordingVideo) {
        debugPrint("❌ No video is recording");
        return;
      }

      final file = await _controller!.stopVideoRecording();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _recordingFinished = true;
        _videoPath = file.path;
      });
    } catch (e) {
      debugPrint("❌ Error stopping video recording: $e");
    }
  }

  void _cancelVideo() {
    Navigator.pop(context, null);
  }

  void _acceptVideo() {
    if (_videoPath != null) {
      Navigator.pop(context, _videoPath);
    }
  }

  @override
  void dispose() {

    _controller?.dispose();
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          // Switch camera button
          Positioned(
            top: 40,
            right: 20,
            child: _controller != null && _controller!.value.isRecordingVideo
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isRecording)
                  Text(
                    "⏱ $_recordDuration s / 60",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                const SizedBox(height: 10),

                // Recording controls
                if (!_recordingFinished)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.green,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                // After recording: Cancel / Accept buttons
                if (_recordingFinished)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 40),
                        onPressed: _cancelVideo,
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        icon: const Icon(Icons.check,
                            color: Colors.green, size: 40),
                        onPressed: _acceptVideo,
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Future<String?> recordVideo(BuildContext context) {
  return Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (context) => const VideoRecorder()),
  );
}
