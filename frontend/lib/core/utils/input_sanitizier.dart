class InputSanitizer {
  // Padrões perigosos frequentemente usados em SQL Injection
  static final RegExp _padraoSqlInseguro = RegExp(
    r"('|--|;|/\*|\*/|xp_|union|select|insert|update|delete|drop|truncate)",
    caseSensitive: false,
  );

  /// Sanitiza e valida o termo de busca por nome.
  /// Lança uma [FormatException] se detectar tentativas de injeção.
  static String sanitizarNome(String texto, {required bool buscaSimilar}) {
    final valorLimpo = texto.trim();

    if (_padraoSqlInseguro.hasMatch(valorLimpo)) {
      throw const FormatException(
        'Entrada inválida: Caracteres ou palavras reservadas não permitidas.',
      );
    }

    if (!buscaSimilar) {
      return valorLimpo;
    }

    // Se for busca similar e o usuário já digitou o caractere %, respeitamos a sintaxe do PDF
    if (valorLimpo.contains('%')) {
      return valorLimpo;
    }

    // Se ele digitou palavras normais (ex: "Maria Silva"), convertemos para "%Maria%Silva%"
    final partes = valorLimpo.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return '%${partes.join('%')}%';
  }

  /// Valida se a UF enviada pertence à lista real dos estados brasileiros
  static bool validarUf(String? uf) {
    if (uf == null || uf.isEmpty) return true; // UF é opcional

    const ufsValidas = {
      'AC',
      'AL',
      'AP',
      'AM',
      'BA',
      'CE',
      'DF',
      'ES',
      'GO',
      'MA',
      'MT',
      'MS',
      'MG',
      'PA',
      'PB',
      'PR',
      'PE',
      'PI',
      'RJ',
      'RN',
      'RS',
      'RO',
      'RR',
      'SC',
      'SP',
      'SE',
      'TO',
    };

    return ufsValidas.contains(uf.toUpperCase().trim());
  }
}
