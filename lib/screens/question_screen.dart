import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../l10n/app_localizations.dart';
import 'result_screen.dart';

// Define your backend base URL here
const String baseUrl = 'https://akshara-xh35.onrender.com';

// Language code mapping for TTS/STT
const Map<String, Map<String, String>> languageCodes = {
  'as': {'tts': 'as-IN', 'stt': 'as_IN'},
  'bn': {'tts': 'bn-IN', 'stt': 'bn_IN'},
  'brx': {'tts': 'brx-IN', 'stt': 'brx_IN'},
  'doi': {'tts': 'doi-IN', 'stt': 'doi_IN'},
  'gu': {'tts': 'gu-IN', 'stt': 'gu_IN'},
  'hi': {'tts': 'hi-IN', 'stt': 'hi_IN'},
  'kn': {'tts': 'kn-IN', 'stt': 'kn_IN'},
  'ks': {'tts': 'ks-IN', 'stt': 'ks_IN'},
  'kok': {'tts': 'kok-IN', 'stt': 'kok_IN'},
  'mai': {'tts': 'mai-IN', 'stt': 'mai_IN'},
  'ml': {'tts': 'ml-IN', 'stt': 'ml_IN'},
  'mni': {'tts': 'mni-IN', 'stt': 'mni_IN'},
  'mr': {'tts': 'mr-IN', 'stt': 'mr_IN'},
  'ne': {'tts': 'ne-IN', 'stt': 'ne_IN'},
  'or': {'tts': 'or-IN', 'stt': 'or_IN'},
  'pa': {'tts': 'pa-IN', 'stt': 'pa_IN'},
  'sa': {'tts': 'sa-IN', 'stt': 'sa_IN'},
  'sat': {'tts': 'sat-IN', 'stt': 'sat_IN'},
  'sd': {'tts': 'sd-IN', 'stt': 'sd_IN'},
  'ta': {'tts': 'ta-IN', 'stt': 'ta_IN'},
  'te': {'tts': 'te-IN', 'stt': 'te_IN'},
  'ur': {'tts': 'ur-IN', 'stt': 'ur_IN'},
};

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  String _lastWords = '';
  bool _speechEnabled = false;
  int currentQuestion = 0;
  int score = 0;
  String? selectedOption;
  bool showResult = false;
  late Future<List<Map<String, dynamic>>> _questionsFuture;
  late String langCode;
  late int level;
  late String module;
  late String submodule;
  late String ttsLang;
  late String sttLang;

  // Level and module structure for navigation
  final Map<int, List<String>> levels = {
    1: ['Script', 'Vocabulary', 'Conversation'],
    2: ['Script Advanced', 'Vocabulary Expansion', 'Conversation Everyday'],
    3: ['Grammar Basics', 'Listening', 'Conversation Daily Life'],
  };

  final Map<String, List<String>> moduleStructure = {
    // Level 1
    'Script': ['Vowels', 'Consonants', 'Letter Combos', 'Script in Words'],
    'Vocabulary': ['Everyday Objects', 'Food', 'Family', 'Nature'],
    'Conversation': [
      'Greetings',
      'Self-introduction',
      'Yes/No',
      'Polite Expressions',
    ],
    // Level 2
    'Script Advanced': ['Syllables', 'Ligatures', 'Rare Letters', 'Usage'],
    'Vocabulary Expansion': ['Days', 'Colors', 'Numbers', 'Food'],
    'Conversation Everyday': ['Asking', 'Requests', 'Shopping', 'Directions'],
    // Level 3
    'Grammar Basics': ['Tenses', 'Plurals', 'Particles', 'Negation'],
    'Listening': ['Words', 'Phrases', 'Sentences', 'Dialogues'],
    'Conversation Daily Life': ['Shopping', 'Travel', 'Emergencies', 'Plans'],
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await speech.initialize();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    langCode = args['langCode'] ?? 'te';
    level = args['level'] ?? 1;
    module = args['module'] ?? 'Script';
    submodule = args['submodule'] ?? 'Vowels';
    ttsLang = languageCodes[langCode]?['tts'] ?? 'en-IN';
    sttLang = languageCodes[langCode]?['stt'] ?? 'en_IN';
    _questionsFuture = fetchQuestions(langCode, level, module, submodule);
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(
    String langCode,
    int level,
    String module,
    String submodule,
  ) async {
    try {
      final languageName = _getLanguageName(langCode);
      final uri = Uri.parse(
        '$baseUrl/questions/'
        '?language=${Uri.encodeComponent(languageName)}'
        '&level=$level'
        '&module=${Uri.encodeComponent(module)}'
        '&submodule=${Uri.encodeComponent(submodule)}'
        '&limit=10',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load questions (Status ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _getLanguageName(String code) {
    const langMap = {
      'as': 'Assamese',
      'bn': 'Bengali',
      'brx': 'Bodo',
      'doi': 'Dogri',
      'gu': 'Gujarati',
      'hi': 'Hindi',
      'kn': 'Kannada',
      'ks': 'Kashmiri',
      'kok': 'Konkani',
      'mai': 'Maithili',
      'ml': 'Malayalam',
      'mni': 'Manipuri',
      'mr': 'Marathi',
      'ne': 'Nepali',
      'or': 'Odia',
      'pa': 'Punjabi',
      'sa': 'Sanskrit',
      'sat': 'Santali',
      'sd': 'Sindhi',
      'ta': 'Tamil',
      'te': 'Telugu',
      'ur': 'Urdu',
    };
    return langMap[code] ?? code;
  }

  bool _hasHiddenWord(Map<String, dynamic> question) {
    return question.containsKey('hiddenWord') &&
        question['question'].contains('{audio_only}');
  }

  Future<void> _speakHiddenWord(String hiddenWord) async {
    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(hiddenWord);
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> _playQuestionAudio(Map<String, dynamic> question) async {
    if (_hasHiddenWord(question)) {
      final hiddenWord = question['hiddenWord'];
      await _speakHiddenWord(hiddenWord);
    } else {
      await _speak(question['question']);
    }
  }

  void _startListening(List<String> options, String answer) async {
    await speech.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          final spokenText = _lastWords.trim().toLowerCase();
          for (var option in options) {
            if (option.toLowerCase().contains(spokenText) ||
                spokenText.contains(option.toLowerCase())) {
              selectedOption = option;
              showResult = true;
              if (option == answer) score++;
              _stopListening();
              break;
            }
          }
        });
      },
      localeId: sttLang,
    );
  }

  void _stopListening() async {
    await speech.stop();
  }

  Widget _buildQuestionSection(Map<String, dynamic> question) {
    final hasHiddenWord = _hasHiddenWord(question);
    String displayQuestion;
    if (hasHiddenWord) {
      displayQuestion = question['question'].replaceAll('{audio_only}', '🔊');
    } else {
      displayQuestion = question['question'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                displayQuestion,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 24),
                label: Text(hasHiddenWord ? 'Listen' : 'Hear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasHiddenWord ? Colors.blue : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _playQuestionAudio(question),
              ),
            ),
          ],
        ),
        if (hasHiddenWord) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.headphones, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Listen carefully to identify the letter used in this word',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void nextQuestion(List<Map<String, dynamic>> questions) {
    _stopListening();
    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        selectedOption = null;
        showResult = false;
        _lastWords = '';
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              total: questions.length,
              langCode: langCode,
              module: module,
              submodule: submodule,
            ),
          ),
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.quizResults)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.quizResults)),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final questions = snapshot.data!;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.quizResults)),
            body: Center(child: Text(loc.noQuestions)),
          );
        }

        final question = questions[currentQuestion];
        final options = List<String>.from(question['options']);

        return Scaffold(
          appBar: AppBar(
            title: Text('${loc.quizResults} - $submodule'),
            backgroundColor: Colors.orange,
          ),
          floatingActionButton: _speechEnabled
              ? FloatingActionButton(
                  onPressed: () => _startListening(options, question['answer']),
                  tooltip: loc.speakAnswer,
                  child: const Icon(Icons.mic),
                )
              : null,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (currentQuestion + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                const SizedBox(height: 16),
                Text(
                  '${loc.question} ${currentQuestion + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildQuestionSection(question),
                const SizedBox(height: 20),
                if (_lastWords.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.youSaid}: $_lastWords',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                ...List.generate(options.length, (index) {
                  final option = options[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedOption == option
                            ? (option == question['answer']
                                ? Colors.green
                                : Colors.red)
                            : Colors.orange[100],
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: selectedOption == null
                          ? () {
                              setState(() {
                                selectedOption = option;
                                showResult = true;
                                if (option == question['answer']) score++;
                              });
                            }
                          : null,
                      child: Text(option, style: const TextStyle(fontSize: 18)),
                    ),
                  );
                }),
                const SizedBox(height: 30),
                if (showResult)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          selectedOption == question['answer']
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: selectedOption == question['answer']
                              ? Colors.green
                              : Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedOption == question['answer']
                              ? loc.correct
                              : '${loc.oops} ${loc.correctAnswerIs} "${question['answer']}"',
                          style: TextStyle(
                            color: selectedOption == question['answer']
                                ? Colors.green
                                : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => nextQuestion(questions),
                          child: Text(
                            currentQuestion < questions.length - 1
                                ? loc.nextQuestion
                                : loc.seeResults,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
