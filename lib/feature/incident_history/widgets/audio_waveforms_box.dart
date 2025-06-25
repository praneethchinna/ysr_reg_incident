import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class AudioWaveformBox extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;
  final bool isFrozen;

  const AudioWaveformBox({
    super.key,
    required this.height,
    required this.width,
    this.margin,
    required this.isFrozen,
  });

  @override
  State<AudioWaveformBox> createState() => _AudioWaveformBoxState();
}

class _AudioWaveformBoxState extends State<AudioWaveformBox> {
  final StreamController<Amplitude> _controller = StreamController.broadcast();
  Timer? _timer;
  final double _maxHeight = 50;

  @override
  void initState() {
    super.initState();
    _startWaveformStream();
  }

  void _startWaveformStream() {
    _timer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!widget.isFrozen) {
        _controller.add(
          Amplitude(
            current: Random().nextDouble() * _maxHeight,
            max: _maxHeight,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedWaveList(
        stream: _controller.stream,
        barBuilder: (animation, amplitude) => WaveFormBar(
          animation: animation,
          amplitude: amplitude,
          color: Colors.blue,
        ),
      ),
    );
  }
}
