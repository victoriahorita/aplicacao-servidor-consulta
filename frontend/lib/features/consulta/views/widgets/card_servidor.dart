import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:flutter/material.dart';

class CardServidor extends StatelessWidget {
  final Servidor servidor;
  final VoidCallback onTap;

  const CardServidor({super.key, required this.servidor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Usamos o Card para dar a elevação e a borda arredondada.
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar com as iniciais do órgão
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  servidor.orgao.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servidor.nome,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${servidor.cargo} • ${servidor.uf}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Remuneração em destaque na direita
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Remuneração',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    servidor.remuneracaoFormatada,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
