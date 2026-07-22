import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  // List of supported languages with display names, native names, and codes
  final List<Map<String, String>> languages = [
    {'name': 'Assamese', 'native': 'অসমীয়া', 'code': 'as'},
    {'name': 'Bengali', 'native': 'বাংলা', 'code': 'bn'},
    {'name': 'Bodo', 'native': 'बड़ो', 'code': 'brx'},
    {'name': 'Dogri', 'native': 'डोगरी', 'code': 'doi'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'code': 'gu'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'code': 'hi'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'Kashmiri', 'native': 'کٲشُر', 'code': 'ks'},
    {'name': 'Konkani', 'native': 'कोंकणी', 'code': 'kok'},
    {'name': 'Maithili', 'native': 'मैथिली', 'code': 'mai'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'code': 'ml'},
    {'name': 'Manipuri', 'native': 'মৈতৈলোন্', 'code': 'mni'},
    {'name': 'Marathi', 'native': 'मराठी', 'code': 'mr'},
    {'name': 'Nepali', 'native': 'नेपाली', 'code': 'ne'},
    {'name': 'Odia', 'native': 'ଓଡ଼ିଆ', 'code': 'or'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'code': 'pa'},
    {'name': 'Sanskrit', 'native': 'संस्कृतम्', 'code': 'sa'},
    {'name': 'Santali', 'native': 'ᱥᱟᱱᱛᱟᱲᱤ', 'code': 'sat'},
    {'name': 'Sindhi', 'native': 'سنڌي', 'code': 'sd'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'code': 'ta'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'code': 'te'},
    {'name': 'Urdu', 'native': 'اردو', 'code': 'ur'},
  ];

  LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.selectLanguage,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
            tooltip: loc.back,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/levels',
                    arguments: {
                      'langCode': lang['code']!,
                      'langName': lang['name']!,
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang['native']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang['name']!,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
