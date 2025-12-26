import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/intelligence_dossier.dart';

class IntelligenceAnalystService {
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<IntelligenceDossier> analyzeIntelligence(
    String query,
    String context,
  ) async {
    try {
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_geminiApiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      """
Eres un analista de inteligencia de una agencia secreta. Tu misión es procesar datos crudos de la web y convertirlos en un Dossier de Investigación.

QUERY: $query

CONTEXTO DE DATOS CRUDOS:
$context

Estructura de respuesta (JSON estrictamente):
{
  "codename": "Un nombre en clave para el caso",
  "executive_summary": "Resumen conciso pero intrigante",
  "evidence_log": [
    { "fuente": "Origen del dato", "fragmento_clave": "Dato específico", "veracidad_estimada": "Alta/Media/Baja" }
  ],
  "rabbit_hole_depth": "Un porcentaje de qué tan profundo es este misterio",
  "divergent_theories": ["Teoría 1", "Teoría 2"]
}

Tono: Frío, analítico y misterioso. Si la información es contradictoria, resáltalo como una anomalía.
Responde ÚNICAMENTE con el objeto JSON.
""",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        final cleanJson = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return IntelligenceDossier.fromJson(jsonDecode(cleanJson));
      } else {
        throw Exception('Error Intelligence Analyst: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falla en análisis de inteligencia: $e');
    }
  }
}
