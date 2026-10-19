// ARQUIVO: lib/features/consulta/views/screen_detalhes_servidor.dart

import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:flutter/material.dart';

class ScreenDetalhesServidor extends StatelessWidget {
  final Servidor servidor;

  const ScreenDetalhesServidor({super.key, required this.servidor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Servidor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        // ConstrainedBox mantém o formulário elegante em monitores grandes
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Cabeçalho Principal
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        servidor.nome,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('${servidor.cargo} - ${servidor.uf}'),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tabela de Dados Detalhados
              Text(
                'Informações Profissionais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _LinhaDetalhe(
                      titulo: 'CPF (Mascarado)',
                      valor: servidor.cpf,
                      icone: Icons.badge,
                    ),
                    const Divider(height: 1),
                    _LinhaDetalhe(
                      titulo: 'Órgão de Lotação',
                      valor: servidor.orgao,
                      icone: Icons.account_balance,
                    ),
                    const Divider(height: 1),
                    _LinhaDetalhe(
                      titulo: 'Remuneração Bruta',
                      valor: servidor.remuneracaoFormatada,
                      icone: Icons.attach_money,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um widget local privado (_) para reaproveitar o layout de cada linha de detalhe
class _LinhaDetalhe extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _LinhaDetalhe({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
