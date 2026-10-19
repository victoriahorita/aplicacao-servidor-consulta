// ARQUIVO: lib/core/widgets/status_conexao_banco.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

enum EstadoConexao { verificando, conectado, desconectado }

/// [StatusConexaoBanco] monitora a rota /health/ do backend Flask e exibe
/// um indicador visual  na barra lateral.
class StatusConexaoBanco extends StatefulWidget {
  const StatusConexaoBanco({super.key});

  @override
  State<StatusConexaoBanco> createState() => _StatusConexaoBancoState();
}

class _StatusConexaoBancoState extends State<StatusConexaoBanco> {
  EstadoConexao _estado = EstadoConexao.verificando;
  Timer? _timerPeriodico;

  @override
  void initState() {
    super.initState();
    _checarSaudeBanco();
    // Executa a checagem automática a cada 30 segundos
    _timerPeriodico = Timer.periodic(const Duration(seconds: 30), (_) {
      _checarSaudeBanco();
    });
  }

  @override
  void dispose() {
    _timerPeriodico?.cancel();
    super.dispose();
  }

  Future<void> _checarSaudeBanco() async {
    if (!mounted) return;
    setState(() => _estado = EstadoConexao.verificando);

    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/health/');
      final resposta = await http.get(url).timeout(const Duration(seconds: 4));

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        if (dados['database'] == 'connected') {
          setState(() => _estado = EstadoConexao.conectado);
          return;
        }
      }
      setState(() => _estado = EstadoConexao.desconectado);
    } catch (_) {
      if (mounted) {
        setState(() => _estado = EstadoConexao.desconectado);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color corStatus, String texto, String tooltip) = switch (_estado) {
      EstadoConexao.conectado => (
        Colors.greenAccent.shade400,
        'Online',
        'Banco de dados operacional e respondendo a consultas.',
      ),
      EstadoConexao.desconectado => (
        Colors.redAccent.shade200,
        'Offline',
        'Falha de comunicação com o SGBD PostgreSQL (HTTP 503). Toque para tentar novamente.',
      ),
      EstadoConexao.verificando => (
        Colors.amber.shade300,
        'Verificando SGBD...',
        'Testando rota de saúde /health/ no servidor Flask.',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: _checarSaudeBanco,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador luminoso sutil com sombra
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: corStatus,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: corStatus.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.refresh,
                size: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
