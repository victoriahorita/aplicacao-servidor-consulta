import 'package:consulta_servidor/core/utils/app_formatters.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';

class ItemHistorico {
  final String id;
  final ServidorFiltros filtros;
  final DateTime dataHora;
  final int totalResultados;

  const ItemHistorico({
    required this.id,
    required this.filtros,
    required this.dataHora,
    required this.totalResultados,
  });

  String get dataFormatada => AppFormatters.formatarDataHora(dataHora);
}
