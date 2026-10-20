import 'package:consulta_servidor/core/layout/main_layout.dart';
import 'package:consulta_servidor/core/utils/app_feedback.dart';
import 'package:consulta_servidor/core/utils/navigation_utils.dart';
import 'package:consulta_servidor/features/consulta/controllers/consulta_controller.dart';
import 'package:consulta_servidor/features/consulta/models/servidor_filtros.dart';
import 'package:consulta_servidor/features/consulta/views/screens/consulta_resultados.dart';
import 'package:consulta_servidor/features/consulta/views/screens/detalhes_servidor.dart';
import 'package:consulta_servidor/features/historico/services/historico_services.dart';
import 'package:flutter/material.dart';

class ConsultaFlow {
  /// Executa uma busca a partir de QUALQUER tela e direciona para os resultados
  static Future<void> executar({
    required BuildContext context,
    required ConsultaController controller,
    required ServidorFiltros filtros,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 20),
                Text(
                  'Consultando servidores...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Chama a API através do Controller
      final resultado = await controller.buscarServidores(filtros);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fecha o diálogo de loading

      final servidores = resultado.servidores;

      // Salva no histórico automaticamente
      HistoricoService().salvarBusca(
        filtros: filtros,
        totalResultados: resultado.totalRegistros,
      );

      // 4. Decisão de Roteamento
      if (servidores.isEmpty) {
        AppFeedback.mostrarAlerta(
          context,
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum servidor encontrado',
          mensagem: 'Não encontramos registros com os critérios informados.',
        );
      } else if (servidores.length == 1) {
        Navigator.of(context).push(
          NavigationUtils.criarRotaFade(
            MainLayout(
              titulo: 'Detalhes do Servidor',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenDetalhesServidor(servidor: servidores.first),
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          NavigationUtils.criarRotaFade(
            MainLayout(
              titulo: 'Resultados da Consulta',
              indiceMenuAtivo: 1,
              mostrarBotaoVoltar: true,
              conteudo: ScreenResultados(
                resultado: resultado,
                filtrosAtuais: filtros,
                controller: controller, // Repassa o controller para filtros subsequentes
              ),
            ),
          ),
        );
      }
    } catch (erro) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        AppFeedback.mostrarAlerta(
          context,
          icone: Icons.cloud_off_rounded,
          titulo: 'Falha na Consulta',
          mensagem: erro.toString(),
          isErro: true,
        );
      }
    }
  }
}
