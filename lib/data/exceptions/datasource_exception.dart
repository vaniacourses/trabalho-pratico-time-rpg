/// Uma exceção personalizada para encapsular erros que ocorrem na camada de dados.
class DatasourceException implements Exception {
  final String message;
  final dynamic originalException;

  DatasourceException({required this.message, this.originalException});

  @override
  String toString() {
    return 'DatasourceException: $message | Causa Original: $originalException';
  }
}