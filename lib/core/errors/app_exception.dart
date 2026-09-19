class AppException implements Exception {
  const AppException({required this.code, required this.userMessage, this.debugMessage});

  final String code;
  final String userMessage;
  final String? debugMessage;

  @override
  String toString() => debugMessage ?? userMessage;
}
