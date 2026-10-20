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
    final colors = Theme.of(context).colorScheme;

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return colors.primaryContainer.withValues(alpha: 0.25);
        }
        return null;
      }),
      cells: [
        // Coluna 1: Nome com Avatar e Hero
        DataCell(
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${servidor.id}',
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      servidor.nome.isNotEmpty
                          ? servidor.nome[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tooltip(
                    message: servidor.nome,
                    child: Text(
                      servidor.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Coluna 2: Cargo
        DataCell(
          SizedBox(
            width: 200,
            child: Tooltip(
              message: servidor.cargo,
              child: Text(
                servidor.cargo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        // Coluna 3: Órgão
        DataCell(
          SizedBox(
            width: 220,
            child: Tooltip(
              message: servidor.orgao,
              child: Text(
                servidor.orgao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        // Coluna 4: UF
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              servidor.uf,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSecondaryContainer,
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

        // Coluna 6: Botão de Ação
        DataCell(
          SizedBox(
            width: 50,
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colors.primary,
              ),
              tooltip: 'Visualizar dados completos',
              onPressed: () => onVerDetalhes(servidor),
            ),
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
