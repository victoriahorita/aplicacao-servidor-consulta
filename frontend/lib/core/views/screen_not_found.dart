import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:flutter/material.dart';

class ScreenNotFound extends StatelessWidget {
  const ScreenNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      titulo: 'Página Não Encontrada',
      indiceMenuAtivo: -1, // Nenhum menu ativo
      mostrarBotaoVoltar: false,
      conteudo: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_off_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '404',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Endereço ou Página Inexistente',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'A rota solicitada não existe ou foi removida do sistema de consulta.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/buscar', (route) => false);
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Voltar para a Página de Busca'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
