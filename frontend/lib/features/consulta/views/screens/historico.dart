import 'package:consulta_servidor/features/consulta/models/item_historico.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:flutter/material.dart';

class ScreenHistorico extends StatefulWidget {
  final Function(ServidorFiltros) onRepetirBusca;

  const ScreenHistorico({super.key, required this.onRepetirBusca});

  @override
  State<ScreenHistorico> createState() => _ScreenHistoricoState();
}

class _ScreenHistoricoState extends State<ScreenHistorico> {
  // Dados mockados de histórico recente para demonstração
  late List<ItemHistorico> _historico;

  @override
  void initState() {
    super.initState();
    _historico = [
      ItemHistorico(
        id: '1',
        filtros: const ServidorFiltros(
          nome: 'João',
          buscaSimilar: true,
          uf: 'DF',
        ),
        dataHora: DateTime.now().subtract(const Duration(minutes: 12)),
        totalResultados: 18,
      ),
      ItemHistorico(
        id: '2',
        filtros: const ServidorFiltros(
          cargo: 'Auditor Fiscal',
          orgao: 'Receita Federal',
        ),
        dataHora: DateTime.now().subtract(const Duration(hours: 2)),
        totalResultados: 5,
      ),
      ItemHistorico(
        id: '3',
        filtros: const ServidorFiltros(
          nome: 'Maria Souza',
          buscaSimilar: false,
        ),
        dataHora: DateTime.now().subtract(const Duration(days: 1)),
        totalResultados: 1,
      ),
    ];
  }

  void _removerItem(int index) {
    setState(() {
      _historico.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removido do histórico.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _limparTudo() {
    setState(() {
      _historico.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          children: [
            // Topo da tela com botão de esvaziar histórico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Histórico de Consultas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Acesse rapidamente suas pesquisas recentes ou repita consultas com um clique.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                if (_historico.isNotEmpty)
                  TextButton.icon(
                    onPressed: _limparTudo,
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Limpar Histórico',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Estado Vazio (Juicy UX)
            if (_historico.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma busca recente registrada.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'As pesquisas que você realizar no formulário aparecerão listadas aqui.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Lista de Cards Interativos
              ...List.generate(_historico.length, (index) {
                final item = _historico[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Ícone do Histórico
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.manage_search,
                            color: Colors.blue.shade700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Detalhes da Busca e Chips
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.dataFormatada,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•  ${item.totalResultados} encontrados',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Chips exibindo os filtros que foram usados
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (item.filtros.nome != null)
                                    Chip(
                                      label: Text(
                                        'Nome: "${item.filtros.nome}"',
                                      ),
                                      avatar: const Icon(
                                        Icons.person,
                                        size: 16,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  if (item.filtros.cargo != null)
                                    Chip(
                                      label: Text(
                                        'Cargo: ${item.filtros.cargo}',
                                      ),
                                      avatar: const Icon(Icons.work, size: 16),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  if (item.filtros.uf != null)
                                    Chip(
                                      label: Text('UF: ${item.filtros.uf}'),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Ações rápidas
                        ElevatedButton.icon(
                          onPressed: () => widget.onRepetirBusca(item.filtros),
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Repetir Busca'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          tooltip: 'Excluir do histórico',
                          onPressed: () => _removerItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
