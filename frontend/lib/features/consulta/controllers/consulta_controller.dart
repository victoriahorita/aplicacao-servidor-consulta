import 'package:consulta_servidor/features/consulta/controllers/consulta_state.dart';
import 'package:consulta_servidor/features/consulta/models/repositories/servidor_repository.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:flutter/material.dart';

/// [ConsultaController] gerencia o estado da consulta de servidores públicos,
/// comunicando-se com o repositório de dados e notificando a interface gráfica.
class ConsultaController extends ChangeNotifier {
  final ServidorRepository _servidorRepository;

  // Estado interno privado (Encapsulamento)
  ConsultaState _actualState = ConsultaInitial();

  /// Getter público que permite à UI apenas ler o estado atual, nunca alterá-lo diretamente.
  ConsultaState get actualState => _actualState;

  /// Injeção de dependência: o repositório é fornecido via construtor.
  ConsultaController(this._servidorRepository);

  /// Executa a busca no repositório aplicando os filtros combinados.
  /// Retorna a lista de [Servidor] para permitir decisões de navegação imediatas na UI.
  Future<List<Servidor>> buscarServidores(ServidorFiltros filtros) async {
    // 1. Notifica a UI de que a busca iniciou (útil para ListenableBuilder)
    _actualState = ConsultaLoading();
    notifyListeners();

    try {
      // 2. Chama o repositório com o pacote completo de filtros
      final List<Servidor> servidores = await _servidorRepository
          .buscarServidores(filtros);

      // 3. Atualiza para o estado de Sucesso com a lista retornada
      _actualState = ConsultaSuccess(servidores);
      notifyListeners();

      // 4. Retorna a lista para o chamador (a tela)
      return servidores;
    } catch (erro) {
      // Formata a mensagem de erro removendo prefixos de exceção genéricos
      final mensagemFormatada = erro.toString().replaceAll('Exception: ', '');

      // 5. Registra o estado de erro
      _actualState = ConsultaError(
        'Erro ao consultar servidores: $mensagemFormatada',
      );
      notifyListeners();

      // Repassa o erro adiante para que a View possa disparar o diálogo de alerta visual
      rethrow;
    }
  }

  /// Limpa a busca e redefine o estado para o momento inicial.
  /// Excelente para o botão "Limpar filtros" da interface.
  void resetarBusca() {
    _actualState = ConsultaInitial();
    notifyListeners();
  }
}
