import 'package:flutter/material.dart';
import '../../data/models/mystery_report.dart';
import '../../data/models/intelligence_dossier.dart';

class EvidenceBoardView extends StatelessWidget {
  final MysteryReport report;

  const EvidenceBoardView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo general del visor
        Container(color: const Color(0xFF121212)),

        // Contenido Scrollable
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildRabbitHoleMeter(),
                    const SizedBox(height: 30),
                    _buildSectionTitle('EXECUTIVE SUMMARY'),
                    _buildDocumentCard(
                      child: Text(
                        report.executiveSummary,
                        style: _typewriterStyle,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSectionTitle('EVIDENCE LOG'),
                    ...report.evidenceLog.map((log) => _buildEvidenceItem(log)),
                    const SizedBox(height: 30),
                    _buildSectionTitle('DIVERGENT THEORIES'),
                    _buildTheoriesCard(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Efecto de Ruido / Interferencia (Overlay)
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/stardust.png',
                repeat: ImageRepeat.repeat,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CASE FILE: ${report.source.toUpperCase()}',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Courier',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'TOP SECRET // EYES ONLY',
            style: TextStyle(
              color: Colors.redAccent,
              fontFamily: 'Courier',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRabbitHoleMeter() {
    // Extraer número del string (ej: "85%")
    double percentage = 0.0;
    try {
      final clean = report.evidenceLevel.replaceAll(RegExp(r'[^0-9]'), '');
      percentage = (double.tryParse(clean) ?? 0) / 100;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[800],
                  color: Colors.cyanAccent,
                  strokeWidth: 6,
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RABBIT HOLE DEPTH',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  percentage > 0.7 ? 'CRITICAL ANOMALY' : 'STANDARD MYSTERY',
                  style: TextStyle(
                    color: percentage > 0.7 ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      if (percentage > 0.7)
                        const BoxShadow(color: Colors.red, blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        '// $title',
        style: TextStyle(
          color: Colors.amber[700],
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDocumentCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6D5), // Hueso / Papel viejo
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
      ),
      child: child,
    );
  }

  Widget _buildEvidenceItem(EvidenceLogItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: _buildDocumentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.source.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'VERACITY: ${item.estimatedVeracity}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black26),
            const SizedBox(height: 5),
            Container(
              color: const Color(0xFFFFF59D), // Efecto resaltador amarillo
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                item.keyFragment,
                style: _typewriterStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheoriesCard() {
    return _buildDocumentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.tags
            .map(
              (theory) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Text(theory, style: _typewriterStyle)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static const TextStyle _typewriterStyle = TextStyle(
    color: Colors.black87,
    fontFamily: 'Courier',
    fontSize: 15,
    height: 1.4,
  );
}
