import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/views/screens/busca_dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  // 1. Criamos nossas dependências (Repository e Controller)
  final repositorio = ServidorRepository();
  final controller = ConsultaController(repositorio);

  // 2. Passamos o controller para o App
  runApp(MyWebApp(controller: controller));
}

class MyWebApp extends StatelessWidget {
  final ConsultaController controller;

  const MyWebApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Servidores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      home: MainLayout(
        titulo: 'Buscar Servidores',
        indiceMenuAtivo: 1, // Menu "Buscar" aceso
        mostrarBotaoVoltar: false,

        // Injetar o controller na tela
        conteudo: ScreenBuscaDashboard(controller: controller),
      ),
    );
  }
}
