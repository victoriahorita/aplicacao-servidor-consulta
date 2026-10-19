import 'package:consulta_servidor/features/consulta/controllers/consulta_state.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:flutter/material.dart';

class ConsultaController extends ChangeNotifier {
  final ServidorRepository _servidorRepository;

  // controlador aguarda o estado atual
  ConsultaState _state = ConsultaInitial();

  // INjeção de dependência do repositório de servidores
  ConsultaController(this._servidorRepository);

  Future<void> realizarBusca(String nome) async {
    _state = ConsultaLoading();
    notifyListeners();

    try {
      final servidores = await _servidorRepository.buscarServidores(nome);
      _state = ConsultaSuccess(servidores);
    } catch (e) {
      _state = ConsultaError('Erro ao buscar servidores: $e');
    } finally {
      notifyListeners();
    }
  }
}
