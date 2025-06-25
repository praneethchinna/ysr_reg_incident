import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ysr_reg_incident/app_colors/app_colors.dart';
import 'package:ysr_reg_incident/feature/incident_registration/widgets/reg_app_bar.dart';

class ProfileSaveSuccessPage extends StatelessWidget {
  const ProfileSaveSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: RegAppBar(
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: LoopingVideoPlayer(),
    );
  }
}

class LoopingVideoPlayer extends StatefulWidget {
  const LoopingVideoPlayer({super.key});

  @override
  State<LoopingVideoPlayer> createState() => _LoopingVideoPlayerState();
}

class _LoopingVideoPlayerState extends State<LoopingVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
        'assets/videos/success.mp4') // or .network()
      ..setLooping(true) // 🔁 Repeat
      ..initialize().then((_) {
        _controller.play(); // ▶️ Auto play
        setState(() {}); // Refresh UI when ready
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // 🧹 Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: _controller.value.isInitialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    "Profile saved",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            AppColors.darkerSeaGreen,
                            AppColors.pacificBlue
                          ],
                        ).createShader(Rect.fromLTWH(
                            0, 0, 200, 70)), // adjust width/height as needed
                    ),
                  ),
                  Text(
                    "Successfully!",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            AppColors.darkerSeaGreen,
                            AppColors.pacificBlue
                          ],
                        ).createShader(Rect.fromLTWH(
                            0, 0, 200, 70)), // adjust width/height as needed
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: VideoPlayer(_controller), // No controllers shown
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
