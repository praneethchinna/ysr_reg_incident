import 'package:flutter/material.dart';

class RegTextWidget extends StatelessWidget {
  final String text;

  const RegTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
