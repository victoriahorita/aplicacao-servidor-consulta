// ARQUIVO: lib/features/consulta/models/servidor_filtros.dart

/// Classe que encapsula todos os parâmetros permitidos pela API Flask.
class ServidorFiltros {
  final String? nome;
  final String? cargo;
  final String? uf;
  final String? orgao;
  final bool buscaSimilar;
  final int limite;

  const ServidorFiltros({
    this.nome,
    this.cargo,
    this.uf,
    this.orgao,
    this.buscaSimilar = false,
    this.limite = 100,
  });
}
