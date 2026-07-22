import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your generated localization delegate
import 'l10n/app_localizations.dart';

// Import Supabase config
import 'supabase_config.dart';

// Import your screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home.dart';
import 'screens/language_selection_screen.dart';
import 'screens/levels.dart';
import 'screens/module_selection_screen.dart';
import 'screens/submodules.dart';
import 'screens/question_screen.dart';
import 'screens/result_screen.dart';
import 'screens/streaks.dart';
import 'screens/match_the_following_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akshara',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(setLocale: setLocale),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => AuthWrapper(setLocale: setLocale),
        '/languages': (context) => LanguageSelectionScreen(),
        '/levels': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return LevelSelectionScreen(
            langCode: args?['langCode'] ?? 'te',
            langName: args?['langName'] ?? 'Telugu',
          );
        },
        '/modules': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return ModuleSelectionScreen(
            langCode: args?['langCode'] ?? 'te',
            level: args?['level'] ?? 1,
          );
        },
        '/submodules': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return SubmoduleSelectionScreen(
            langCode: args?['langCode'] ?? 'te',
            module: args?['module'] ?? 'Script',
            level: args?['level'] ?? 1,
          );
        },
        '/questions': (context) => const QuestionScreen(),
        '/result': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return ResultScreen(
            score: args?['score'] ?? 0,
            total: args?['total'] ?? 0,
            langCode: args?['langCode'] ?? 'te',
            module: args?['module'] ?? 'Script',
            submodule: args?['submodule'] ?? '',
          );
        },
        '/streaks': (context) => const StreaksScreen(),
        '/match': (context) => const MatchTheFollowingScreen(),
      },
    );
  }
}

/// AuthWrapper: Shows Home if logged in, Login if not
class AuthWrapper extends StatelessWidget {
  final void Function(Locale locale) setLocale;
  const AuthWrapper({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseConfig.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data!.session != null) {
          // Pass setLocale to HomeScreen for language switching
          return HomeScreen(setLocale: setLocale);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

