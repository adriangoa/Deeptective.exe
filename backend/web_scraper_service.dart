import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class WebScraperService {
  static const String _userAgent = 'Mozilla/5.0 (compatible; Deeptective/1.0)';

  /// Busca en DuckDuckGo Lite y extrae contenido de los primeros resultados.
  Future<List<String>> fetchMysteryData(String query) async {
    print('>> INICIANDO RASTREO WEB (DART): $query');
    final List<String> contextData = [];

    try {
      // 1. Búsqueda en DuckDuckGo Lite (Versión ligera HTML sin JS pesado)
      final searchUrl = Uri.parse(
        'https://lite.duckduckgo.com/lite/?q=${Uri.encodeComponent(query)}',
      );

      final searchResponse = await http.get(
        searchUrl,
        headers: {'User-Agent': _userAgent},
      );

      if (searchResponse.statusCode != 200) {
        print('Error buscando en DDG: ${searchResponse.statusCode}');
        return [];
      }

      final document = parser.parse(searchResponse.body);
      final links = <String>[];

      // Selector para enlaces de resultados en DDG Lite (.result-link)
      final resultLinks = document.querySelectorAll('.result-link');
      for (var element in resultLinks.take(3)) {
        final href = element.attributes['href'];
        if (href != null && href.startsWith('http')) {
          links.add(href);
        }
      }

      // 2. Extraer contenido de cada enlace encontrado
      for (final link in links) {
        try {
          print('>> EXTRAYENDO DATOS DE: $link');
          final pageResponse = await http
              .get(Uri.parse(link), headers: {'User-Agent': _userAgent})
              .timeout(
                const Duration(seconds: 5),
              ); // Timeout corto para no bloquear la UI

          if (pageResponse.statusCode == 200) {
            final pageDoc = parser.parse(pageResponse.body);

            // Limpieza del DOM: eliminar scripts, estilos y navegación
            pageDoc
                .querySelectorAll(
                  'script, style, nav, footer, header, aside, iframe, noscript',
                )
                .forEach((element) {
                  element.remove();
                });

            // Obtener texto y limpiar espacios
            String text = pageDoc.body?.text ?? '';
            text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

            // Recortar para no saturar a Gemini
            if (text.length > 2000) text = '${text.substring(0, 2000)}...';

            if (text.length > 100)
              contextData.add('FUENTE: $link\nCONTENIDO: $text');
          }
        } catch (e) {
          print('>> ERROR EN FUENTE ($link): $e');
        }
      }
    } catch (e) {
      print('>> ERROR CRÍTICO EN BÚSQUEDA: $e');
    }
    return contextData;
  }
}
