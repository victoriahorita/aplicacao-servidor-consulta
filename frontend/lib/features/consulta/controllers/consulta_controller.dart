import 'package:consulta_servidor/features/consulta/controllers/consulta_state.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:flutter/material.dart';

class ConsultaController extends ChangeNotifier {
  final ServidorRepository _servidorRepository;

  ConsultaState _actualState = ConsultaInitial();
  ConsultaState get actualState => _actualState;

  // Guarda o último filtro executado no sistema
  ServidorFiltros? filtrosAtivos;

  ConsultaController(this._servidorRepository);

  Future<ResultadoPaginado> buscarServidores(ServidorFiltros filtros) async {
    filtrosAtivos = filtros;
    _actualState = ConsultaLoading();
    notifyListeners();

    try {
      final ResultadoPaginado resultado = await _servidorRepository
          .buscarServidores(filtros);

      _actualState = ConsultaSuccess(resultado);
      notifyListeners();

      return resultado;
    } catch (erro) {
      final mensagemFormatada = erro
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('FormatException: ', '');

      _actualState = ConsultaError('Falha na consulta: $mensagemFormatada');
      notifyListeners();

      rethrow;
    }
  }

  void resetarBusca() {
    filtrosAtivos = null;
    _actualState = ConsultaInitial();
    notifyListeners();
  }
}
