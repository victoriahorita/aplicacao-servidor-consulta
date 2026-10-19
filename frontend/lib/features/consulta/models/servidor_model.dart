import 'package:consulta_servidor/core/utils/app_formatters.dart';

class Servidor {
  final int id;
  final String nome;
  final String cpf;
  final String cargo;
  final String uf;
  final String orgao;
  final double remuneracao;

  const Servidor({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.cargo,
    required this.uf,
    required this.orgao,
    required this.remuneracao,
  });

  String get remuneracaoFormatada => AppFormatters.formatarMoeda(remuneracao);
}
