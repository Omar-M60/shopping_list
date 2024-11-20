class ValidatorResponse {
  const ValidatorResponse({
    required this.message,
    required this.status,
  });

  final bool status;
  final String message;
}
