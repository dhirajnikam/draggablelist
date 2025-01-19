import 'dart:ui';
import 'package:dragtest/widget/mac_doc_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MacDockWidget(),
    );
  }
}
