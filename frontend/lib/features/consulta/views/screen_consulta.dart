import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_state.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/views/detalhes_servidor.dart';
import 'package:consulta_servidor/features/consulta/views/widgets/card_servidor.dart';
import 'package:flutter/material.dart';

class ScreenConsulta extends StatefulWidget {
  const ScreenConsulta({super.key});

  @override
  State<ScreenConsulta> createState() => _ScreenConsultaState();
}

class _ScreenConsultaState extends State<ScreenConsulta> {
  late final ServidorRepository repository;
  late final ConsultaController controller;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    repository = ServidorRepository();
    controller = ConsultaController(repository);
  }

  @override
  void dispose() {
    textController.dispose();
    controller.dispose();
    super.dispose();
  }

  void inSubmit() {
    final query = textController.text.trim();
    if (query.isNotEmpty) {
      controller.realizarBusca(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Dados dos Servidores Publicos'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Digite o nome do servidor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => inSubmit(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    SizedBox(
                      height: 56.0, // Ajustado para alinhar com a altura do TextField
                      child: ElevatedButton.icon(
                        onPressed: inSubmit,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) {
                      final state = controller.actualState;

                      return switch (state) {
                        ConsultaInitial() => const Center(
                          child: Text(
                            'Digite o nome do servidor e pressione "Buscar"',
                          ),
                        ),
                        ConsultaLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        ConsultaSuccess(:final servidores) =>
                          servidores.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum servidor encontrado com esse nome.',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: servidores.length,
                                  itemBuilder: (context, index) {
                                    final servidor = servidores[index];

                                    // AQUI USAMOS O NOSSO NOVO COMPONENTE
                                    return CardServidor(
                                      servidor: servidor,
                                      onTap: () {
                                        // Navegação no Flutter: Empurramos (push) uma nova rota
                                        // por cima da tela atual, passando o servidor clicado.
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ScreenDetalhesServidor(
                                                  servidor: servidor,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ConsultaError(:final message) => Center(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      };
                    },
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
