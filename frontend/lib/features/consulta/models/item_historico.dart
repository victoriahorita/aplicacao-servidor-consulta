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

  String get dataFormatada {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$minuto';
  }
}
