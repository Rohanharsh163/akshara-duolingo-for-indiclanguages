import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SubmoduleSelectionScreen extends StatelessWidget {
  final String langCode;
  final String module;
  final int level;

  const SubmoduleSelectionScreen({
    super.key,
    required this.langCode,
    required this.module,
    required this.level,
  });

  // Define submodules for each module
  static const Map<String, List<String>> moduleStructure = {
    // Level 1 modules
    'Script': ['Vowels', 'Consonants', 'Letter Combos', 'Script in Words'],
    'Vocabulary': ['Everyday Objects', 'Food', 'Family', 'Nature'],
    'Conversation': [
      'Greetings',
      'Self-introduction',
      'Yes/No',
      'Polite Expressions',
    ],
    // Level 2 modules
    'Script Advanced': ['Syllables', 'Ligatures', 'Rare Letters', 'Usage'],
    'Vocabulary Expansion': ['Days', 'Colors', 'Numbers', 'Food'],
    'Conversation Everyday': ['Asking', 'Requests', 'Shopping', 'Directions'],
    // Level 3 modules
    'Grammar Basics': ['Tenses', 'Plurals', 'Particles', 'Negation'],
    'Listening': ['Words', 'Phrases', 'Sentences', 'Dialogues'],
    'Conversation Daily Life': ['Shopping', 'Travel', 'Emergencies', 'Plans'],
  };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final submodules = moduleStructure[module] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$module - ${loc?.level ?? "Level"} $level',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submodules.length,
        itemBuilder: (context, index) {
          final submodule = submodules[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                submodule,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(
                context,
                '/questions',
                arguments: {
                  'langCode': langCode,
                  'level': level,
                  'module': module,
                  'submodule': submodule,
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
