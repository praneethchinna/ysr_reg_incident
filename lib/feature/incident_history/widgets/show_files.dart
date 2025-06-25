import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import 'package:ysr_reg_incident/feature/incident_history/widgets/audio_waveforms_box.dart';

void showFullDialog(BuildContext context, String url) {
  final isVideo = _isVideo(url);
  final isAudio = _isAudio(url);

  if (isVideo) {
    _showVideoPage(context, url); // full screen for video
    return;
  }

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(8),
        content: SizedBox(
          width: 300,
          height: 300,
          child: isAudio
              ? _AudioDialogPlayer(url: url)
              : InstaImageViewer(
                  child: Image.network(
                    url,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      );
    },
  );
}

void _showVideoPage(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoFullScreenPage(videoUrl: url),
    ),
  );
}

class VideoFullScreenPage extends StatefulWidget {
  final String videoUrl;

  const VideoFullScreenPage({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
        backgroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Chewie(controller: _chewieController),
        ),
      ),
    );
  }
}

Widget _buildAudioPlayer(String url) {
  return _audioPlayer(url);
}

Widget _audioPlayer(String url) {
  final player = AudioPlayer();
  player.setUrl(url);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.audiotrack, size: 48),
      const SizedBox(height: 16),
      StreamBuilder<PlayerState>(
        stream: player.playerStateStream,
        builder: (context, snapshot) {
          final isPlaying = snapshot.data?.playing ?? false;
          return IconButton(
            iconSize: 40,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              isPlaying ? player.pause() : player.play();
            },
          );
        },
      ),
    ],
  );
}

bool _isVideo(String url) {
  return url.endsWith('.mp4') || url.contains('video');
}

bool _isAudio(String url) {
  return url.endsWith('.mp3') || url.contains('audio');
}

class _AudioDialogPlayer extends StatefulWidget {
  final String url;
  const _AudioDialogPlayer({required this.url});

  @override
  State<_AudioDialogPlayer> createState() => _AudioDialogPlayerState();
}

class _AudioDialogPlayerState extends State<_AudioDialogPlayer> {
  late final AudioPlayer _player;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.url).then((_) => _player.play());
  }

  @override
  void dispose() {
    _player.dispose(); // ❗ Stop audio when dialog closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("🎧 Playing audio..."),
        const SizedBox(height: 20),
        IconButton(
          icon: Icon(_isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled),
          iconSize: 40,
          onPressed: () {
            if (_player.playing) {
              setState(() {
                _isPlaying = false;
                _player.pause();
              });
            } else {
              setState(() {
                _isPlaying = true;
                _player.play();
              });
            }
          },
        ),
        AudioWaveformBox(
          height: 50,
          width: 200,
          isFrozen: !_isPlaying,
        )
      ],
    );
  }

  Stream<Amplitude> createRandomAmplitudeStream() {
    return Stream.periodic(
      const Duration(milliseconds: 70),
      (count) => Amplitude(
        current: Random().nextDouble() * 100,
        max: 100,
      ),
    );
  }
}
