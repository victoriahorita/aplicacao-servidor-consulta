import 'dart:convert';

import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:consulta_servidor/features/consulta/views/screens/detalhes_servidor.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/servidor_data_source.dart';
import 'package:flutter/material.dart';

class ScreenResultados extends StatelessWidget {
  final List<Servidor> servidores;

  const ScreenResultados({super.key, required this.servidores});

  void _abrirDetalhes(BuildContext context, Servidor servidor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenDetalhesServidor(servidor: servidor),
      ),
    );
  }

  void _exportarJson(BuildContext context) {
    // Converte a lista em uma String JSON indentada e formatada
    final listaMap = servidores
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

    // Feedback visual "Juicy": Exibe um Dialog com o JSON pronto para cópia
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.data_object, color: Colors.blue),
            SizedBox(width: 8),
            Text('Exportação JSON'),
          ],
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('JSON copiado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instancia a fonte de dados paginada com os callbacks necessários
    final dataSource = ServidorDataSource(
      servidores: servidores,
      context: context,
      onVerDetalhes: (servidor) => _abrirDetalhes(context, servidor),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1300),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          children: [
            // Barra de ferramentas superior da tabela
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      'Total de ${servidores.length} registros correspondentes à busca.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Botão de Exportar JSON (Requisito do trabalho)
                ElevatedButton.icon(
                  onPressed: () => _exportarJson(context),
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

            // Card da Tabela Paginada
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: PaginatedDataTable(
                header: const Text(
                  'Base de Dados do Executivo Federal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                rowsPerPage: servidores.length >= 10
                    ? 10
                    : (servidores.isEmpty ? 1 : servidores.length),
                availableRowsPerPage: const [5, 10, 20],
                columnSpacing: 24,
                horizontalMargin: 24,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('Servidor')),
                  DataColumn(label: Text('Cargo / Função')),
                  DataColumn(label: Text('Lotação / Órgão')),
                  DataColumn(label: Text('UF')),
                  DataColumn(label: Text('Remuneração')),
                  DataColumn(label: Text('Ações')),
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
