import 'package:consulta_servidor/features/consulta/controllers/consulta_state.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:flutter/material.dart';

class ConsultaController extends ChangeNotifier {
  final ServidorRepository _servidorRepository;

  // controlador aguarda o estado atual
  ConsultaState actualState = ConsultaInitial();

  // INjeção de dependência do repositório de servidores
  ConsultaController(this._servidorRepository);

  Future<void> realizarBusca(String nome) async {
    actualState = ConsultaLoading();
    notifyListeners();

    try {
      final servidores = await _servidorRepository.buscarServidores(nome);
      actualState = ConsultaSuccess(servidores);
    } catch (e) {
      actualState = ConsultaError('Erro ao buscar servidores: $e');
    } finally {
      notifyListeners();
    }
  }
}
