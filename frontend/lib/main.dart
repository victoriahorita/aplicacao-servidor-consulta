import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/theme/app_theme.dart';
import 'package:consulta_servidor/core/views/screen_not_found.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/views/screens/busca_dashboard.dart';
import 'package:consulta_servidor/features/historico/views/screens/historico.dart';
import 'package:flutter/material.dart';

void main() {
  // Garante a correta inicialização dos bindings do Flutter no Web e Desktop
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Injeção de Dependências limpa
  final servidorRepository = ServidorRepository();
  final consultaController = ConsultaController(servidorRepository);

  // 2. Inicialização da Aplicação
  runApp(MyApp(controller: consultaController));
}

/// [MyApp] configura o MaterialApp, temas globais e rotas nomeadas.
class MyApp extends StatelessWidget {
  final ConsultaController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal da Transparência - Servidores Federais',
      debugShowCheckedModeBanner: false,

      // Aplica o tema institucional criado anteriormente
      theme: AppTheme.light,

      // Rota inicial padrão ao abrir o navegador ou aplicativo desktop
      initialRoute: '/buscar',

      // Mapeamento de Rotas Nomeadas com o App Shell (MainLayout)
      routes: {
        '/buscar': (context) => MainLayout(
          titulo: 'Buscar Servidores',
          indiceMenuAtivo: 1,
          mostrarBotaoVoltar: false,
          conteudo: ScreenBuscaDashboard(controller: controller),
        ),
        '/historico': (context) => MainLayout(
          titulo: 'Histórico de Consultas',
          indiceMenuAtivo: 2,
          mostrarBotaoVoltar: false,
          conteudo: ScreenHistorico(
            onRepetirBusca: (filtros) {
              // Ao clicar em 'Repetir Busca', redireciona para a tela de busca
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/buscar', (route) => false);
              // Dispara a busca novamente utilizando o Controller compartilhado
              controller.buscarServidores(filtros);
            },
          ),
        ),
      },

      // Tratamento obrigatório do PDF: Rota desconhecida / Página inexistente (404)
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const ScreenNotFound()),
    );
  }
}
