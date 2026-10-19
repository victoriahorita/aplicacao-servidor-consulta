import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/historico/models/item_historico.dart';
import 'package:consulta_servidor/features/historico/services/historico_services.dart';
import 'package:flutter/material.dart';

class ScreenHistorico extends StatelessWidget {
  final ValueChanged<ServidorFiltros> onRepetirBusca;

  const ScreenHistorico({super.key, required this.onRepetirBusca});

  void _confirmarLimpeza(BuildContext context, HistoricoService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Limpar todo o histórico?'),
        content: const Text(
          'Esta ação removerá todas as consultas salvas localmente nesta sessão.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              service.limparTudo();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Histórico limpo com sucesso!'),
                  backgroundColor: Colors.blueGrey,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Sim, Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historicoService = HistoricoService();

    // ListenableBuilder reconstrói esta tela automaticamente sempre que
    // o HistoricoService adicionar ou remover itens com notifyListeners()
    return ListenableBuilder(
      listenable: historicoService,
      builder: (context, _) {
        final List<ItemHistorico> itens = historicoService.itens;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              children: [
                // Barra de cabeçalho
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (itens.isNotEmpty)
                      TextButton.icon(
                        onPressed: () =>
                            _confirmarLimpeza(context, historicoService),
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
                if (itens.isEmpty)
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
                            'Nenhuma consulta registrada até o momento.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Faça uma busca no formulário para visualizar seus registros aqui.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Lista de Cards com as buscas reais armazenadas
                  ...itens.map((item) {
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
                            // Ícone visual
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

                            // Resumo da busca
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
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: item.totalResultados > 0
                                              ? Colors.green.shade700
                                              : Colors.orange.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Chips Dinâmicos dos Filtros Utilizados
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      if (item.filtros.nome != null)
                                        Chip(
                                          label: Text(
                                            'Nome: "${item.filtros.nome}" (${item.filtros.buscaSimilar ? "Similar" : "Exato"})',
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
                                          avatar: const Icon(
                                            Icons.work,
                                            size: 16,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      if (item.filtros.orgao != null)
                                        Chip(
                                          label: Text(
                                            'Órgão: ${item.filtros.orgao}',
                                          ),
                                          avatar: const Icon(
                                            Icons.account_balance,
                                            size: 16,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      if (item.filtros.uf != null)
                                        Chip(
                                          label: Text('UF: ${item.filtros.uf}'),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      Chip(
                                        label: Text(
                                          'Limite: ${item.filtros.limite}',
                                        ),
                                        avatar: const Icon(
                                          Icons.format_list_numbered,
                                          size: 16,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Ações do Cartão
                            ElevatedButton.icon(
                              onPressed: () => onRepetirBusca(item.filtros),
                              icon: const Icon(Icons.replay_rounded, size: 18),
                              label: const Text('Repetir Busca'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              tooltip: 'Excluir registro',
                              onPressed: () =>
                                  historicoService.removerItem(item.id),
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
      },
    );
  }
}
