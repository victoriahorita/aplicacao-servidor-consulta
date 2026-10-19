import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:flutter/material.dart';

class ServidorDataSource extends DataTableSource {
  final List<Servidor> servidores;
  final BuildContext context;
  final ValueChanged<Servidor> onVerDetalhes;

  ServidorDataSource({
    required this.servidores,
    required this.context,
    required this.onVerDetalhes,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= servidores.length) return null;

    final servidor = servidores[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.25);
        }
        return null;
      }),
      cells: [
        // Coluna 1: Nome com Avatar
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  servidor.nome.isNotEmpty
                      ? servidor.nome[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                servidor.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        // Coluna 2: Cargo
        DataCell(Text(servidor.cargo)),
        // Coluna 3: Órgão
        DataCell(Text(servidor.orgao)),
        // Coluna 4: UF com Chip visual
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              servidor.uf,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Coluna 5: Remuneração Formatada
        DataCell(
          Text(
            servidor.remuneracaoFormatada,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF15803D),
            ),
          ),
        ),
        // Coluna 6: Ação com feedback visual
        DataCell(
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF0284C7),
            ),
            tooltip: 'Visualizar dados completos',
            onPressed: () => onVerDetalhes(servidor),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => servidores.length;

  @override
  int get selectedRowCount => 0;
}
