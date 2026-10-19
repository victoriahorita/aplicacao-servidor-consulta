import '../servidor_filtros.dart';
import '../servidor_model.dart';

/// [ServidorRepository] é a camada de acesso a dados (Data Layer).
/// Atualmente utiliza dados mockados em memória para desenvolvimento ágil,
/// mas possui a exata mesma assinatura exigida para chamadas HTTP com a API Flask.
class ServidorRepository {
  // Base de dados mockada expandida para testar múltiplos cenários de busca
  final List<Servidor> _servidoresDb = const [
    Servidor(
      id: 1,
      nome: 'João Silva',
      cpf: '123.456.789-00',
      cargo: 'Analista de Infraestrutura',
      uf: 'DF',
      orgao: 'Ministério da Educação',
      remuneracao: 8500.00,
    ),
    Servidor(
      id: 2,
      nome: 'Maria Souza',
      cpf: '987.654.321-00',
      cargo: 'Professora do Magistério Superior',
      uf: 'RJ',
      orgao: 'Universidade Federal',
      remuneracao: 9200.50,
    ),
    Servidor(
      id: 3,
      nome: 'João Sarney Silva',
      cpf: '143.456.789-00',
      cargo: 'Analista de Sistemas',
      uf: 'DF',
      orgao: 'Ministério da Economia',
      remuneracao: 11400.00,
    ),
    Servidor(
      id: 4,
      nome: 'Carlos Alberto Souza',
      cpf: '234.567.890-11',
      cargo: 'Auditor Fiscal',
      uf: 'SP',
      orgao: 'Receita Federal',
      remuneracao: 21000.00,
    ),
    Servidor(
      id: 5,
      nome: 'Fernanda Rodrigues',
      cpf: '345.678.901-22',
      cargo: 'Assistente Administrativo',
      uf: 'BA',
      orgao: 'Ministério da Saúde',
      remuneracao: 4300.00,
    ),
    Servidor(
      id: 6,
      nome: 'Ricardo Martins',
      cpf: '456.789.012-33',
      cargo: 'Engenheiro Civil',
      uf: 'RS',
      orgao: 'Ministério da Infraestrutura',
      remuneracao: 10800.00,
    ),
    Servidor(
      id: 7,
      nome: 'Juliana Ferreira',
      cpf: '567.890.123-44',
      cargo: 'Técnica de Enfermagem',
      uf: 'DF',
      orgao: 'Hospital das Forças Armadas',
      remuneracao: 5100.00,
    ),
  ];

  /// Consulta os servidores aplicando múltiplos filtros simultâneos.
  Future<List<Servidor>> buscarServidores(ServidorFiltros filtros) async {
    // 1. Simula latência de conexão com o banco de dados (1 segundo)
    await Future.delayed(const Duration(milliseconds: 1000));

    // 2. Simulação de falha: permite testar como o app reage a erros do servidor
    if (filtros.nome != null && filtros.nome!.toLowerCase() == 'erro') {
      throw Exception(
        'Falha temporária ao comunicar com o banco de dados PostgreSQL.',
      );
    }

    // 3. Aplicação encadeada de filtros (Busca Combinada Avançada)
    return _servidoresDb.where((servidor) {
      // Filtro por Nome (suporta busca exata ou por similaridade)
      if (filtros.nome != null && filtros.nome!.isNotEmpty) {
        final nomeFiltro = filtros.nome!.toLowerCase();
        final nomeServidor = servidor.nome.toLowerCase();

        if (filtros.buscaSimilar) {
          // Busca por similaridade: contém o trecho digitado
          if (!nomeServidor.contains(nomeFiltro)) return false;
        } else {
          // Busca exata: o nome precisa ser idêntico
          if (nomeServidor != nomeFiltro) return false;
        }
      }

      // Filtro por Cargo / Profissão
      if (filtros.cargo != null && filtros.cargo!.isNotEmpty) {
        final cargoFiltro = filtros.cargo!.toLowerCase();
        final cargoServidor = servidor.cargo.toLowerCase();
        if (!cargoServidor.contains(cargoFiltro)) return false;
      }

      // Filtro por Unidade Federativa (UF)
      if (filtros.uf != null && filtros.uf!.isNotEmpty) {
        final ufFiltro = filtros.uf!.toUpperCase();
        final ufServidor = servidor.uf.toUpperCase();
        if (ufServidor != ufFiltro) return false;
      }

      // Filtro por Órgão / Instituição
      if (filtros.orgao != null && filtros.orgao!.isNotEmpty) {
        final orgaoFiltro = filtros.orgao!.toLowerCase();
        final orgaoServidor = servidor.orgao.toLowerCase();
        if (!orgaoServidor.contains(orgaoFiltro)) return false;
      }

      // Passou por todos os critérios ativos
      return true;
    }).toList();
  }
}
