import 'package:flutter/material.dart';
import '../../data/models/mystery_report.dart';
import 'evidence_board_view.dart';

class EvidenceBoard extends StatelessWidget {
  final MysteryReport? report;
  final bool isLoading;
  final String? errorMessage;

  const EvidenceBoard({
    super.key,
    this.report,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Fondo con textura oscura (simulación de fibra de carbono/mesa de trabajo)
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        // En producción, usa una imagen local en assets/images/carbon_fiber.png
        image: DecorationImage(
          image: const NetworkImage(
            'https://www.transparenttextures.com/patterns/carbon-fibre.png',
          ),
          repeat: ImageRepeat.repeat,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.8),
            BlendMode.darken,
          ),
        ),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 20),
            Text(
              '// DECRYPTING ARCHIVES...',
              style: TextStyle(color: Colors.amber, fontFamily: 'Courier'),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            '>> ACCESS DENIED: $errorMessage',
            style: const TextStyle(color: Colors.red, fontFamily: 'Courier'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (report == null) {
      return const Center(
        child: Text(
          '// WAITING FOR EVIDENCE...',
          style: TextStyle(color: Colors.white24, fontFamily: 'Courier'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [_ManilaFolderCard(report: report!)]),
    );
  }
}

class _ManilaFolderCard extends StatelessWidget {
  final MysteryReport report;

  const _ManilaFolderCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEvidenceModal(context, report),
      child: Container(
        height: 280, // Altura fija para el efecto de carpeta
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Contraportada (Fondo de la carpeta)
            Positioned(
              top: 20, // Espacio para la pestaña
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC1A178), // Manila oscuro
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            // Pestaña (Tab) integrada visualmente
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 150,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFC1A178),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CASE #${report.tags.isNotEmpty ? report.tags.first.toUpperCase() : "UNK"}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),

            // 2. Documento interno (Hoja de papel asomándose)
            Positioned(
              top: 30,
              left: 15,
              right: 15,
              bottom: 20,
              child: Transform.rotate(
                angle: -0.02, // Ligera rotación para realismo
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFEFE6D5,
                    ), // Beige papel viejo (Más suave)
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CLASSIFIED',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.7),
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const Icon(
                            Icons.fingerprint,
                            color: Colors.black12,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Texto borroso simulado o resumen
                      Text(
                        report.executiveSummary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Portada frontal (Tapa de la carpeta)
            Positioned(
              top: 150, // Cubre la mitad inferior
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0C097), // Manila claro
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      report.source.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withOpacity(0.6),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, size: 16, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            'TAP TO OPEN FILE',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEvidenceModal(BuildContext context, MysteryReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EvidenceModal(report: report),
    );
  }
}

class _EvidenceModal extends StatelessWidget {
  final MysteryReport report;

  const _EvidenceModal({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: EvidenceBoardView(report: report),
      ),
    );
  }
}
