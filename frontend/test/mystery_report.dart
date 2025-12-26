class MysteryReport {
  final String source;
  final String executiveSummary;
  final String evidenceLevel;
  final List<String> tags;

  MysteryReport({
    required this.source,
    required this.executiveSummary,
    required this.evidenceLevel,
    required this.tags,
  });

  factory MysteryReport.fromJson(Map<String, dynamic> json) {
    return MysteryReport(
      source: json['fuente'] ?? 'Origen Desconocido',
      executiveSummary:
          json['resumen_ejecutivo'] ?? 'Datos corruptos o ilegibles.',
      evidenceLevel: json['nivel_de_evidencia'] ?? 'Desconocido',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
