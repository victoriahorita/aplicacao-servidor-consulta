import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:flutter/material.dart';

class ScreenConsulta extends StatefulWidget {
  const ScreenConsulta({super.key});

  @override
  State<ScreenConsulta> createState() => _ScreenConsultaState();
}

class _ScreenConsultaState extends State<ScreenConsulta> {
  @override
  Widget build(BuildContext context) {
    // Inicializa o repositório e o controlador
    late final ServidorRepository repository;
    late final ConsultaController controller;

    // Controlador para acessar o texto no campo de busca
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
      controller.realizarBusca(textController.text);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Consulta de Dados dos Servidores Publicos'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  }
}
