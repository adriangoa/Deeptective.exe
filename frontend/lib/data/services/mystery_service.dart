import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/mystery_report.dart';
import '../models/rabbit_hole_suggestion.dart';
import 'web_scraper_service.dart';
import 'intelligence_analyst_service.dart';

class MysteryService {
  // API Key de Gemini (Consíguela en aistudio.google.com)
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Inicia una investigación sobre un [query] específico.
  /// Retorna un [MysteryReport] o lanza una excepción si la red falla.
  Future<MysteryReport> investigateMystery(
    String query, {
    bool isSkeptic = true,
  }) async {
    try {
      // 1. Recopilar datos de la web (Scraping)
      final scraper = WebScraperService();
      final List<String> webData = await scraper.fetchMysteryData(query);
      final String webContext = webData.isEmpty
          ? "Sin datos externos recientes."
          : webData.join("\n\n------------------------\n\n");

      // 2. Análisis de Inteligencia (Nuevo Servicio)
      final analyst = IntelligenceAnalystService();
      final dossier = await analyst.analyzeIntelligence(query, webContext);

      // 3. Adaptar Dossier a MysteryReport para la UI actual
      return MysteryReport(
        source:
            dossier.codename, // Usamos el nombre en clave como fuente/título
        executiveSummary: dossier.executiveSummary,
        evidenceLevel:
            dossier.rabbitHoleDepth, // Usamos la profundidad como nivel
        tags:
            dossier.divergentTheories, // Las teorías divergentes serán los tags
        evidenceLog: dossier.evidenceLog,
      );
    } catch (e) {
      print('Excepción en Investigate: $e');
      // Manejo de errores robusto para la UI
      throw Exception('Conexión interrumpida o fuente bloqueada. Detalles: $e');
    }
  }

  /// Genera sugerencias de "Rabbit Holes" usando Gemini.
  Future<List<RabbitHoleSuggestion>> getSuggestedRabbitHoles() async {
    // MODO DE PRUEBA: Si no hay API Key de Gemini
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'TU_GEMINI_API_KEY') {
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
