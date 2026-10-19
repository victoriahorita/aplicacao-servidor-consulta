import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ConsultaServidorApp extends StatelessWidget {
  const ConsultaServidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Servidores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // Aplicando nosso tema personalizado
      // Iniciamos com o MainLayout envolvendo nossa tela de Busca
      home: const MainLayout(
        titulo: 'Buscar Servidores',
        conteudo: ScreenBuscaDashboard(),
      ),
    );
  }
}