import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/utils/app_feedback.dart';
import 'package:consulta_servidor/core/utils/consulta_flow.dart';
import 'package:consulta_servidor/core/utils/navigation_utils.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:consulta_servidor/features/consulta/views/screens/consulta_resultados.dart';
import 'package:consulta_servidor/features/consulta/views/screens/detalhes_servidor.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/form_busca.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/stat_card.dart';
import 'package:consulta_servidor/features/historico/services/historico_services.dart';
import 'package:flutter/material.dart';

class ScreenBuscaDashboard extends StatefulWidget {
  final ConsultaController controller;
  final ServidorFiltros? filtrosIniciais;

  const ScreenBuscaDashboard({
    super.key,
    required this.controller,
    this.filtrosIniciais,
  });

  @override
  State<ScreenBuscaDashboard> createState() => _ScreenBuscaDashboardState();
}

class _ScreenBuscaDashboardState extends State<ScreenBuscaDashboard> {
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.filtrosIniciais != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _realizarBusca(widget.filtrosIniciais!);
      });
    }
  }

  Future<void> _realizarBusca(ServidorFiltros filtros) async {
    setState(() => _isCarregando = true);

    try {
      final ResultadoPaginado resultado = await widget.controller
          .buscarServidores(filtros);

      if (!mounted) return;

      final servidores = resultado.servidores;
      final totalNoBanco = resultado.totalRegistros;

      HistoricoService().salvarBusca(
        filtros: filtros,
        totalResultados: totalNoBanco,
      );

      if (servidores.isEmpty) {
        AppFeedback.mostrarAlerta(
          context,
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum servidor encontrado',
          mensagem: 'Não encontramos registros com os filtros informados. Tente usar a busca por similaridade.',
        );
      } else if (servidores.length == 1) {
        Navigator.of(context).push(
          NavigationUtils.criarRotaFade(
            MainLayout(
              titulo: 'Detalhes do Servidor',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenDetalhesServidor(servidor: servidores.first),
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          NavigationUtils.criarRotaFade(
            MainLayout(
              titulo: 'Resultados da Consulta',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenResultados(
                resultado: resultado,
                filtrosAtuais: filtros,
                controller: widget.controller,
              ),
            ),
          ),
        );
      }
    } catch (erro) {
      if (!mounted) return;
      AppFeedback.mostrarAlerta(
        context,
        icone: Icons.cloud_off_rounded,
        titulo: 'Falha na Conexão',
        mensagem: erro.toString(),
        isErro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isCarregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            children: [
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
              FormConsulta(
                controller: widget.controller,
                onBuscar: (filtros) {
                  ConsultaFlow.executar(
                    context: context,
                    controller: widget.controller,
                    filtros: filtros,
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Visão Geral da Base de Dados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int colunas = switch (constraints.maxWidth) {
                    < 600 => 1,
                    < 1050 => 2,
                    _ => 4,
                  };

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
                          valor: '1.092.882',
                          icone: Icons.people_outline,
                          corIcone: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Servidores ativos',
                          valor: '1.092.160',
                          icone: Icons.check_circle_outline,
                          corIcone: Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: larguraCard,
                        child: const StatCard(
                          titulo: 'Aposentados',
                          valor: '722',
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
