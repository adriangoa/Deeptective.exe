class EvidenceLogItem {
  final String source;
  final String keyFragment;
  final String estimatedVeracity;

  EvidenceLogItem({
    required this.source,
    required this.keyFragment,
    required this.estimatedVeracity,
  });

  factory EvidenceLogItem.fromJson(Map<String, dynamic> json) {
    return EvidenceLogItem(
      source: json['source'] ?? 'Unknown Source',
      keyFragment: json['keyFragment'] ?? 'No data available',
      estimatedVeracity: json['estimatedVeracity'] ?? 'Unknown',
    );
  }
}

class IntelligenceDossier {
  final String codename;
  final String executiveSummary;
  final List<EvidenceLogItem> evidenceLog;
  final String rabbitHoleDepth;
  final List<String> divergentTheories;

  IntelligenceDossier({
    required this.codename,
    required this.executiveSummary,
    required this.evidenceLog,
    required this.rabbitHoleDepth,
    required this.divergentTheories,
  });

  factory IntelligenceDossier.fromJson(Map<String, dynamic> json) {
    return IntelligenceDossier(
      codename: json['codename'] ?? 'Unknown Case',
      executiveSummary: json['executive_summary'] ?? 'No summary available',
      evidenceLog: (json['evidence_log'] as List<dynamic>? ?? [])
          .map((item) => EvidenceLogItem(
                source: item['fuente'] ?? 'Unknown',
                keyFragment: item['fragmento_clave'] ?? 'No data',
                estimatedVeracity: item['veracidad_estimada'] ?? 'Unknown',
              ))
          .toList(),
      rabbitHoleDepth: json['rabbit_hole_depth'] ?? '0%',
      divergentTheories: List<String>.from(json['divergent_theories'] ?? []),
    );
  }
}