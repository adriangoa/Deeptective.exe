import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mystery_report.dart';

class MysteryService {
  // TODO: En producción, mueve esta clave a un archivo .env o un servicio de secretos.
  static const String _apiKey = 'TU_PERPLEXITY_API_KEY';
  static const String _baseUrl = 'https://api.perplexity.ai/chat/completions';

  /// Inicia una investigación sobre un [query] específico.
  /// Retorna un [MysteryReport] o lanza una excepción si la red falla.
  Future<MysteryReport> investigateMystery(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // Usamos un modelo con capacidad de búsqueda en internet (sonar-online)
          "model": "llama-3.1-sonar-small-128k-online",
          "messages": [
            {
              "role": "system",
              "content": """
                Actúa como 'Deeptective', una IA investigadora de misterios.
                Tu objetivo es buscar información en internet priorizando:
                1. Foros de discusión (Reddit, 4chan, foros especializados).
                2. Archivos históricos y wikis de misterio.
                3. Teorías divergentes y orígenes oscuros.

                Debes responder ÚNICAMENTE con un objeto JSON válido (sin markdown) con esta estructura:
                {
                  "fuente": "Nombre de la fuente principal o dominio más relevante",
                  "resumen_ejecutivo": "Resumen detallado, técnico pero comprensible (máx 100 palabras)",
                  "nivel_de_evidencia": "Bajo, Medio o Alto (basado en la fiabilidad de las fuentes)",
                  "tags": ["Etiqueta1", "Etiqueta2", "Etiqueta3"]
                }
              """,
            },
            {"role": "user", "content": "Investiga el siguiente caso: $query"},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Limpiamos posibles bloques de código Markdown que la IA pueda incluir
        final cleanJson = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return MysteryReport.fromJson(jsonDecode(cleanJson));
      } else {
        throw Exception(
          'Error en el enlace neuronal: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      // Manejo de errores robusto para la UI
      throw Exception('Conexión interrumpida o fuente bloqueada. Detalles: $e');
    }
  }
}
