import 'package:consulta_servidor/features/historico/models/item_historico.dart';
import 'package:flutter/material.dart';

import '../../consulta/models/servidor_filtros.dart';

class HistoricoService extends ChangeNotifier {
  static final HistoricoService _instancia = HistoricoService._interno();
  factory HistoricoService() => _instancia;
  HistoricoService._interno();

  final List<ItemHistorico> _historico = [];

  List<ItemHistorico> get itens => List.unmodifiable(_historico);

  /// Registra uma busca realizada no histórico do frontend
  void salvarBusca({
    required ServidorFiltros filtros,
    required int totalResultados,
  }) {
    // Evita duplicatas idênticas consecutivas
    _historico.removeWhere(
      (item) =>
          item.filtros.nome == filtros.nome &&
          item.filtros.cargo == filtros.cargo &&
          item.filtros.uf == filtros.uf &&
          item.filtros.orgao == filtros.orgao,
    );

    // Insere sempre no topo da lista (mais recente primeiro)
    _historico.insert(
      0,
      ItemHistorico(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filtros: filtros,
        dataHora: DateTime.now(),
        totalResultados: totalResultados,
      ),
    );

    // Mantém no máximo os últimos 20 registros para economizar memória
    if (_historico.length > 20) {
      _historico.removeLast();
    }

    notifyListeners();
  }

  void removerItem(String id) {
    _historico.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void limparTudo() {
    _historico.clear();
    notifyListeners();
  }
}
