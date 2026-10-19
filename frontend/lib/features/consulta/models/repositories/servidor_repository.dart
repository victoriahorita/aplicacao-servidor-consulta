import 'dart:async';
import 'dart:convert';

import 'package:consulta_servidor/core/config/app_config.dart';
import 'package:consulta_servidor/core/utils/input_sanitizier.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:http/http.dart' as http;

/// [ServidorRepository] é a camada de comunicação com a API.
class ServidorRepository {
  final http.Client _httpClient;

  ServidorRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Consulta os servidores consumindo a rota GET /api/servidores do Flask
  Future<List<Servidor>> buscarServidores(ServidorFiltros filtros) async {
    // 1. Validação defensiva (Evita enviar parâmetros inválidos)
    if (!InputSanitizer.validarUf(filtros.uf)) {
      throw const FormatException('A UF informada é inválida.');
    }

    final Map<String, String> queryParams = {};

    if (filtros.nome != null && filtros.nome!.isNotEmpty) {
      final nomeSanitizado = InputSanitizer.sanitizarNome(
        filtros.nome!,
        buscaSimilar: filtros.buscaSimilar,
      );

      // Conforme o api.py: se for similaridade usa ?similar=, senão usa ?nome=
      if (filtros.buscaSimilar) {
        queryParams['similar'] = nomeSanitizado;
      } else {
        queryParams['nome'] = nomeSanitizado;
      }
    }

    if (filtros.cargo != null && filtros.cargo!.isNotEmpty) {
      queryParams['cargo'] = filtros.cargo!;
    }

    if (filtros.uf != null && filtros.uf!.isNotEmpty) {
      queryParams['uf'] = filtros.uf!.toUpperCase().trim();
    }

    if (filtros.orgao != null && filtros.orgao!.isNotEmpty) {
      queryParams['orgao'] = filtros.orgao!;
    }

    // Conforme o api.py: limite de registros retornados
    queryParams['limite'] = filtros.limite.toString();

    // 3. Construção robusta e dinâmica da URL sem hardcode
    final baseUrl = Uri.parse('${AppConfig.apiBaseUrl}/api/servidores');
    final urlFinal = baseUrl.replace(queryParameters: queryParams);

    try {
      // 4. Execução da chamada HTTP com Timeout configurável
      final resposta = await _httpClient
          .get(urlFinal)
          .timeout(
            Duration(seconds: AppConfig.timeoutSegundos),
            onTimeout: () {
              throw TimeoutException(
                'Tempo limite de busca excedido (${AppConfig.timeoutSegundos}s). O banco de dados demorou para responder.',
              );
            },
          );

      // 5. Tratamento de códigos de status HTTP
      switch (resposta.statusCode) {
        case 200:
          final List<dynamic> listaJson = jsonDecode(
            utf8.decode(resposta.bodyBytes),
          );

          return listaJson
              .map(
                (mapa) => Servidor(
                  id: mapa['id'] as int,
                  nome: mapa['nome'] as String,
                  cpf: mapa['cpf'] as String,
                  cargo: mapa['cargo'] as String,
                  uf: mapa['uf'] as String? ?? 'Não informado',
                  orgao: mapa['orgao'] as String,
                  remuneracao: (mapa['remuneracao'] as num).toDouble(),
                ),
              )
              .toList();

        case 503:
          throw Exception('O banco de dados está indisponível.');

        case 400:
          throw const FormatException(
            'Parâmetros de busca inválidos enviados à API.',
          );

        default:
          throw Exception(
            'Falha na resposta do servidor: Código HTTP ${resposta.statusCode}',
          );
      }
    } on TimeoutException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (erro) {
      throw Exception('Não foi possível se conectar à API Flask: $erro');
    }
  }
}
