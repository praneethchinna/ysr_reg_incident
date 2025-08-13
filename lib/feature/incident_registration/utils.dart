import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<File?> generateThumbnail({
  required String videoPath,
}) async {
  try {
    return await VideoCompress.getFileThumbnail(
      videoPath,
      quality: 50, // 0-100
      position: -1, // middle frame
    );
  } catch (e) {
    debugPrint("Thumbnail generation failed: $e");
    return null; // fail gracefully
  }
}

Future<Uint8List?> generateThumbnailFromUrl(String videoUrl) async {
  try {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl, // Can be a local file path or a network URL
      imageFormat: ImageFormat.PNG,
      maxWidth: 128, // Specify width of the thumbnail
      quality: 25,
    );
    return uint8list;
  } catch (e) {
    print("Error generating thumbnail: $e");
    return null;
  }
}
