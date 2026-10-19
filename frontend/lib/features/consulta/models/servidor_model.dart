import 'package:intl/intl.dart';

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

  String get remuneracaoFormatada {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(remuneracao);
  }
}
