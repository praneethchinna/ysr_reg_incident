import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AwsomeSnackbar {
  static void showSuccessSnackbar(
      {required BuildContext context,
      required ContentType contentType,
      required String title,
      required String message}) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType:
            contentType, // ContentType.failure, ContentType.warning, ContentType.help also available
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
