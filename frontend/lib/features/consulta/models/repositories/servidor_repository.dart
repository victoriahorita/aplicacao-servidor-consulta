import 'package:consulta_servidor/features/consulta/models/servidor_model.dart';

class ServidorRepository {
  // Dados Mockados
  final List<Servidor> _servidores_db = [
    Servidor(
      id: 1,
      nome: 'João Silva',
      cpf: '123.456.789-00',
      cargo: 'Analista',
      uf: 'SP',
      orgao: 'Secretaria de Educação',
      remuneracao: 5000.00,
    ),
    Servidor(
      id: 2,
      nome: 'Maria Souza',
      cpf: '987.654.321-00',
      cargo: 'Professor',
      uf: 'RJ',
      orgao: 'Secretaria de Saúde',
      remuneracao: 4500.00,
    ),
    Servidor(
      id: 3,
      nome: 'João Sarney Silva',
      cpf: '143.456.789-00',
      cargo: 'Analista Plano',
      uf: 'RJ',
      orgao: 'Secretaria de Educação',
      remuneracao: 7000.00,
    ),
  ];

  // Busca produtos no backend pelo nome, retorna um [Future] porque é assincrono.
  Future<List<Servidor>> buscarServidores(String nome) async {
    // Simula um atraso de 2 segundos para imitar uma chamada de rede
    await Future.delayed(const Duration(seconds: 2));

    // Filtra os servidores pelo nome (case insensitive)
    return _servidores_db
        .where(
          (servidor) =>
              servidor.nome.toLowerCase().contains(nome.toLowerCase()),
        )
        .toList();
  }
}
