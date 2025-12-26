class RabbitHoleSuggestion {
  final String topic;
  final String hook;
  final String category;

  RabbitHoleSuggestion({
    required this.topic,
    required this.hook,
    required this.category,
  });

  factory RabbitHoleSuggestion.fromJson(Map<String, dynamic> json) {
    return RabbitHoleSuggestion(
      topic: json['tema'] ?? 'Misterio Desconocido',
      hook: json['gancho'] ?? 'Información clasificada.',
      category: json['categoria'] ?? 'General',
    );
  }
}
