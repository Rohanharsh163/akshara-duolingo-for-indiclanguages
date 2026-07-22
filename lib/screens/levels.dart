import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LevelSelectionScreen extends StatelessWidget {
  final String langCode;
  final String langName;

  const LevelSelectionScreen({
    super.key,
    required this.langCode,
    required this.langName,
  });

  // Level descriptions can be localized or customized per language
  static const List<String> levelDescriptions = [
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${loc?.selectLevel ?? "Select Level"} - $langName',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          final level = index + 1;
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/modules',
              arguments: {
                'langCode': langCode,
                'level': level,
              },
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${loc?.level ?? "Level"} $level',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc != null
                        ? (index == 0
                            ? loc.beginner
                            : index == 1
                                ? loc.intermediate
                                : loc.advanced)
                        : levelDescriptions[index],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
