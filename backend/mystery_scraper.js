const axios = require('axios');
const cheerio = require('cheerio');

/**
 * Busca información en la web y extrae texto limpio para contexto de IA.
 * @param {string} query - El tema a investigar.
 * @returns {Promise<string[]>} - Lista de textos extraídos de las fuentes.
 */
async function fetchMysteryData(query) {
    console.log(`>> INICIANDO RASTREO WEB: ${query}`);
    const contextData = [];

    try {
        // 1. Búsqueda en DuckDuckGo Lite (HTML estático, fácil de scrapear)
        const searchUrl = `https://lite.duckduckgo.com/lite/?q=${encodeURIComponent(query)}`;
        const searchResponse = await axios.get(searchUrl, {
            headers: { 'User-Agent': 'Mozilla/5.0 (compatible; Deeptective/1.0)' }
        });

        const $ = cheerio.load(searchResponse.data);
        const links = [];

        // Extraer los primeros 3 enlaces reales
        $('.result-link').each((i, el) => {
            if (i < 3) {
                const link = $(el).attr('href');
                if (link) links.push(link);
            }
        });

        // 2. Extraer contenido de cada enlace
        for (const link of links) {
            try {
                console.log(`>> EXTRAYENDO DATOS DE: ${link}`);
                const pageResponse = await axios.get(link, { timeout: 5000 });
                const $page = cheerio.load(pageResponse.data);

                // Limpieza del DOM: eliminar scripts, estilos, navegación, etc.
                $page('script, style, nav, footer, header, aside, iframe').remove();

                // Obtener texto y limpiar espacios excesivos
                let text = $page('body').text().replace(/\s+/g, ' ').trim();

                // Recortar a 2000 caracteres para no saturar el prompt de Gemini
                if (text.length > 2000) {
                    text = text.substring(0, 2000) + '...';
                }

                if (text.length > 100) {
                    contextData.push(`FUENTE: ${link}\nCONTENIDO: ${text}`);
                }
            } catch (err) {
                console.warn(`>> ERROR EN FUENTE (${link}): ${err.message}`);
            }
        }
    } catch (error) {
        console.error('>> ERROR CRÍTICO EN BÚSQUEDA:', error.message);
    }

    return contextData;
}

module.exports = { fetchMysteryData };
