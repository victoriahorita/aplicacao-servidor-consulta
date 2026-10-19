import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:consulta_servidor/features/consulta/views/screens/consulta_resultados.dart';
import 'package:consulta_servidor/features/consulta/views/screens/detalhes_servidor.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/form_busca.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/stat_card.dart';
import 'package:consulta_servidor/features/historico/services/historico_services.dart';
import 'package:flutter/material.dart';

/// [ScreenBuscaDashboard] é o componente orquestrador (Smart Widget) do painel principal.
/// Gerencia a chamada de API, exibe diálogos de feedback e navega entre as telas.
class ScreenBuscaDashboard extends StatefulWidget {
  final ConsultaController controller;

  const ScreenBuscaDashboard({super.key, required this.controller});

  @override
  State<ScreenBuscaDashboard> createState() => _ScreenBuscaDashboardState();
}

class _ScreenBuscaDashboardState extends State<ScreenBuscaDashboard> {
  // Controle local do estado de carregamento repassado ao FormConsulta
  bool _isCarregando = false;

  /// Dispara a consulta na API através do Controller e direciona o usuário
  /// conforme as regras do trabalho acadêmico (1 resultado vs N resultados).
  Future<void> _realizarBusca(ServidorFiltros filtros) async {
    setState(() {
      _isCarregando = true;
    });

    try {
      // 1. Executa a requisição assíncrona
      final List<Servidor> resultados = await widget.controller
          .buscarServidores(filtros);

      HistoricoService().salvarBusca(
        filtros: filtros,
        totalResultados: resultados.length,
      );

      if (!mounted) return;

      // 2. Roteamento condicional
      if (resultados.isEmpty) {
        _mostrarAlerta(
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum servidor encontrado',
          mensagem: 'Não encontramos registros com os filtros informados. Tente usar a busca por similaridade ou ampliar os termos.',
        );
      } else if (resultados.length == 1) {
        // Redireciona diretamente para os detalhes caso haja apenas 1 resultado
        Navigator.of(context).push(
          _criarRotaTransicaoSuave(
            MainLayout(
              titulo: 'Detalhes do Servidor',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenDetalhesServidor(servidor: resultados.first),
            ),
          ),
        );
      } else {
        // Redireciona para a tabela paginada se houver 2 ou mais resultados
        Navigator.of(context).push(
          _criarRotaTransicaoSuave(
            MainLayout(
              titulo: 'Resultados da Consulta',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenResultados(servidores: resultados),
            ),
          ),
        );
      }
    } catch (erro) {
      if (!mounted) return;
      _mostrarAlerta(
        icone: Icons.cloud_off_rounded,
        titulo: 'Falha na Conexão',
        mensagem:
            'Não foi possível se comunicar com o servidor da base de dados: $erro',
        isErro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCarregando = false;
        });
      }
    }
  }

  /// Exibe um diálogo de alerta customizado com ícones contextuais e cantos arredondados.
  void _mostrarAlerta({
    required IconData icone,
    required String titulo,
    required String mensagem,
    bool isErro = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          icone,
          size: 56,
          color: isErro ? Colors.redAccent : Colors.amber.shade800,
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isErro
                  ? Colors.redAccent
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói uma transição suave por Fade (150ms) nativa para Web e Desktop.
  PageRouteBuilder _criarRotaTransicaoSuave(Widget destino) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destino,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SelectionArea habilita a seleção de texto com o ponteiro do mouse (Vital para Web/Desktop)
    return SelectionArea(
      child: Center(
        child: ConstrainedBox(
          // Limite de 1300px: evita que o painel se torne ilegível em telas ultrawide
          constraints: const BoxConstraints(maxWidth: 1300),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            children: [
              // Cabeçalho institucional da tela
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel de Consultas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Informe os parâmetros desejados para pesquisar na base de servidores do Poder Executivo.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // O Formulário Modular Desacoplado
              FormConsulta(
                isCarregando: _isCarregando,
                onBuscar: _realizarBusca,
              ),

              const SizedBox(height: 32),

              // Seção de Métricas / Estatísticas
              const Text(
                'Visão Geral da Base de Dados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),

              // Grid Responsivo de Estatísticas usando Pattern Matching (Dart 3)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Switch expression calculando colunas de acordo com a largura real da janela
                  final int colunas = switch (constraints.maxWidth) {
                    < 600 => 1,
                    < 1050 => 2,
                    _ => 4,
                  };

                  // Cálculo preciso da largura de cada cartão subtraindo os espaçamentos
                  final double espacoTotal = (colunas - 1) * 16.0;
                  final double larguraCard =
                      (constraints.maxWidth - espacoTotal) / colunas;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Total de registros',
                          valor: '1.092.160',
                          icone: Icons.people_outline,
                          corIcone: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Servidores ativos',
                          valor: '876.543',
                          icone: Icons.check_circle_outline,
                          corIcone: Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Aposentados',
                          valor: '358.024',
                          icone: Icons.history,
                          corIcone: Colors.purple,
                        ),
                      ),
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Órgãos / Instituições',
                          valor: '412',
                          icone: Icons.account_balance_outlined,
                          corIcone: Colors.orange,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
