import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ModuleSelectionScreen extends StatelessWidget {
  final String langCode;
  final int level;

  const ModuleSelectionScreen({
    super.key,
    required this.langCode,
    required this.level,
  });

  // Define modules for each level
  static const Map<int, List<Map<String, String>>> modulesByLevel = {
    1: [
      {'icon': 'న', 'title': 'Script', 'desc': 'Script Basics'},
      {'icon': 'వ', 'title': 'Vocabulary', 'desc': 'Vocabulary'},
      {'icon': '☰', 'title': 'Conversation', 'desc': 'Conversations'},
    ],
    2: [
      {'icon': '✍️', 'title': 'Script Advanced', 'desc': 'Advanced Script'},
      {'icon': '📖', 'title': 'Vocabulary Expansion', 'desc': 'More Words'},
      {'icon': '💬', 'title': 'Conversation Everyday', 'desc': 'Everyday Talk'},
    ],
    3: [
      {'icon': '🔤', 'title': 'Grammar Basics', 'desc': 'Grammar & Structure'},
      {'icon': '🎧', 'title': 'Listening', 'desc': 'Comprehension'},
      {'icon': '🗣️', 'title': 'Conversation Daily Life', 'desc': 'Real Life Talk'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final modules = modulesByLevel[level] ?? modulesByLevel[1]!;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${loc.level} $level ${loc.modules}',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.selectModule,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/submodules',
                      arguments: {
                        'langCode': langCode,
                        'level': level,
                        'module': module['title'],
                      },
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              module['icon']!,
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              // You can localize module titles here if you add keys in ARB
                              module['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Text(
                                  module['desc']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
