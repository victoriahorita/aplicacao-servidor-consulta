import 'package:flutter/material.dart';

class ScreenBuscaDashboard extends StatelessWidget {
  const ScreenBuscaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32.0),
      children: [
        // 1. Cabeçalho da tela
        const Text(
          'Use os filtros abaixo para encontrar os servidores desejados.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // 2. Formulário de Busca (Modularizado)
        const FormularioBuscaWeb(),

        const SizedBox(height: 32),

        // 3. Cartões de Estatísticas (Row + Expanded para dividir igual em Web)
        Row(
          children: const [
            Expanded(
              child: StatCard(
                titulo: 'Total de registros',
                valor: '1.234.567',
                icone: Icons.people,
                corIcone: Colors.blue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                titulo: 'Servidores ativos',
                valor: '876.543',
                icone: Icons.check_circle_outline,
                corIcone: Colors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                titulo: 'Aposentados',
                valor: '358.024',
                icone: Icons.history,
                corIcone: Colors.purple,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                titulo: 'Órgãos / Instituições',
                valor: '412',
                icone: Icons.account_balance,
                corIcone: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
