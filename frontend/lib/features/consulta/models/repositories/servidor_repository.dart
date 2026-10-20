import 'dart:async';
import 'dart:convert';

import 'package:consulta_servidor/core/config/app_config.dart';
import 'package:consulta_servidor/core/utils/input_sanitizier.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';
import 'package:http/http.dart' as http;

class ServidorRepository {
  final http.Client _httpClient;

  ServidorRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Retorna o [ResultadoPaginado] contendo o total geral no banco e a lista da página atual.
  Future<ResultadoPaginado> buscarServidores(ServidorFiltros filtros) async {
    if (!InputSanitizer.validarUf(filtros.uf)) {
      throw const FormatException('A UF informada é inválida.');
    }

    final Map<String, String> queryParams = {};

    if (filtros.nome != null && filtros.nome!.isNotEmpty) {
      final nomeSanitizado = InputSanitizer.sanitizarNome(
        filtros.nome!,
        buscaSimilar: filtros.buscaSimilar,
      );

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

    queryParams['limit'] = filtros.limite.toString();
    queryParams['page'] = filtros.pagina.toString();

    final baseUrl = Uri.parse('${AppConfig.apiBaseUrl}/api/servidores');
    final urlFinal = baseUrl.replace(queryParameters: queryParams);

    try {
      final resposta = await _httpClient
          .get(urlFinal)
          .timeout(
            Duration(seconds: AppConfig.timeoutSegundos),
            onTimeout: () {
              throw TimeoutException(
                'O tempo limite de busca foi excedido. O banco de dados demorou para responder.',
              );
            },
          );

      switch (resposta.statusCode) {
        case 200:
          final Map<String, dynamic> bodyJson = jsonDecode(
            utf8.decode(resposta.bodyBytes),
          );

          final int total = bodyJson['total'] as int? ?? 0;
          final List<dynamic> dados = bodyJson['data'] as List<dynamic>? ?? [];

          final servidores = dados
              .map((mapa) => Servidor.fromJson(mapa))
              .toList();

          return ResultadoPaginado(
            totalRegistros: total,
            servidores: servidores,
          );

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
      throw Exception('Não foi possível se conectar à API: $erro');
    }
  }
}
