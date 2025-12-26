import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mystery_report.dart';
import '../models/rabbit_hole_suggestion.dart';

class MysteryService {
  // API Key de Gemini (Consíguela en aistudio.google.com)
  static const String _geminiApiKey = 'AIzaSyA7K9EntjWb0mpGm64iYOfL1OLT4qPLZBo';

  /// Inicia una investigación sobre un [query] específico.
  /// Retorna un [MysteryReport] o lanza una excepción si la red falla.
  Future<MysteryReport> investigateMystery(
    String query, {
    bool isSkeptic = true,
  }) async {
    try {
      // Usamos el mismo modelo que funcionó para los Rabbit Holes
      const url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_geminiApiKey';

      final String perspective = isSkeptic
          ? "Actúa como un detective ESCÉPTICO y racional. Prioriza explicaciones científicas, lógicas y desmiente mitos sin fundamento. Busca el origen psicológico o sociológico del misterio."
          : "Actúa como un investigador de lo PARANORMAL y 'Creyente'. Mantén la mente abierta a teorías alternativas, conexiones ocultas, fenómenos inexplicables y testimonios de testigos, aunque parezcan imposibles.";

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
                    $perspective
                    
                    Analiza el siguiente caso basándote en tu conocimiento de internet, foros (Reddit, 4chan), wikis y archivos históricos: '$query'.
                    
                    Debes responder ÚNICAMENTE con un objeto JSON válido (sin markdown) con esta estructura:
                    {
                      "fuente": "Menciona la fuente principal, dominio o comunidad más relevante asociada (ej: Reddit r/UnresolvedMysteries, Archivos FBI, Wikipedia)",
                      "resumen_ejecutivo": "Resumen detallado, técnico pero comprensible (máx 100 palabras)",
                      "nivel_de_evidencia": "Bajo, Medio o Alto (basado en el consenso general o pruebas disponibles)",
                      "tags": ["Etiqueta1", "Etiqueta2", "Etiqueta3"]
                    }
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
        // Limpiamos posibles bloques de código Markdown que la IA pueda incluir
        final cleanJson = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return MysteryReport.fromJson(jsonDecode(cleanJson));
      } else {
        print(
          'Error Gemini Investigate [${response.statusCode}]: ${response.body}',
        );
        throw Exception(
          'Error en el enlace neuronal: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Excepción en Investigate: $e');
      // Manejo de errores robusto para la UI
      throw Exception('Conexión interrumpida o fuente bloqueada. Detalles: $e');
    }
  }

  /// Genera sugerencias de "Rabbit Holes" usando Gemini.
  Future<List<RabbitHoleSuggestion>> getSuggestedRabbitHoles() async {
    // MODO DE PRUEBA: Si no hay API Key de Gemini
    if (_geminiApiKey == 'TU_GEMINI_API_KEY') {
      await Future.delayed(const Duration(seconds: 1));
      return [
        RabbitHoleSuggestion(
          topic: 'El Incidente de la Frecuencia 444Hz',
          hook: '¿Control mental masivo o simple mito urbano audiófilo?',
          category: 'Conspiración Digital',
        ),
        RabbitHoleSuggestion(
          topic: 'Göbekli Tepe',
          hook:
              'El templo que reescribe la historia humana 6,000 años antes de lo pensado.',
          category: 'Arqueología Prohibida',
        ),
        RabbitHoleSuggestion(
          topic: 'Cicada 3301',
          hook:
              'El rompecabezas más complejo de internet que recluta genios para un fin desconocido.',
          category: 'Web',
        ),
        RabbitHoleSuggestion(
          topic: 'El Zumbido (The Hum)',
          hook:
              'Un sonido de baja frecuencia que solo el 2% de la población mundial puede escuchar.',
          category: 'Fenómeno Inexplicable',
        ),
        RabbitHoleSuggestion(
          topic: 'Dead Internet Theory',
          hook:
              'La teoría de que la mayoría del tráfico web actual son bots hablando con otros bots.',
          category: 'Tecnología',
        ),
      ];
    }

    try {
      const url =
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
                      "Genera 5 temas de misterio aleatorios y actuales (Arqueología, Conspiraciones Digitales, Fenómenos Inexplicables). Para cada uno, incluye un 'gancho' intrigante. Responde ÚNICAMENTE con un JSON Array válido con esta estructura: [{\"tema\": \"Titulo\", \"gancho\": \"Frase intrigante\", \"categoria\": \"Categoria\"}]",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text =
            data['candidates'][0]['content']['parts'][0]['text'];

        // Limpieza de formato Markdown que Gemini suele añadir
        final cleanJson = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final List<dynamic> jsonList = jsonDecode(cleanJson);
        return jsonList.map((e) => RabbitHoleSuggestion.fromJson(e)).toList();
      } else {
        print('Error Gemini [${response.statusCode}]: ${response.body}');
        throw Exception(
          'Error en el oráculo de Gemini: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Excepción en Rabbit Holes: $e');
      // Ejecutamos diagnóstico para ver qué modelos están disponibles realmente
      await _listAvailableModels();
      throw Exception(
        'Falla al recuperar coordenadas de agujeros de conejo: $e',
      );
    }
  }

  /// Consulta la API para listar los modelos disponibles y sus capacidades.
  Future<void> _listAvailableModels() async {
    try {
      print('\n--- INICIANDO DIAGNÓSTICO DE MODELOS (ListModels) ---');
      // Usamos v1beta para tener la lista más amplia posible
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_geminiApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;

        print('Modelos encontrados con capacidad de generación:');
        for (var model in models) {
          if (model['supportedGenerationMethods'].toString().contains(
            'generateContent',
          )) {
            print(' > ${model['name']}');
          }
        }
      } else {
        print('Error al listar modelos: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
      }
      print('--- FIN DEL DIAGNÓSTICO ---\n');
    } catch (e) {
      print('Error crítico en diagnóstico: $e');
    }
  }
}
