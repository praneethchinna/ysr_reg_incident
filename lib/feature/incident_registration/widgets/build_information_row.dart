import 'package:flutter/material.dart';

Widget buildInformationRow({required String title, required String value}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
        ),
        Text("   :   "),
        Expanded(
          flex: 6,
          child: Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey)),
        ),
      ],
    ),
  );
}