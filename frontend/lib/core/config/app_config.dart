/// [AppConfig] centraliza todas as variáveis de ambiente do aplicativo.
/// Permite alternar entre desenvolvimento local, contêiner Docker e produção
/// sem alterar uma única linha de código Dart.
class AppConfig {
  /// URL base da API Flask.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  /// Timeout global para requisições HTTP (em segundos)
  static const int timeoutSegundos = int.fromEnvironment(
    'API_TIMEOUT_SEGUNDOS',
    defaultValue: 10,
  );
}
