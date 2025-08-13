import 'package:flutter/services.dart';

class LowQualityVideoRecorder {
  static const MethodChannel _channel =
  MethodChannel('custom_video_recorder');

  static Future<String?> recordLowQualityVideo() async {
    try {
      final String? videoUriString = await _channel.invokeMethod('recordLowQualityVideo');
      if (videoUriString != null) {
        // Now you have the content URI, but let's get the file path from it.
        final String? filePath = await _channel.invokeMethod('getFilePathFromUri', {'uriString': videoUriString});
        return filePath;
      }
    } on PlatformException catch (e) {
      print("Failed to record video: '${e.message}'.");
    }
    return null;
  }
}
