import 'package:consulta_servidor/features/consulta/views/screen_consulta.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyWebApp());
}

class MyWebApp extends StatelessWidget {
  const MyWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Web App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ScreenConsulta(),
    );
  }
}
