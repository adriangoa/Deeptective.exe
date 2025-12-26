import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'data/models/mystery_report.dart';
import 'data/models/rabbit_hole_suggestion.dart';
import 'data/services/mystery_service.dart';
import 'ui/widgets/evidence_board.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const DeeptectiveApp());
}

class DeeptectiveApp extends StatelessWidget {
  const DeeptectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deeptective.exe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.detectiveTheme, // Aplicando el tema
      home: const TerminalHomePage(),
    );
  }
}

class TerminalHomePage extends StatefulWidget {
  const TerminalHomePage({super.key});

  @override
  State<TerminalHomePage> createState() => _TerminalHomePageState();
}

class _TerminalHomePageState extends State<TerminalHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final MysteryService _mysteryService = MysteryService();
  bool _isLoading = false;
  bool _isLoadingSuggestions = false;
  List<RabbitHoleSuggestion> _suggestions = [];
  MysteryReport? _report;
  bool _isSkeptic = true; // Estado por defecto: Escéptico
  String? _errorMessage;

  Future<void> _initiateScan() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Ocultar teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _report = null;
      _errorMessage = null;
    });

    try {
      final report = await _mysteryService.investigateMystery(
        query,
        isSkeptic: _isSkeptic,
      );
      setState(() {
        _report = report;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRabbitHoles() async {
    setState(() {
      _isLoadingSuggestions = true;
      _errorMessage = null;
    });

    try {
      final suggestions = await _mysteryService.getSuggestedRabbitHoles();
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('> DEEPTECTIVE.EXE')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('// SYSTEM INITIALIZED...'),
            const SizedBox(height: 10),
            const SizedBox(height: 30),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter search query...',
                prefixIcon: Icon(Icons.terminal),
              ),
              style: TextStyle(color: primaryColor),
              onSubmitted: (_) => _initiateScan(),
            ),
            const SizedBox(height: 10),
            // Selector de Modo (Escéptico / Creyente)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isSkeptic ? 'MODE: SKEPTIC' : 'MODE: BELIEVER',
                  style: TextStyle(
                    color: _isSkeptic ? Colors.cyan : Colors.purpleAccent,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: !_isSkeptic, // Invertido para que ON sea "Believer"
                  onChanged: (value) {
                    setState(() {
                      _isSkeptic = !value;
                    });
                  },
                  activeColor: Colors.purpleAccent,
                  inactiveThumbColor: Colors.cyan,
                  inactiveTrackColor: Colors.cyan.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoadingSuggestions)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.amber,
              ),
            if (_suggestions.isNotEmpty && !_isLoadingSuggestions) ...[
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = item.topic;
                        _initiateScan();
                      },
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '// ${item.category.toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 10,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.topic,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item.hook,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontFamily: 'Courier',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: EvidenceBoard(
                report: _report,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : _initiateScan,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    foregroundColor: primaryColor,
                  ),
                  child: Text(_isLoading ? 'SCANNING...' : 'INITIATE SCAN'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: (_isLoading || _isLoadingSuggestions)
                      ? null
                      : _loadRabbitHoles,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber),
                    foregroundColor: Colors.amber,
                  ),
                  child: Text(
                    _isLoadingSuggestions ? 'ACCESSING...' : 'RANDOM ACCESS',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
