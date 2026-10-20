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

  String get remuneracaoFormatada =>
      AppFormatters.formatarMoeda(remuneracao / 100);

  factory Servidor.fromJson(Map<String, dynamic> map) {
    return Servidor(
      id: map['id'] as int? ?? map['cpf'].hashCode,
      nome: map['nome'] as String? ?? 'Sem nome',
      cpf: map['cpf'] as String? ?? '000.000.000-00',
      cargo: map['cargo'] as String? ?? 'Não informado',
      uf: map['uf'] as String? ?? 'Não informado',
      orgao: map['orgao'] as String? ?? 'Não informado',
      // Converte num para double, tratando se vier null
      remuneracao: (map['remuneracao'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// DTO
class ResultadoPaginado {
  final int totalRegistros;
  final List<Servidor> servidores;

  const ResultadoPaginado({
    required this.totalRegistros,
    required this.servidores,
  });
}
