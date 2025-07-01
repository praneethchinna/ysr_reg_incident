import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:ysr_reg_incident/feature/login/ui/login_ui.dart';

class VideoScreen extends StatefulWidget {
  final String videoPath; // local or network URL

  const VideoScreen({super.key, required this.videoPath});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        // Listen for video completion
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration &&
              _controller.value.isInitialized) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginUi(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller
                        .value.aspectRatio, // Will preserve Reels-style ratio
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginUi(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'skip'.tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shakeX(
                          duration: Duration(seconds: 1), // slower animation
                          hz: 1, // 2 shakes per second (default is 5)
                          amount: 8, // how far it moves in px (optional)
                        )
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
