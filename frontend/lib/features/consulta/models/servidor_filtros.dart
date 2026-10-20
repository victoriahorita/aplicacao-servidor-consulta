class ServidorFiltros {
  final String? nome;
  final String? cargo;
  final String? uf;
  final String? orgao;
  final bool buscaSimilar;
  final int limite;
  final int pagina;

  const ServidorFiltros({
    this.nome,
    this.cargo,
    this.uf,
    this.orgao,
    this.buscaSimilar = false,
    this.limite = 100,
    this.pagina = 1,
  });
}
