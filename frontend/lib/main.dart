import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:consulta_servidor/core/views/screen_not_found.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/views/screens/busca_dashboard.dart';
import 'package:consulta_servidor/features/historico/views/screens/historico.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Injeção de dependências: Repository -> Controller
  final servidorRepository = ServidorRepository();
  final consultaController = ConsultaController(servidorRepository);

  runApp(PortalServidorApp(controller: consultaController));
}

class PortalServidorApp extends StatelessWidget {
  final ConsultaController controller;

  const PortalServidorApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal de Servidores Públicos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/buscar',
      routes: {
        '/buscar': (context) {
          // Captura filtros passados por navegações
          final filtrosPassados =
              ModalRoute.of(context)?.settings.arguments as ServidorFiltros?;

          return MainLayout(
            titulo: 'Buscar Servidores',
            indiceMenuAtivo: 1,
            mostrarBotaoVoltar: false,
            conteudo: ScreenBuscaDashboard(
              controller: controller,
              filtrosIniciais: filtrosPassados,
            ),
          );
        },
        '/historico': (context) => MainLayout(
          titulo: 'Histórico de Consultas',
          indiceMenuAtivo: 2,
          mostrarBotaoVoltar: false,
          conteudo: ScreenHistorico(controller: controller),
        ),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const ScreenNotFound()),
    );
  }
}
