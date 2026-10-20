import 'dart:convert';

import 'package:consulta_servidor/core/utils/app_feedback.dart';
import 'package:consulta_servidor/core/utils/consulta_flow.dart';
import 'package:consulta_servidor/core/utils/navigation_utils.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:consulta_servidor/features/consulta/views/screens/detalhes_servidor.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/servidor_data_source.dart';
import 'package:flutter/material.dart';

class ScreenResultados extends StatefulWidget {
  final ConsultaController controller;
  final ResultadoPaginado resultado;
  final ServidorFiltros filtrosAtuais;

  const ScreenResultados({
    super.key,
    required this.resultado,
    required this.filtrosAtuais,
    required this.controller,
  });

  @override
  State<ScreenResultados> createState() => _ScreenResultadosState();
}

class _ScreenResultadosState extends State<ScreenResultados> {
  late List<Servidor> _servidores;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Cria uma cópia mutável da lista para permitir a ordenação
    _servidores = List<Servidor>.from(widget.resultado.servidores);
  }

  /// Ordenação tipada genérica
  void _ordenar<T extends Comparable<T>>(
    T Function(Servidor s) extrairCampo,
    int columnIndex,
    bool ascending,
  ) {
    _servidores.sort((a, b) {
      final campoA = extrairCampo(a);
      final campoB = extrairCampo(b);
      return ascending ? campoA.compareTo(campoB) : campoB.compareTo(campoA);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  /// Abre um Diálogo e permite filtrar
  void _abrirFiltroColuna({
    required String titulo,
    required Set<String> valoresUnicos,
    required Function(String) onAplicar,
  }) {
    final listaOrdenada = valoresUnicos.toList()..sort();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Filtrar por $titulo'),
        content: SizedBox(
          width: 400,
          height: 350,
          child: listaOrdenada.isEmpty
              ? const Center(child: Text('Nenhum valor para filtrar.'))
              : ListView.separated(
                  itemCount: listaOrdenada.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final valor = listaOrdenada[index];
                    return ListTile(
                      title: Text(valor, style: const TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.add_circle_outline, size: 20),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onAplicar(valor);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Adiciona o critério selecionado aos filtros ativos e reexecuta a busca via API
  void _aplicarFiltroAdicional({
    String? novoCargo,
    String? novoOrgao,
    String? novaUf,
  }) {
    final novosFiltros = ServidorFiltros(
      nome: widget.filtrosAtuais.nome,
      cargo: novoCargo ?? widget.filtrosAtuais.cargo,
      orgao: novoOrgao ?? widget.filtrosAtuais.orgao,
      uf: novaUf ?? widget.filtrosAtuais.uf,
      buscaSimilar: widget.filtrosAtuais.buscaSimilar,
      limite: widget.filtrosAtuais.limite,
      pagina: 1,
    );

    // Navega para /buscar
    ConsultaFlow.executar(
      context: context,
      controller:
          widget.controller, // Passe o controller para a ScreenResultados
      filtros: novosFiltros,
    );
  }

  void _exportarJson() {
    final listaMap = _servidores
        .map(
          (s) => {
            'id': s.id,
            'nome': s.nome,
            'cpf': s.cpf,
            'cargo': s.cargo,
            'uf': s.uf,
            'orgao': s.orgao,
            'remuneracao': s.remuneracao,
          },
        )
        .toList();

    final jsonFormatado = const JsonEncoder.withIndent('  ').convert(listaMap);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exportação JSON'),
        content: SizedBox(
          width: 600,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonFormatado,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copiar JSON'),
            onPressed: () {
              Navigator.of(context).pop();
              AppFeedback.mostrarSnackBar(
                context,
                mensagem: 'JSON copiado com sucesso!',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalNoBanco = widget.resultado.totalRegistros;

    final dataSource = ServidorDataSource(
      servidores: _servidores,
      context: context,
      onVerDetalhes: (servidor) {
        Navigator.of(context).push(
          NavigationUtils.criarRotaFade(
            ScreenDetalhesServidor(servidor: servidor),
          ),
        );
      },
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1300),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          children: [
            // Cabeçalho da Tabela
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servidores Encontrados',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalNoBanco > _servidores.length
                            ? 'Exibindo os primeiros ${_servidores.length} registros de um total de $totalNoBanco no banco.'
                            : 'Exibindo todos os ${_servidores.length} registros correspondentes.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportarJson,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Exportar JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tabela
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: PaginatedDataTable(
                header: const Text(
                  'Base Oficial (Clique nas colunas para ordenar)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                rowsPerPage: _servidores.length >= 10
                    ? 10
                    : (_servidores.isEmpty ? 1 : _servidores.length),
                availableRowsPerPage: const [5, 10, 20, 50],
                columnSpacing: 20,
                horizontalMargin: 20,
                showCheckboxColumn: false,
                columns: [
                  // Coluna 0: Nome
                  DataColumn(
                    label: const Text('Servidor'),
                    onSort: (columnIndex, ascending) => _ordenar(
                      (s) => s.nome.toLowerCase(),
                      columnIndex,
                      ascending,
                    ),
                  ),

                  // Coluna 1: Cargo
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Cargo / Função'),
                        IconButton(
                          icon: const Icon(Icons.filter_alt_outlined, size: 16),
                          tooltip: 'Filtrar por Cargo único',
                          onPressed: () {
                            final cargosUnicos = _servidores
                                .map((s) => s.cargo)
                                .where((c) => c.isNotEmpty)
                                .toSet();
                            _abrirFiltroColuna(
                              titulo: 'Cargo',
                              valoresUnicos: cargosUnicos,
                              onAplicar: (cargoEscolhido) =>
                                  _aplicarFiltroAdicional(
                                    novoCargo: cargoEscolhido,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) => _ordenar(
                      (s) => s.cargo.toLowerCase(),
                      columnIndex,
                      ascending,
                    ),
                  ),

                  // Coluna 2: Órgão
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Lotação / Órgão'),
                        IconButton(
                          icon: const Icon(Icons.filter_alt_outlined, size: 16),
                          tooltip: 'Filtrar por Órgão único',
                          onPressed: () {
                            final orgaosUnicos = _servidores
                                .map((s) => s.orgao)
                                .where((o) => o.isNotEmpty)
                                .toSet();
                            _abrirFiltroColuna(
                              titulo: 'Órgão',
                              valoresUnicos: orgaosUnicos,
                              onAplicar: (orgaoEscolhido) =>
                                  _aplicarFiltroAdicional(
                                    novoOrgao: orgaoEscolhido,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) => _ordenar(
                      (s) => s.orgao.toLowerCase(),
                      columnIndex,
                      ascending,
                    ),
                  ),

                  // Coluna 3: UF
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('UF'),
                        IconButton(
                          icon: const Icon(Icons.filter_alt_outlined, size: 16),
                          tooltip: 'Filtrar por UF única',
                          onPressed: () {
                            final ufsUnicas = _servidores
                                .map((s) => s.uf)
                                .where((u) => u.isNotEmpty)
                                .toSet();
                            _abrirFiltroColuna(
                              titulo: 'UF',
                              valoresUnicos: ufsUnicas,
                              onAplicar: (ufEscolhida) =>
                                  _aplicarFiltroAdicional(novaUf: ufEscolhida),
                            );
                          },
                        ),
                      ],
                    ),
                    onSort: (columnIndex, ascending) =>
                        _ordenar((s) => s.uf, columnIndex, ascending),
                  ),

                  // Coluna 4: Remuneração
                  DataColumn(
                    label: const Text('Remuneração'),
                    numeric: true,
                    onSort: (columnIndex, ascending) =>
                        _ordenar((s) => s.remuneracao, columnIndex, ascending),
                  ),

                  // Coluna 5: Ações
                  const DataColumn(label: Text('Ações')),
                ],
                source: dataSource,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
