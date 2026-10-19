import 'package:flutter/material.dart';

class FormBusca extends StatelessWidget {
  const FormBusca({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1 de filtros
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _CampoComLabel(
                    label: 'Nome',
                    hint: 'Digite o nome...',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _CampoComLabel(
                    label: 'Cargo / Profissão',
                    hint: 'Ex: Professor',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _CampoComLabel(
                    label: 'UF',
                    hint: 'Selecione',
                    isDropdown: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linha 2 de filtros
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _CampoComLabel(
                    label: 'Órgão / Instituição',
                    hint: 'Digite o órgão...',
                    icone: Icons.search,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _CampoComLabel(
                    label: 'Tipo de vínculo',
                    hint: 'Todos',
                    isDropdown: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {}, // Abriria o Modal de Filtros Avançados
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Busca avançada'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Chamar o Controller aqui e navegar para a tela de Tabela
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Um widget utilitário privado para manter o design limpo (Label em cima, Input embaixo)
class _CampoComLabel extends StatelessWidget {
  final String label;
  final String hint;
  final bool isDropdown;
  final IconData? icone;

  const _CampoComLabel({
    required this.label,
    required this.hint,
    this.isDropdown = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textoPrincipal,
          ),
        ),
        const SizedBox(height: 8),
        isDropdown
            ? DropdownButtonFormField<String>(
                decoration: const InputDecoration(),
                items: [],
                onChanged: (val) {},
                hint: Text(hint),
              )
            : TextField(
                decoration: InputDecoration(
                  hintText: hint,
                  suffixIcon: icone != null
                      ? Icon(icone, color: Colors.grey)
                      : null,
                ),
              ),
      ],
    );
  }
}
